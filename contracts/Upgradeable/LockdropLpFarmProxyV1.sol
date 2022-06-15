//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../interfaces/sigma/ILockdrop.sol";
import "../interfaces/sigma/ILpFarm.sol";

contract LockdropLpFarmProxyV1 is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* ========== STATE VARIABLES ========== */
    IERC20Upgradeable public lpToken; // KSP - sigKSP lp
    ILockdrop public lockdrop;
    ILpFarm public lpFarm;

    bool public isLPTokensReleased;
    uint256 public totalLPTokenSupply;
    uint256 public totalLockdropDeposit;

    mapping(address => bool) public isForwarded;

    event LPTokenReleased(uint256 timestamp, uint256 amount);

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    /**
        @notice Initialize the contract's basic config parameters, which contains 
     */
    function setInitialInfo(
        address _lpToken,
        address _lockdrop,
        address _lpFarm
    ) external onlyOwner {
        lpToken = IERC20Upgradeable(_lpToken);
        lockdrop = ILockdrop(_lockdrop);
        lpFarm = ILpFarm(_lpFarm);
        totalLockdropDeposit = 227100212865627939698517;
    }

    /* ========== External & Public FUNCTIONS ========== */

    /**
        @notice forward lp token to lpfarm
     */

    function forwardLpTokenToLpFarm() external {
        require(!isForwarded[msg.sender], "already forwarded");

        uint256 withdrawableLpToken = getWithdrawableLPTokenAmount();
        (
            uint256 amount, // deposited KSP amount
            uint256 weight, // weight = lockMonth * amount
            uint256 lockMonth, // locked month
            uint256 claimedSIG, // released amount sig
            bool withdrewAtPhase2, // if it's withdrawn at phase 2
            bool isLPTokensClaimed
        ) = lockdrop.depositOf(msg.sender);

        if (withdrawableLpToken > 0) {
            lpFarm.forwardLpTokensFromLockdrop(
                msg.sender,
                withdrawableLpToken,
                lockMonth
            );

            isForwarded[msg.sender] = true;
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getWithdrawableLPTokenAmount() public view returns (uint256) {
        (
            uint256 amount, // deposited KSP amount
            uint256 weight, // weight = lockMonth * amount
            uint256 lockMonth, // locked month
            uint256 claimedSIG, // released amount sig
            bool withdrewAtPhase2, // if it's withdrawn at phase 2
            bool isLPTokensClaimed
        ) = lockdrop.depositOf(msg.sender);

        if (amount == 0 || !isLPTokensReleased || totalLPTokenSupply == 0) {
            return 0;
        }
        uint256 portion = _getWithdrawableTokenPortion(
            amount,
            totalLockdropDeposit
        );
        uint256 withdrawableAmount = (portion * totalLPTokenSupply) / 1e18;
        return withdrawableAmount;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _getWithdrawableTokenPortion(
        uint256 _depositAmount,
        uint256 _totalDepositAmount
    ) internal pure returns (uint256) {
        if (_totalDepositAmount == 0) {
            return 1e18;
        } else {
            uint256 portion = (_depositAmount * 1e18) / _totalDepositAmount;
            return portion;
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
        @notice set lp token address. 
     */
    function setLPTokenAddress(address _lpToken) external onlyOwner {
        lpToken = IERC20Upgradeable(_lpToken);
    }

    /**
        @notice approve Token lp token address. 
     */
    function approveToken(address _token, address _to) external onlyOwner {
        IERC20Upgradeable(_token).approve(address(_to), type(uint256).max);
    }

    /**
        @notice Release lp tokens to return KSP-sigKSP to depositor after their locking period.
     */
    function releaseLPToken(uint256 _amount) external onlyOwner {
        require(isLPTokensReleased == false, "LP Tokens are already released.");

        lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        isLPTokensReleased = true;
        totalLPTokenSupply = _amount;
        emit LPTokenReleased(block.timestamp, _amount);
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

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
}
