//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../dependencies/Ownable.sol";
import "../dependencies/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Lockdrop is Ownable {
    using SafeERC20 for IERC20;
    /* ========== STATE VARIABLES ========== */
    IERC20 public SIG; // reward token.
    IERC20 public KSP; // deposit token
    IERC20 public lpToken; // KSP - sigKSP lp

    bool public isSIGTokensReleased;
    bool public isLPTokensReleased;

    uint256 public totalLPTokenSupply;
    uint256 public totalDeposit;
    uint256 public totalWeight; // weight = lockMonth * amount;
    address public receiver;
    uint256 public vestingPeriod;

    mapping(address => DepositInfo) public depositOf;

    struct DepositInfo {
        uint256 amount; // deposited KSP amount
        uint256 weight; // weight = lockMonth * amount
        uint256 lockMonth; // locked month
        uint256 claimedSIG; // released amount sig
        bool withdrewAtPhase2; // if it's withdrawn at phase 2
        bool isLPTokensClaimed;
    }

    uint256 public phase1StartTs;
    uint256 public phase2StartTs;
    uint256 public phase2EndTs;
    uint256 public immutable HOUR = 3600;
    uint256 public immutable TOTAL_SIG_SUPPLY = 2500000000000000000000000;

    uint256 public immutable LOCK_1_MONTHS = 2628000;
    uint256 public immutable LOCK_3_MONTHS = 7884000;
    uint256 public immutable LOCK_6_MONTHS = 15770000;
    uint256 public immutable LOCK_9_MONTHS = 23650000;
    uint256 public immutable LOCK_12_MONTHS = 31540000;

    mapping(uint256 => uint256) public multiplierOf; // Multipler of each lock month

    event InitialInfoSet(
        uint256 phase1StartTs,
        uint256 phase2StartTs,
        uint256 phase2EndTs,
        address receiver,
        uint256 vestingPeriod
    );

    event Deposit(address user, uint256 amount, uint256 lockMonth);
    event Withdrawal(address user, uint256 amount);
    event SIGTokenReleased(uint256 at, uint256 releasedTokenAmount);
    event LPTokenReleased(uint256 at, uint256 releasedTokenAmount);
    event AdminWithdraw(uint256 withdrawAmount);
    event SIGTokenClaimed(address user, uint256 amount);
    event LPTokenClaimed(address user, uint256 amount);

    constructor() {}

    /* ========== External & Public FUNCTIONS ========== */

    /**
        @notice Deposit KSP into this contract, only allowed during Phase1.
     */
    function deposit(uint256 _amount, uint256 _lockMonth) external {
        require(block.timestamp > phase1StartTs, "Phase 1 did not start yet.");
        require(
            block.timestamp < phase2StartTs,
            "Deposit period is already ended"
        );
        require(_amount > 0, "Amount should be bigger than 0");
        require(
            _lockMonth == LOCK_1_MONTHS ||
                _lockMonth == LOCK_3_MONTHS ||
                _lockMonth == LOCK_6_MONTHS ||
                _lockMonth == LOCK_9_MONTHS ||
                _lockMonth == LOCK_12_MONTHS,
            "Lock Month must be one of 1,3,6,9 or 12 months."
        );
        //Transfer KSP
        KSP.safeTransferFrom(msg.sender, address(this), _amount);
        // Update User KSP Deposit Balance
        DepositInfo storage userDeposit = depositOf[msg.sender];

        // Update Weight
        if (userDeposit.amount == 0) {
            userDeposit.weight = (_amount * multiplierOf[_lockMonth]) / 1e5;
            totalWeight += userDeposit.weight;
        } else {
            uint256 newWeight = ((userDeposit.amount + _amount) *
                multiplierOf[_lockMonth]) / 1e5;
            totalWeight = totalWeight - userDeposit.weight + newWeight;
            userDeposit.weight = newWeight;
        }

        userDeposit.amount += _amount;
        userDeposit.lockMonth = _lockMonth;
        // Update Total Deposit
        totalDeposit += _amount;

        emit Deposit(msg.sender, _amount, _lockMonth);
    }

    /**
        @notice User can change _lockMonth at Phase 1,2.
     */

    function setLockMonth(uint256 _lockMonth) external {
        require(block.timestamp > phase1StartTs, "Phase 1 did not start yet.");
        require(
            block.timestamp < phase2EndTs,
            "Phase2 is already done. You can't change lock month anymore"
        );
        require(
            _lockMonth == LOCK_1_MONTHS ||
                _lockMonth == LOCK_3_MONTHS ||
                _lockMonth == LOCK_6_MONTHS ||
                _lockMonth == LOCK_9_MONTHS ||
                _lockMonth == LOCK_12_MONTHS,
            "Lock Month must be one of 1,3,6,9 or 12 months."
        );
        DepositInfo storage userDeposit = depositOf[msg.sender];
        require(
            userDeposit.amount > 0,
            "No funds available to change lock month"
        );

        userDeposit.lockMonth = _lockMonth;

        // Update Weight
        uint256 newWeight = (userDeposit.amount * multiplierOf[_lockMonth]) /
            1e5;
        totalWeight = totalWeight - userDeposit.weight + newWeight;
        userDeposit.weight = newWeight;
    }

    /**
        @notice Withdraw KSP from this contract, allowed during Phase1(many times) and Phase2(only one time).
     */
    function withdraw(uint256 _requiredAmount) external {
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

        // Update Weight
        if (userDeposit.amount == 0) {
            totalWeight -= userDeposit.weight;
            userDeposit.lockMonth = 0;
            userDeposit.weight = 0;
        } else {
            uint256 newWeight = ((userDeposit.amount) *
                multiplierOf[userDeposit.lockMonth]) / 1e5;
            totalWeight = totalWeight - userDeposit.weight + newWeight;
            userDeposit.weight = newWeight;
        }

        totalDeposit -= _requiredAmount;

        KSP.transfer(msg.sender, _requiredAmount);
        emit Withdrawal(msg.sender, _requiredAmount);
    }

    /**
        @notice Withdraw pro-rata allocated SIG tokens, in vested manner. 
    */
    function claimSIGTokens() external {
        require(
            block.timestamp > phase2EndTs,
            "You can't withdraw tokens before phase 2 ends."
        );
        require(isSIGTokensReleased, "Sig Token is not released yet");
        DepositInfo storage userDeposit = depositOf[msg.sender];
        require(
            userDeposit.amount > 0 && userDeposit.weight > 0,
            "No funds available to withdraw token"
        );

        uint256 portion = _getWithdrawableTokenPortion(
            userDeposit.weight,
            totalWeight
        );

        uint256 amount = (portion * TOTAL_SIG_SUPPLY) / 1e18;
        require(amount != 0, "No withdrawable Token.");

        // vesting 기간에 맞춰서 주어야함.
        uint256 claimable = userTotalVestedSIGAmount(amount, block.timestamp) -
            userDeposit.claimedSIG;

        userDeposit.claimedSIG += claimable;
        SIG.safeTransfer(msg.sender, claimable);
        emit SIGTokenClaimed(msg.sender, claimable);
    }

    /**
        @notice Withdraw pro-rata allocated SIG tokens, in vested manner. 
    */
    function withdrawLPTokens() external {
        require(
            block.timestamp > phase2EndTs,
            "You can't withdraw tokens before phase 2 ends."
        );
        require(isLPTokensReleased, "LP Token should be released first.");
        DepositInfo storage userDeposit = depositOf[msg.sender];
        require(
            phase2EndTs + userDeposit.lockMonth < block.timestamp,
            "Lock period did not ended yet."
        );
        require(!userDeposit.isLPTokensClaimed, "You already claimed LPToken.");

        uint256 portion = _getWithdrawableTokenPortion(
            userDeposit.amount,
            totalDeposit
        );

        uint256 amount = (portion * totalLPTokenSupply) / 1e18;
        require(amount != 0, "No withdrawable Token.");

        userDeposit.isLPTokensClaimed = true;
        lpToken.safeTransfer(msg.sender, amount);
        emit LPTokenClaimed(msg.sender, amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getWithdrawableKSPAmount() external view returns (uint256) {
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

            uint256 currentSlot = (phase2EndTs - block.timestamp) / HOUR;
            uint256 totalSlot = (phase2EndTs - phase2StartTs) / HOUR;
            uint256 withdrawablePortion = _getWithdrawablePortion(
                currentSlot,
                totalSlot
            );
            return (userDeposit.amount * withdrawablePortion) / 1e18;
        }
    }

    function getWithdrawableLPTokenAmount() external view returns (uint256) {
        DepositInfo memory userDeposit = depositOf[msg.sender];
        if (
            userDeposit.amount == 0 ||
            userDeposit.isLPTokensClaimed ||
            !isLPTokensReleased
        ) {
            return 0;
        }
        uint256 portion = _getWithdrawableTokenPortion(
            userDeposit.amount,
            totalDeposit
        );
        uint256 amount = (portion * TOTAL_SIG_SUPPLY) / 1e18;
        return amount;
    }

    /**
     @notice Get user's total allocated Sig amount.
     */
    function userTotalAllocatedSIGToken(address _addr)
        external
        view
        returns (uint256)
    {
        DepositInfo storage userDeposit = depositOf[_addr];

        if (userDeposit.amount == 0) {
            return 0;
        } else {
            uint256 portion = _getWithdrawableTokenPortion(
                userDeposit.weight,
                totalWeight
            );

            return (portion * TOTAL_SIG_SUPPLY) / 1e18;
        }
    }

    /**
     @notice Estimate SIG Token allocation for given ksp token amount.
     */
    function estimateTotalAllocatedSIGToken(uint256 _amount, uint256 _lockMonth)
        external
        view
        returns (uint256)
    {
        require(_amount > 0, "Amount should be bigger than 0");
        require(
            _lockMonth == LOCK_1_MONTHS ||
                _lockMonth == LOCK_3_MONTHS ||
                _lockMonth == LOCK_6_MONTHS ||
                _lockMonth == LOCK_9_MONTHS ||
                _lockMonth == LOCK_12_MONTHS,
            "Lock Month must be one of 1,3,6,9 or 12 months."
        );

        uint256 weight = (_amount * multiplierOf[_lockMonth]) / 1e5;
        uint256 portion = _getWithdrawableTokenPortion(weight, totalWeight);

        return (portion * TOTAL_SIG_SUPPLY) / 1e18;
    }

    /**
     @notice Get user's claimable Sig amount.
     */
    function userClaimableSIGAmount(address _addr)
        external
        view
        returns (uint256)
    {
        DepositInfo memory userDeposit = depositOf[_addr];

        if (userDeposit.amount > 0 && userDeposit.weight > 0) {
            uint256 portion = _getWithdrawableTokenPortion(
                userDeposit.weight,
                totalWeight
            );

            uint256 amount = (portion * TOTAL_SIG_SUPPLY) / 1e18;
            require(amount != 0, "No withdrawable Token.");

            // vesting 기간에 맞춰서 주어야함.
            return
                userTotalVestedSIGAmount(amount, block.timestamp) -
                userDeposit.claimedSIG;
        } else {
            return 0;
        }
    }

    /** 
     @notice Get user's total claimed amount.
    */
    function userTotalClaimedSIGAmount(address _addr)
        external
        view
        returns (uint256)
    {
        return depositOf[_addr].claimedSIG;
    }

    /** 
     @notice Get user's vested amount.
    */
    function userTotalVestedSIGAmount(
        uint256 totalAllocation,
        uint256 timestamp
    ) public view returns (uint256) {
        if (timestamp < phase2EndTs) {
            return 0;
        } else if (timestamp > phase2EndTs + vestingPeriod) {
            return totalAllocation;
        } else {
            return
                (totalAllocation * (timestamp - phase2EndTs)) / vestingPeriod;
        }
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
        if (_totalDepositAmount == 0) {
            return 1e18;
        } else {
            uint256 portion = (_depositAmount * 1e18) / _totalDepositAmount;
            return portion;
        }
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
        address _KSP,
        address _lpToken,
        address _receiver,
        uint256 _vestingPeriod
    ) external onlyOwner {
        require(
            block.timestamp < _phase1StartTs,
            "Phase1 should start in the future."
        );
        require(
            _phase1StartTs < _phase2StartTs,
            "Phase2 should start after phase1"
        );
        require(
            _phase2StartTs < _phase2EndTs,
            "phase2StartTs should smaller than phase2EndTs"
        );
        require(
            (_phase2EndTs - _phase2StartTs) > HOUR,
            "Phase2 should be longer than 1 hour."
        );
        require(_vestingPeriod > 0, "Vesting period should be bigger than 0");
        require(_receiver != address(0), "Invalid receiver address");
        phase1StartTs = _phase1StartTs;
        phase2StartTs = _phase2StartTs;
        phase2EndTs = _phase2EndTs;
        SIG = IERC20(_SIG);
        KSP = IERC20(_KSP);
        lpToken = IERC20(_lpToken);
        receiver = _receiver;
        vestingPeriod = _vestingPeriod;

        multiplierOf[LOCK_1_MONTHS] = 8 * 1e4; // 0.8x
        multiplierOf[LOCK_3_MONTHS] = 27 * 1e4; // 2.7x
        multiplierOf[LOCK_6_MONTHS] = 6 * 1e5; // 6x
        multiplierOf[LOCK_9_MONTHS] = 11 * 1e5; // 11x
        multiplierOf[LOCK_12_MONTHS] = 22 * 1e5; // 18x

        emit InitialInfoSet(
            phase1StartTs,
            phase2StartTs,
            phase2EndTs,
            _receiver,
            vestingPeriod
        );
    }

    /**
        @notice Withdraw the contract's KSP balance at the end of the launch.
     */
    function adminWithdraw() external onlyOwner {
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to withdraw KSP Tokens."
        );
        uint256 balanceOfKSP = KSP.balanceOf(address(this));
        require(balanceOfKSP > 0, "There is no withdrawable amount of KSP");
        KSP.transfer(receiver, balanceOfKSP);
        emit AdminWithdraw(balanceOfKSP);
    }

    /**
        @notice Withdraw the contract's ERC20 Token from klayswap. 
     */
    function adminRewardTokenWithdraw(address _token) external onlyOwner {
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to withdraw KSP Tokens."
        );
        uint256 balanceOfToken = IERC20(_token).balanceOf(address(this));
        require(balanceOfToken > 0, "There is no withdrawable amount of KSP");
        IERC20(_token).transfer(receiver, balanceOfToken);
        emit AdminWithdraw(balanceOfToken);
    }

    /**
        @notice Release SIG token for depositer.
     */
    function releaseSIGToken() external onlyOwner {
        require(isSIGTokensReleased == false, "Tokens are already released.");
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to release SIG Tokens."
        );
        SIG.safeTransferFrom(msg.sender, address(this), TOTAL_SIG_SUPPLY);
        isSIGTokensReleased = true;
        emit SIGTokenReleased(block.timestamp, TOTAL_SIG_SUPPLY);
    }

    /**
        @notice Change KSP receiver address
     */
    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Invalid receiver address");
        receiver = _receiver;
    }

    /**
        @notice Release lp tokens to return KSP-sigKSP to depositor after their locking period.
     */
    function releaseLPToken(uint256 _amount) external onlyOwner {
        require(isLPTokensReleased == false, "LP Tokens are already released.");
        require(
            block.timestamp > phase2EndTs,
            "Phase 2 should end to release LP Tokens."
        );
        lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        isLPTokensReleased = true;
        totalLPTokenSupply = _amount;
        emit LPTokenReleased(block.timestamp, _amount);
    }
}
