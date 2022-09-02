//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface ILpFarm {
    function deposited(uint256 _pid, address _user)
        external
        view
        returns (uint256);
}

contract LpFarmMiningRateHelperV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* ========== STATE VARIABLES ========== */

    struct Reward {
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 balance;
    }

    event RewardAdded(uint256 pid, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed stakingToken,
        uint256 reward
    );
    event RewardsDurationUpdated(uint256 newDuration);
    event UpdateReward(
        address indexed stakingToken,
        uint256 rewardPerTokenStored,
        address indexed user,
        uint256 earned,
        uint256 userRewardPerTokenPaid
    );

    // staking token address  -> user -> amount
    mapping(address => mapping(address => uint256))
        public userRewardPerTokenPaid;

    // staking token address -> user -> amount
    mapping(address => mapping(address => uint256)) public rewards;

    // pid -> staking token
    mapping(uint256 => address) public stakingTokens;
    IERC20Upgradeable public rewardToken;

    // staking token addrses -> Reward
    mapping(address => Reward) public rewardData;

    // Reward Duration
    uint256 public REWARDS_DURATION;

    // Total Pool Count
    uint256 public poolCount;

    // Total Reward Balance
    uint256 public totalRewardBalance;

    // LpFarm address
    ILpFarm public lpFarm;

    // Operator
    mapping(address => bool) public operators;

    /* ========== Restricted Function  ========== */

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
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

    /**
     @notice sets initialInfo of the contract.
     */
    function setInitialInfo(
        address _rewardToken,
        uint256 _rewardDuration,
        address _lpFarm
    ) external onlyOwner {
        rewardToken = IERC20Upgradeable(_rewardToken); // sigKSP
        REWARDS_DURATION = _rewardDuration;
        lpFarm = ILpFarm(_lpFarm);
    }

    /**
        @notice add pool
     */
    function addPool(address _poolAddress) external onlyOwner {
        stakingTokens[poolCount] = _poolAddress;
        poolCount++;
    }

    /**
        @notice set pool
     */
    function setPoolAddress(uint256 _pid, address _newPoolAddress)
        external
        onlyOwner
    {
        stakingTokens[_pid] = _newPoolAddress;
    }

    /**
     @notice [Update] V5 added function.
     @notice Set operator to run functions.
     @param _operators list of operator to give an authority.
     */
    function setOperator(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators[_operators[i]] = true;
        }
    }

    /**
     @notice [Update] V5 added function.
     @notice Revoke authority to run functions.
     @param _operator : operator to revoke permission from.
     */
    function revokeOperator(address _operator) external onlyOwner {
        require(operators[_operator], "This address is not an operator");
        operators[_operator] = false;
    }

    /**
     @notice update reward amount. 
     @dev only can be called from rewardDistribution contract. 
     */
    function updateRewardAmount(uint256 _pid)
        external
        onlyOperator
        updateReward(_pid, address(0))
    {
        address stakingToken = stakingTokens[_pid];
        Reward storage reward = rewardData[stakingToken];

        uint256 unseen = rewardToken.balanceOf(address(this)) -
            totalRewardBalance;
        if (unseen > 0) {
            _notifyRewardAmount(reward, unseen);
            emit RewardAdded(_pid, unseen);
        }
    }

    /**
     @notice set reward duration. 
     */
    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            _rewardsDuration > 0,
            "reward durationi should be longer than 0"
        );
        REWARDS_DURATION = _rewardsDuration;
        emit RewardsDurationUpdated(REWARDS_DURATION);
    }

    /* ========== External & Public Function  ========== */

    function claimReward(uint256 _pid, address _user)
        external
        nonReentrant
        whenNotPaused
        updateReward(_pid, _user)
        onlyLpFarm
    {
        address stakingToken = stakingTokens[_pid];
        Reward storage r = rewardData[stakingToken];
        uint256 reward = rewards[stakingToken][_user];
        if (reward > 0) {
            rewards[stakingToken][_user] = 0;
            r.balance -= reward;
            totalRewardBalance -= reward;
            IERC20Upgradeable(rewardToken).safeTransfer(_user, reward);
            emit RewardPaid(_user, stakingToken, reward);
        }
    }

    function updateUserReward(uint256 _pid, address _user) external onlyLpFarm {
        address stakingToken = stakingTokens[_pid];
        rewardData[stakingToken].rewardPerTokenStored = rewardPerToken(
            stakingToken
        );
        rewardData[stakingToken].lastUpdateTime = lastTimeRewardApplicable(
            stakingToken
        );
        if (_user != address(0)) {
            rewards[stakingToken][_user] = earned(_user, _pid);
            userRewardPerTokenPaid[stakingToken][_user] = rewardData[
                stakingToken
            ].rewardPerTokenStored;
            emit UpdateReward(
                stakingToken,
                rewardData[stakingToken].rewardPerTokenStored,
                _user,
                rewards[stakingToken][_user],
                userRewardPerTokenPaid[stakingToken][_user]
            );
        }
    }

    /* ========== Internal & Private Function  ========== */

    function _notifyRewardAmount(Reward storage r, uint256 reward) internal {
        if (block.timestamp >= r.periodFinish) {
            r.rewardRate = reward / REWARDS_DURATION;
        } else {
            uint256 remaining = r.periodFinish - block.timestamp;
            uint256 leftover = remaining * r.rewardRate;
            r.rewardRate = (reward + leftover) / REWARDS_DURATION;
        }
        r.lastUpdateTime = block.timestamp;
        r.periodFinish = block.timestamp + REWARDS_DURATION;
        r.balance += reward;
        totalRewardBalance += reward;
    }

    /* ========== View Function  ========== */

    function lastTimeRewardApplicable(address _stakingToken)
        public
        view
        returns (uint256)
    {
        uint256 periodFinish = rewardData[_stakingToken].periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
        @notice Calculate Reward per token. 
        @param _stakingToken address of staking token.
     */
    function rewardPerToken(address _stakingToken)
        public
        view
        returns (uint256)
    {
        uint256 totalDeposit = IERC20Upgradeable(_stakingToken).balanceOf(
            address(lpFarm)
        );
        if (totalDeposit == 0) {
            return rewardData[_stakingToken].rewardPerTokenStored;
        }
        uint256 duration = lastTimeRewardApplicable(_stakingToken) -
            rewardData[_stakingToken].lastUpdateTime;
        uint256 pending = (duration *
            rewardData[_stakingToken].rewardRate *
            1e18) / totalDeposit;
        return rewardData[_stakingToken].rewardPerTokenStored + pending;
    }

    function earned(address _user, uint256 _pid) public view returns (uint256) {
        address stakingToken = stakingTokens[_pid];
        uint256 rpt = rewardPerToken(stakingToken) -
            userRewardPerTokenPaid[stakingToken][_user];
        return
            (lpFarm.deposited(_pid, _user) * rpt) /
            1e18 +
            rewards[stakingToken][_user];
    }

    function getRewardForDuration(address _stakingToken)
        external
        view
        returns (uint256)
    {
        return rewardData[_stakingToken].rewardRate * REWARDS_DURATION;
    }

    /* ========== MODIFIERS ========== */

    /**
     @notice [Update] V5 added function.
     */
    modifier onlyOperator() {
        require(operators[msg.sender], "This address is not an operator");
        _;
    }

    modifier onlyLpFarm() {
        require(msg.sender == address(lpFarm), "Caller is not LpFarm.");
        _;
    }

    modifier updateReward(uint256 _pid, address _user) {
        address stakingToken = stakingTokens[_pid];
        rewardData[stakingToken].rewardPerTokenStored = rewardPerToken(
            stakingToken
        );
        rewardData[stakingToken].lastUpdateTime = lastTimeRewardApplicable(
            stakingToken
        );
        if (_user != address(0)) {
            rewards[stakingToken][_user] = earned(_user, _pid);
            userRewardPerTokenPaid[stakingToken][_user] = rewardData[
                stakingToken
            ].rewardPerTokenStored;
            emit UpdateReward(
                stakingToken,
                rewardData[stakingToken].rewardPerTokenStored,
                _user,
                rewards[stakingToken][_user],
                userRewardPerTokenPaid[stakingToken][_user]
            );
        }
        _;
    }
}
