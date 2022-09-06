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

// [Update] V2 appended interface
interface IFeeDistributor {
    function depositERC20(address _token, uint256 _amount) external;
}

// [Update] V2 appended interface
interface IKlayswapSinglePool {
    function claimReward() external;
}

contract LockdropLpFarmProxyV2 is
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

    /// @notice [Update] V2 appended value
    mapping(address => bool) public operators;
    IFeeDistributor public feeDistributor;

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
        address _lpFarm,
        uint256 _totalLockdropDeposit
    ) external onlyOwner {
        lpToken = IERC20Upgradeable(_lpToken);
        lockdrop = ILockdrop(_lockdrop);
        lpFarm = ILpFarm(_lpFarm);
        // totalLockdropDeposit = 227100212865627939698517;
        totalLockdropDeposit = _totalLockdropDeposit;

        lpToken.approve(_lpFarm, type(uint256).max);
    }

    /**
     @notice [Update] V2 added function.
     @notice sets feeDistributor Address of the contract.
     */
    function setFeeDistributor(address _feeDistributor) external onlyOwner {
        feeDistributor = IFeeDistributor(_feeDistributor);
        //Approve KSP to fee distributor
        IERC20Upgradeable(0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654).approve(
            address(_feeDistributor),
            type(uint256).max
        );
    }

    /**
     @notice [Update] V2 added function.
     @notice Set operator to run functions.
     @param _operators list of operator to give an authority.
     */
    function setOperator(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators[_operators[i]] = true;
        }
    }

    /**
     @notice [Update] V2 added function.
     @notice Revoke authority to run functions.
     @param _operator : operator to revoke permission from.
     */
    function revokeOperator(address _operator) external onlyOwner {
        require(operators[_operator], "This address is not an operator");
        operators[_operator] = false;
    }

    /**
        @notice [Update] V2 appended function
     */
    function claimMiningRewardAndForward()
        external
        onlyOperator
        whenNotPaused
        nonReentrant
    {
        IKlayswapSinglePool(address(lpToken)).claimReward();
        IERC20Upgradeable ksp = IERC20Upgradeable(
            0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654
        );

        uint256 kspAmountToForward = ksp.balanceOf(address(this));

        if (kspAmountToForward > 0) {
            feeDistributor.depositERC20(address(ksp), kspAmountToForward);
        }
    }

    /* ========== External & Public FUNCTIONS ========== */

    /**
        @notice forward lp token to lpfarm
     */

    function forwardLpTokenToLpFarm() external {
        require(!isForwarded[msg.sender], "already forwarded");

        uint256 withdrawableLpToken = getWithdrawableLPTokenAmount();
        require(withdrawableLpToken > 0, "No withdrawable Lp Token");
        (
            uint256 amount, // deposited KSP amount
            uint256 weight, // weight = lockMonth * amount
            uint256 lockMonth, // locked month
            uint256 claimedSIG, // released amount sig
            bool withdrewAtPhase2, // if it's withdrawn at phase 2
            bool isLPTokensClaimed
        ) = lockdrop.depositOf(msg.sender);

        lpFarm.forwardLpTokensFromLockdrop(
            msg.sender,
            withdrawableLpToken,
            lockMonth
        );

        isForwarded[msg.sender] = true;
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

    /**
     @notice [Update] V5 added function.
     */
    modifier onlyOperator() {
        require(operators[msg.sender], "This address is not an operator");
        _;
    }
}
