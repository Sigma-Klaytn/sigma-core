//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract UpgradeableTokenSaleV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* ========== STATE VARIABLES ========== */

    IERC20Upgradeable public SIG;
    bool public tokensReleased;
    uint256 public totalDeposit;
    address public receiver;
    mapping(address => DepositInfo) public depositOf;

    uint256 public phase1StartTs;
    uint256 public phase2StartTs;
    uint256 public phase2EndTs;

    uint256 public constant HOUR = 3600;
    uint256 public constant TOTAL_SIG_SUPPLY = 9000000000000000000000000; //9M Token

    struct DepositInfo {
        uint256 amount;
        bool withdrewAtPhase2;
        bool tokensClaimed;
    }

    event InitialInfoSet(
        uint256 phase1StartTs,
        uint256 phase2StartTs,
        uint256 phase2EndTs,
        address receiver
    );

    event Deposit(address user, uint256 amount);
    event Withdrawal(address user, uint256 amount);
    event SIGTokenReleased(uint256 at, uint256 releasedTokenAmount);
    event AdminWithdraw(uint256 withdrawAmount);
    event TokenClaimed(address user, uint256 amount);

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    /**
        @notice Deposit KLAY into this contract, only allowed during Phase1.
     */
    function deposit() external payable whenNotPaused nonReentrant {
        uint256 _amount = msg.value;
        require(block.timestamp > phase1StartTs, "Phase 1 did not start yet.");
        require(
            block.timestamp < phase2StartTs,
            "Deposit period is already ended"
        );
        require(_amount > 0, "Amount should be bigger than 0");

        // Update User's Deposit Balance
        DepositInfo storage userDeposit = depositOf[msg.sender];
        userDeposit.amount += _amount;

        // Update Total Deposit
        totalDeposit += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /**
        @notice Withdraw KLAY from this contract, allowed during Phase1 and Phase2.
     */
    function withdraw(uint256 _requiredAmount)
        external
        whenNotPaused
        nonReentrant
    {
        require(
            block.timestamp < phase2EndTs,
            "Withdraw period is already done."
        );

        require(
            _requiredAmount > 0,
            "Required amount of withdrawal should be bigger than 0"
        );

        DepositInfo storage userDeposit = depositOf[msg.sender];
        require(userDeposit.amount > 0, "No funds available to withdraw");

        uint256 withdrawableAmount = 0;
        if (block.timestamp > phase2StartTs) {
            require(
                userDeposit.withdrewAtPhase2 == false,
                "Already withdrew fund. Withdrawal is only permitted once."
            );

            uint256 currentSlot = (phase2EndTs - block.timestamp) / HOUR;
            uint256 totalSlot = (phase2EndTs - phase2StartTs) / HOUR;

            uint256 withdrawablePortion = _getWithdrawablePortion(
                currentSlot,
                totalSlot
            );

            withdrawableAmount =
                (userDeposit.amount * withdrawablePortion) /
                1e18;
            userDeposit.withdrewAtPhase2 = true;
        } else {
            withdrawableAmount = userDeposit.amount;
        }

        require(
            _requiredAmount <= withdrawableAmount,
            "You can't withdraw more than current withdrawable amount"
        );

        userDeposit.amount -= _requiredAmount;
        totalDeposit -= _requiredAmount;

        payable(msg.sender).transfer(_requiredAmount);

        emit Withdrawal(msg.sender, _requiredAmount);
    }

    /**
        @notice Withdraw pro-rata allocated SIG tokens, only allowed at the end of the launch (after Phase2).
     */
    function withdrawTokens() external whenNotPaused nonReentrant {
        require(
            block.timestamp > phase2EndTs,
            "You can't withdraw tokens before phase 2 ends."
        );

        require(tokensReleased, "Token is not released yet");

        DepositInfo storage userDeposit = depositOf[msg.sender];
        require(userDeposit.amount > 0, "No funds available to withdraw token");
        require(!userDeposit.tokensClaimed, "Tokens are already claimed");

        uint256 portion = _getWithdrawableTokenPortion(
            userDeposit.amount,
            totalDeposit
        );
        uint256 amount = (portion * TOTAL_SIG_SUPPLY) / 1e18;
        require(amount != 0, "No withdrawable Token.");

        SIG.safeTransfer(msg.sender, amount);

        userDeposit.tokensClaimed = true;

        emit TokenClaimed(msg.sender, amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getWithdrawableAmount() external view returns (uint256) {
        if (phase2EndTs < block.timestamp) {
            return 0;
        }
        DepositInfo memory userDeposit = depositOf[msg.sender];
        if (block.timestamp < phase2StartTs) {
            return userDeposit.amount;
        } else {
            if (userDeposit.withdrewAtPhase2) {
                return 0;
            }

            if (userDeposit.tokensClaimed) {
                return 0;
            }

            uint256 currentSlot = (phase2EndTs - block.timestamp) / HOUR;
            uint256 totalSlot = (phase2EndTs - phase2StartTs) / HOUR;

            uint256 withdrawablePortion = _getWithdrawablePortion(
                currentSlot,
                totalSlot
            );
            return (userDeposit.amount * withdrawablePortion) / 1e18;
        }
    }

    function getWithdrawableTokenAmount() external view returns (uint256) {
        DepositInfo memory userDeposit = depositOf[msg.sender];
        if (userDeposit.amount == 0 || userDeposit.tokensClaimed) {
            return 0;
        }

        uint256 portion = _getWithdrawableTokenPortion(
            userDeposit.amount,
            totalDeposit
        );
        uint256 amount = (portion * TOTAL_SIG_SUPPLY) / 1e18;

        return amount;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _getWithdrawablePortion(uint256 _currentSlot, uint256 _totalSlot)
        internal
        pure
        returns (uint256)
    {
        uint256 portion = ((_currentSlot + 1) * 1e18) / _totalSlot;
        if (portion < 1e18) {
            return portion;
        } else {
            return 1e18;
        }
    }

    function _getWithdrawableTokenPortion(
        uint256 _depositAmount,
        uint256 _totalDepositAmount
    ) internal pure returns (uint256) {
        uint256 portion = (_depositAmount * 1e18) / _totalDepositAmount;
        return portion;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
        @notice Initialize the contract's basic config parameters, which contains 
        1) Total SIG distribution amount
        2) The phase start/end timestamps. 
     */
    function setInitialInfo(
        uint256 _phase1StartTs,
        uint256 _phase2StartTs,
        uint256 _phase2EndTs,
        address _SIG,
        address _receiver
    ) external onlyOwner {
        require(
            _phase1StartTs < _phase2StartTs,
            "Phase2 should start after phase1"
        );
        require(
            _phase2StartTs < _phase2EndTs,
            "phase2StartTs should smaller than phase2EndTs"
        );
        require(
            (_phase2EndTs - _phase2StartTs) == HOUR * 24,
            "Phase2 should be 24 hours."
        );
        require(_receiver != address(0), "Invalid receiver address");

        phase1StartTs = _phase1StartTs;
        phase2StartTs = _phase2StartTs;
        phase2EndTs = _phase2EndTs;
        SIG = IERC20Upgradeable(_SIG);
        receiver = _receiver;

        emit InitialInfoSet(
            phase1StartTs,
            phase2StartTs,
            phase2EndTs,
            _receiver
        );
    }

    /**
        @notice Withdraw the contract's KSUDT balance at the end of the launch.
     */
    function adminWithdraw() external onlyOwner {
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to withdraw KLAY Tokens."
        );

        uint256 balanceOfKLAY = address(this).balance;
        require(balanceOfKLAY > 0, "There is no withdrawable amount of KLAY");

        payable(receiver).transfer(balanceOfKLAY);

        emit AdminWithdraw(balanceOfKLAY);
    }

    /**
        @notice Allows depositors to claim their share of the tokens.
     */
    function releaseToken() external onlyOwner {
        require(tokensReleased == false, "Tokens are already released.");
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to release SIG Tokens."
        );

        SIG.safeTransferFrom(msg.sender, address(this), TOTAL_SIG_SUPPLY);
        tokensReleased = true;

        emit SIGTokenReleased(block.timestamp, TOTAL_SIG_SUPPLY);
    }

    /**
        @notice Change KLAY receiver address
     */
    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Invalid receiver address");
        receiver = _receiver;
    }

    /**
        @notice restrict upgrade to only owner.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}

    /**
        @notice pause contract functions.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
        @notice unpause contract functions.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
}
