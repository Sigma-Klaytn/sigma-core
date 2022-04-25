//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "./dependencies/SafeERC20.sol";
import "./interfaces/sigma/ISigKSPStaking.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract SigKSPStaking is Ownable, ReentrancyGuard, Pausable, ISigKSPStaking {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    struct Reward {
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 balance;
    }
    IERC20 public stakingToken;
    address[2] public rewardTokens;
    mapping(address => Reward) public rewardData;

    address public rewardsDistribution;

    // user -> reward token -> amount
    mapping(address => mapping(address => uint256))
        public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) public rewards;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public REWARDS_DURATION = 86400 * 7;

    event RewardAdded(address indexed rewardsToken, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed rewardsToken,
        uint256 reward
    );
    event RewardsDurationUpdated(uint256 newDuration);
    //TODO: Need to be deleted
    event UpdateReward(
        address rewardToken,
        uint256 rewardPerTokenStored,
        address user,
        uint256 earned,
        uint256 userRewardPerTokenPaid
    );

    function lastTimeRewardApplicable(address _rewardsToken)
        public
        view
        returns (uint256)
    {
        uint256 periodFinish = rewardData[_rewardsToken].periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /**
        @notice Calculate Reward per token. 
        @param _rewardsToken address of reward token.
     */
    function rewardPerToken(address _rewardsToken)
        public
        view
        returns (uint256)
    {
        if (totalSupply == 0) {
            return rewardData[_rewardsToken].rewardPerTokenStored;
        }
        uint256 duration = lastTimeRewardApplicable(_rewardsToken) -
            rewardData[_rewardsToken].lastUpdateTime;
        uint256 pending = (duration *
            rewardData[_rewardsToken].rewardRate *
            1e18) / totalSupply; //1e18 is for preventing rounding error
        return rewardData[_rewardsToken].rewardPerTokenStored + pending;
    }

    function earned(address account, address _rewardsToken)
        public
        view
        returns (uint256)
    {
        uint256 rpt = rewardPerToken(_rewardsToken) -
            userRewardPerTokenPaid[account][_rewardsToken];
        return
            (balanceOf[account] * rpt) / 1e18 + rewards[account][_rewardsToken];
    }

    function getRewardForDuration(address _rewardsToken)
        external
        view
        returns (uint256)
    {
        return rewardData[_rewardsToken].rewardRate * REWARDS_DURATION;
    }

    function stake(uint256 amount)
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot stake 0");
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        for (uint256 i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            Reward storage r = rewardData[token];
            // reward 업데이트가 지금으로부터 한 시간 전 보다 더되었으면 새로운 리워드가 있는지 확인을 해라.
            if (block.timestamp + REWARDS_DURATION > r.periodFinish + 3600) {
                uint256 unseen = IERC20(token).balanceOf(address(this)) -
                    r.balance;
                if (unseen > 0) {
                    _notifyRewardAmount(r, unseen);
                    emit RewardAdded(token, unseen);
                }
            }
            uint256 reward = rewards[msg.sender][token];
            if (reward > 0) {
                rewards[msg.sender][token] = 0;
                r.balance -= reward;
                IERC20(token).safeTransfer(msg.sender, reward);
                emit RewardPaid(msg.sender, token, reward);
            }
        }
    }

    function exit() external {
        withdraw(balanceOf[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setAddresses(
        address _stakingToken,
        address[2] memory _rewardTokens
    ) external onlyOwner {
        stakingToken = IERC20(_stakingToken); // sigKSP
        rewardTokens = _rewardTokens; // KSP, SIG
    }

    function updateRewardAmount()
        external
        override
        onlyRewardsDistribution
        updateReward(address(0))
    {
        for (uint256 i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            Reward storage r = rewardData[token];
            uint256 unseen = IERC20(token).balanceOf(address(this)) - r.balance;
            if (unseen > 0) {
                _notifyRewardAmount(r, unseen);
                emit RewardAdded(token, unseen);
            }
        }
    }

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
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        for (uint256 i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            Reward storage r = rewardData[token];

            require(
                block.timestamp > r.periodFinish,
                "Previous rewards period must be complete before changing the duration for the new period"
            );
        }
        REWARDS_DURATION = _rewardsDuration;
        emit RewardsDurationUpdated(REWARDS_DURATION);
    }

    function setRewardsDistribution(address _rewardsDistribution)
        external
        onlyOwner
    {
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyRewardsDistribution() {
        require(
            msg.sender == rewardsDistribution,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }
    modifier updateReward(address account) {
        for (uint256 i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            rewardData[token].rewardPerTokenStored = rewardPerToken(token);
            rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
            if (account != address(0)) {
                rewards[account][token] = earned(account, token);
                userRewardPerTokenPaid[account][token] = rewardData[token]
                    .rewardPerTokenStored;
                emit UpdateReward(
                    token,
                    rewardData[token].rewardPerTokenStored,
                    msg.sender,
                    rewards[account][token],
                    userRewardPerTokenPaid[account][token]
                );
            }
        }
        _;
    }
}
