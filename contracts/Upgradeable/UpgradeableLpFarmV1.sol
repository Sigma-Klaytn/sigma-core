// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "../interfaces/sigma/IvxERC20.sol";

// Farm distributes the sig rewards based on staked LP to each user.
//
// Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by LTO Network to work for non-mintable sig.
// Modified by Sigma to work for boosted rewards with vxSIG.
contract LpFarm is Ownable {
    using SafeERC20 for IERC20;

    IvxERC20 public vxSIG;

    /// @notice variable name with prefix "boost" means that's related to boost reward. Others are related to base reward.

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 boostRewardDebt; // Boosted Reward debt
        uint256 boostWeight;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 lastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 boostAllocPoint; // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 boostLastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 boostAccERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 totalBoostWeight; // Total boost weight of the pool
    }

    // Address of the sig Token contract.
    IERC20 public sig;
    // The total amount of SIG that's paid out as base reward.
    uint256 public paidOut = 0;
    // sig tokens rewarded per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    /// @notice Reward per block will be divided by totalAllocPoint
    uint256 public totalAllocPoint = 0; // boostTotalAllocPoint + baseTotalAllocPoint

    uint256 public boostTotalAllocPoint = 0;
    uint256 public baseTotalAllocPoint = 0;

    // The block number when farming starts.
    uint256 public startBlock;
    // The block number when farming ends.
    uint256 public endBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed lpToken, uint256 indexed pid);
    event Funded(address indexed from, uint256 amount, uint256 newEndBlock);

    /* ========== External & Public Function  ========== */

    /**
      @notice deposit lp token in the pool
      @param _pid pool Id
      @param _amount amount of the lp token to deposit
     */
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) /
                1e36) - user.rewardDebt;
            erc20Transfer(msg.sender, pendingAmount);

            //if user has boost,
            if (user.boostWeight > 0) {
                uint256 boostPendingaAmount = (user.boostWeight *
                    pool.boostAccERC20PerShare) /
                    1e36 -
                    user.boostRewardDebt;
                erc20Transfer(msg.sender, boostPendingaAmount);
            }
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount += _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;
        }

        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
      @notice withdraw lp token and gets pending token.
      @param _pid pool Id
      @param _amount amount of the lp token to withdraw
     */
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            user.amount >= _amount,
            "withdraw: can't withdraw more than deposit"
        );
        updatePool(_pid);

        uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) / 1e36) -
            user.rewardDebt;

        //if user has boost,
        if (user.boostWeight > 0) {
            uint256 boostPendingAmount = (user.boostWeight *
                pool.boostAccERC20PerShare) /
                1e36 -
                user.boostRewardDebt;
            pendingAmount += boostPendingAmount;
        }

        erc20Transfer(msg.sender, pendingAmount);

        user.amount -= _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;

            updateBoostWeightToPool(_pid);
        }

        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /**
      @notice claim pending rewards on the pool
      @param _pid pool id 
     */
    function claim(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "User didn't deposit in this pool.");
        uint256 pendingAmount = basePending(_pid, msg.sender);
        if (user.boostWeight > 0) {
            pendingAmount += boostPending(_pid, msg.sender);
        }
        require(pendingAmount > 0, "claim: no rewards to claim");
        updatePool(_pid);
        erc20Transfer(msg.sender, pendingAmount);

        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;
        }
        emit Claim(msg.sender, _pid, pendingAmount);
    }

    /**
      @notice update boost weight of the user. 
      @notice This will be called from xSIGFarm if user activate boost.
     */
    function updateBoostWeight() external {
        for (uint256 i = 0; i < poolInfo.length; i++) {
            UserInfo storage user = userInfo[i][msg.sender];
            //0. if user has amount
            if (user.amount > 0) {
                _updateBoostWeight(msg.sender, i);
            }
        }
    }

    function updateBoostWeightToPool(uint256 _pid) public {
        // user's amount can be zero
        _updateBoostWeight(msg.sender, _pid);
    }

    /**
      @notice update pool both with base,boost
     */
    function updatePool(uint256 _pid) public {
        _updatePoolWithBaseReward(_pid);
        _updatePoolWithBoostReward(_pid);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
      @notice Fund the farm, anyone call fund sig token.
      @param _amount amount of the token to fund.
     */
    function fund(uint256 _amount) public {
        require(block.number < endBlock, "fund: too late, the farm is closed");
        require(_amount > 0, "Funding amount should be bigger than 0");

        sig.safeTransferFrom(address(msg.sender), address(this), _amount);
        endBlock += _amount / rewardPerBlock;

        emit Funded(msg.sender, _amount, endBlock);
    }

    /* ========== Restricted Function  ========== */
    /**
     @notice sets initialInfo of the contract.
     */
    function setInitialInfo(
        IERC20 _sig,
        IvxERC20 _vxSIG,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) external onlyOwner {
        require(
            _startBlock > block.number,
            "Start block should be in the future"
        );
        sig = _sig;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock;
        vxSIG = _vxSIG;
    }

    /**
      @notice Add a new lp to the pool. Can only be called by the owner.
      @notice DO NOT add the same LP token more than once. Rewards will be messed up if you do.
      @param _allocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function addPool(
        uint256 _allocPoint,
        uint256 _boostAllocPoint,
        IERC20 _lpToken
    ) public onlyOwner {
        massUpdatePools();

        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        baseTotalAllocPoint += _allocPoint;
        boostTotalAllocPoint += _boostAllocPoint;
        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accERC20PerShare: 0,
                boostAllocPoint: _boostAllocPoint,
                boostLastRewardBlock: lastRewardBlock,
                boostAccERC20PerShare: 0,
                totalBoostWeight: 0
            })
        );

        emit PoolAdded(address(_lpToken), poolInfo.length - 1);
    }

    /**
      @notice Update the given pool's sig allocation point. Can only be called by the owner.
      @param _pid pool Id
      @param _allocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function setPool(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _boostAllocPoint
    ) public onlyOwner {
        massUpdatePools();
        baseTotalAllocPoint =
            baseTotalAllocPoint -
            poolInfo[_pid].allocPoint +
            _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        boostTotalAllocPoint =
            boostTotalAllocPoint -
            poolInfo[_pid].boostAllocPoint +
            _boostAllocPoint;
        poolInfo[_pid].boostAllocPoint = _boostAllocPoint;

        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;
    }

    /**
     @notice set rewardPerBlock. It will change endblock as well.
     */
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(
            _rewardPerBlock > 0,
            "reward per block should be bigger than 0"
        );
        rewardPerBlock = _rewardPerBlock;
        uint256 sigBalance = sig.balanceOf(address(this));
        endBlock = sigBalance / rewardPerBlock;
    }

    /* ========== Internal & Private Function  ========== */

    /**
      @notice update boost weight of all existing pool
      @param _addr address of the user
      @param _pid pool id 
     */
    function _updateBoostWeight(address _addr, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _updatePoolWithBoostReward(_pid);

        uint256 vxAmount = vxSIG.balanceOf(_addr);
        uint256 oldBoostWeight = user.boostWeight;

        uint256 newBoostWeight = _sqrt(user.amount * vxAmount);
        user.boostWeight = newBoostWeight;
        pool.totalBoostWeight =
            pool.totalBoostWeight -
            oldBoostWeight +
            newBoostWeight;
    }

    /**
      @notice send _amount amount of sig to _to & add up paidOut
      @param _to receiver of the token
      @param _amount amount of the sig token to send 
     */
    function erc20Transfer(address _to, uint256 _amount) internal {
        sig.transfer(_to, _amount);
        paidOut += _amount;
    }

    /**
      @notice update base reward variable of the pool
      @param _pid pool Id
     */
    function _updatePoolWithBaseReward(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock - (pool.lastRewardBlock);

        uint256 erc20Reward = (nrOfBlocks *
            (rewardPerBlock) *
            (pool.allocPoint)) / (totalAllocPoint);

        pool.accERC20PerShare =
            pool.accERC20PerShare +
            (erc20Reward * 1e36) /
            lpSupply;
        pool.lastRewardBlock = block.number;
    }

    /**
      @notice update boost reward variable of the pool
      @param _pid pool Id
     */
    function _updatePoolWithBoostReward(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= pool.boostLastRewardBlock) {
            return;
        }
        uint256 totalBoostWeight = pool.totalBoostWeight;
        if (totalBoostWeight == 0) {
            pool.boostLastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock - (pool.boostLastRewardBlock);

        uint256 erc20Reward = (nrOfBlocks *
            rewardPerBlock *
            pool.boostAllocPoint) / (totalAllocPoint);

        pool.boostAccERC20PerShare =
            pool.boostAccERC20PerShare +
            ((erc20Reward * 1e36) / totalBoostWeight);
        pool.boostLastRewardBlock = block.number;
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /* ========== View Function  ========== */

    /**
     @notice total pending amount on protocol.
     */
    function totalPending() external view returns (uint256) {
        if (block.number <= startBlock) {
            return 0;
        }

        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
        return (rewardPerBlock * (lastBlock - startBlock)) - paidOut;
    }

    /**
     @notice get pool length
     */
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     @notice pending amount with base reward.
     */
    function basePending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return 0;
        }
        uint256 accERC20PerShare = pool.accERC20PerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (
            lastBlock > pool.lastRewardBlock &&
            block.number > pool.lastRewardBlock &&
            lpSupply != 0
        ) {
            uint256 nrOfBlocks = lastBlock - pool.lastRewardBlock;
            uint256 erc20Reward = (nrOfBlocks *
                (rewardPerBlock) *
                (pool.allocPoint)) / (totalAllocPoint);
            accERC20PerShare =
                accERC20PerShare +
                ((erc20Reward * 1e36) / lpSupply);
        }

        return ((user.amount * accERC20PerShare) / 1e36) - user.rewardDebt;
    }

    /**
     @notice pending amount with boost reward.
     */
    function boostPending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];

        if (user.boostWeight == 0) {
            return 0;
        }
        uint256 boostAccERC20PerShare = pool.boostAccERC20PerShare;
        uint256 totalBoostWeight = pool.totalBoostWeight;
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (
            lastBlock > pool.boostLastRewardBlock &&
            block.number > pool.boostLastRewardBlock &&
            totalBoostWeight != 0
        ) {
            uint256 nrOfBlocks = lastBlock - (pool.boostLastRewardBlock);

            uint256 erc20Reward = (nrOfBlocks *
                rewardPerBlock *
                pool.boostAllocPoint) / (totalAllocPoint);

            boostAccERC20PerShare =
                boostAccERC20PerShare +
                (erc20Reward * 1e36) /
                totalBoostWeight;
        }

        return
            (user.boostWeight * boostAccERC20PerShare) /
            1e36 -
            user.boostRewardDebt;
    }

    /**
     @notice deposited amount of the lp.
     */
    function deposited(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_pid][_user];
        return user.amount;
    }
}
