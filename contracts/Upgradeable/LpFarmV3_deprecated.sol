// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

interface ILpFarm {
    function updateBoostWeight(address _user) external;

    function forwardLpTokensFromLockdrop(
        address _user,
        uint256 _amount,
        uint256 _lockingPeriod
    ) external;
}

// Farm distributes the sig rewards based on staked LP to each user.
//
// Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by LTO Network to work for non-mintable sig.
// Modified by Sigma to work for boosted rewards with vxSIG.
/// @notice variable name with prefix "boost" means that's related to boost reward. Others are related to base reward.
/// @notice LpFarmV3 is different from LpFarmV1 in a way that new features for handling Lockdrop forwarded Lp tokens.
/// changed Few variables added, UserInfo struct, few functions added.
contract LpFarmV3 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    ILpFarm
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided. (including lockdrop)
        uint256 rewardDebt; // Reward debt.
        uint256 boostRewardDebt; // Boosted Reward debt
        uint256 boostWeight;
        uint256 lockdropAmount; // How many lockdrop amount among amount.
        uint256 lockingPeriod;
        bool isLockdropLPTokenClaimed;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this base pool. ERC20s to distribute per block.
        uint256 lastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 boostAllocPoint; // How many allocation points assigned to this boost pool. ERC20s to distribute per block.
        uint256 boostLastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 boostAccERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 totalBoostWeight; // Total boost weight of the pool
    }

    /// @notice Address of the vxSIG Token contract.
    IvxERC20 public vxSIG;
    /// @notice Address of the sig Token contract.
    IERC20Upgradeable public sig;
    /// @notice The total amount of SIG that's paid out as base reward.
    uint256 public paidOut;
    /// @notice sig tokens rewarded per block.
    uint256 public rewardPerBlock;

    /// @notice Info of each pool.
    PoolInfo[] public poolInfo;
    /// @notice Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    /// @notice Reward per block will be divided by totalAllocPoint
    uint256 public totalAllocPoint; // boostTotalAllocPoint + baseTotalAllocPoint
    /// @notice Total alloc point for boost pool.
    uint256 public boostTotalAllocPoint;
    /// @notice Total alloc point for base pool.
    uint256 public baseTotalAllocPoint;

    /// @notice The block number when farming starts.
    uint256 public startBlock;
    /// @notice The block number when farming ends.
    uint256 public endBlock;

    /// @notice address of lockdrop proxy
    address public lockdropProxy;
    /// @notice Timestamp when lockdrop eneded.
    uint256 public constant LOCKDROP_ENDTIME = 1654527600;
    /// @notice pool index of sigKSP - KSP
    uint256 public constant LOCKDROP_POOL_INDEX = 1;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed lpToken, uint256 indexed pid);
    event Funded(address indexed from, uint256 amount, uint256 newEndBlock);
    event PoolSet(
        uint256 pid,
        uint256 totalAlloc,
        uint256 baseTotalAlloc,
        uint256 boostTotalAlloc
    );
    event RewardPerBlockSet(uint256 rewardPerBlock, uint256 endBlock);
    event InitialInfoSet(
        uint256 rewardPerBlock,
        uint256 startBlock,
        uint256 endBlock
    );
    event WithdrawLockdropLP(address indexed user, uint256 amount);
    event LockdropDeposit(address indexed user, uint256 amount);

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
     @notice sets initialInfo of the contract.
     */
    function setInitialInfo(
        IERC20Upgradeable _sig,
        IvxERC20 _vxSIG,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) external onlyOwner {
        sig = _sig;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock;
        vxSIG = _vxSIG;

        emit InitialInfoSet(rewardPerBlock, startBlock, endBlock);
    }

    /**
     @notice sets vxSIG Address of the contract.
     */
    function setVxSIGAddress(IvxERC20 _vxSIG) external onlyOwner {
        vxSIG = _vxSIG;
    }

    /**
     @notice sets vxSIG Address of the contract.
     */
    function setLockdropProxy(address _lockdropProxy) external onlyOwner {
        lockdropProxy = _lockdropProxy;
    }

    /**
      @notice Add a new lp to the pool. Can only be called by the owner.
      @notice DO NOT add the same LP token more than once. Rewards will be messed up if you do.
      @param _baseAllocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function addPool(
        uint256 _baseAllocPoint,
        uint256 _boostAllocPoint,
        IERC20Upgradeable _lpToken
    ) external onlyOwner {
        _massUpdatePools();
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        baseTotalAllocPoint += _baseAllocPoint;
        boostTotalAllocPoint += _boostAllocPoint;
        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _baseAllocPoint,
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
      @param _baseAllocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function setPool(
        uint256 _pid,
        uint256 _baseAllocPoint,
        uint256 _boostAllocPoint
    ) external onlyOwner {
        _massUpdatePools();
        baseTotalAllocPoint =
            baseTotalAllocPoint -
            poolInfo[_pid].allocPoint +
            _baseAllocPoint;
        poolInfo[_pid].allocPoint = _baseAllocPoint;

        boostTotalAllocPoint =
            boostTotalAllocPoint -
            poolInfo[_pid].boostAllocPoint +
            _boostAllocPoint;
        poolInfo[_pid].boostAllocPoint = _boostAllocPoint;

        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;

        emit PoolSet(
            _pid,
            totalAllocPoint,
            baseTotalAllocPoint,
            boostTotalAllocPoint
        );
    }

    /**
      @notice Update the given pool's lp token address.
      @param _pid pool Id
      @param _address change address of the pool
     */
    function setPoolLpAddress(uint256 _pid, address _address)
        external
        onlyOwner
    {
        poolInfo[_pid].lpToken = IERC20Upgradeable(_address);
    }

    /**
     @notice set rewardPerBlock. It will change endblock as well.
     @param _rewardPerBlock reward per block.
     */
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(
            _rewardPerBlock > 0,
            "reward per block should be bigger than 0"
        );
        rewardPerBlock = _rewardPerBlock;
        uint256 sigBalance = sig.balanceOf(address(this));
        endBlock = startBlock + (sigBalance / rewardPerBlock);
        require(
            endBlock > block.number,
            "endBlock should be greater than current block number"
        );

        _massUpdatePools();

        emit RewardPerBlockSet(rewardPerBlock, endBlock);
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

    /* ========== External & Public Function  ========== */

    /**
      @notice deposit lp token in the pool
      @param _pid pool Id
      @param _amount amount of the lp token to deposit
     */
    function deposit(uint256 _pid, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {
        require(_amount > 0, "Deposit lp amount should be bigger than 0");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        _updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) /
                1e36) - user.rewardDebt;
            transferSIG(msg.sender, pendingAmount);
        }

        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        user.amount += _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;

        _updateBoostWeight(msg.sender, _pid);

        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
      @notice withdraw lp token and gets pending token.
      @param _pid pool Id
      @param _amount amount of the lp token to withdraw
     */
    function withdraw(uint256 _pid, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            user.amount - user.lockdropAmount >= _amount,
            "withdraw: can't withdraw more than deposit"
        );
        _updatePool(_pid);

        uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) / 1e36) -
            user.rewardDebt;

        transferSIG(msg.sender, pendingAmount);

        user.amount -= _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;

        _updateBoostWeight(msg.sender, _pid);

        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /**
      @notice claim pending rewards on the pool
      @param _pid pool id 
     */
    function claim(uint256 _pid) external whenNotPaused nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "User didn't deposit in this pool.");
        PoolInfo storage pool = poolInfo[_pid];
        uint256 pendingAmount = getUserBasePending(_pid, msg.sender);
        if (user.boostWeight > 0) {
            pendingAmount += getUserBoostPending(_pid, msg.sender);
        }
        require(pendingAmount > 0, "There is no rewards to claim");

        _updatePool(_pid);
        transferSIG(msg.sender, pendingAmount);

        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;
        }
        emit Claim(msg.sender, _pid, pendingAmount);
    }

    /**
      @notice update boost weight of the user to all pool user voted.
      @notice This will be called from xSIGFarm if user activate boost.
     */
    function updateBoostWeight(address _user) external override {
        for (uint256 i = 0; i < poolInfo.length; i++) {
            UserInfo storage user = userInfo[i][_user];
            if (user.amount > 0) {
                _updateBoostWeight(_user, i);
            }
        }
    }

    /**
      @notice update pool both with base,boost. anyone can update pool.
      @param _pid pool id
     */
    function updatePool(uint256 _pid) external whenNotPaused nonReentrant {
        _updatePoolWithBaseReward(_pid);
        _updatePoolWithBoostReward(_pid);
    }

    /**
      @notice Update reward variables for all pools. Be careful of gas spending! anyone can update pool.
     */
    function massUpdatePools() external whenNotPaused nonReentrant {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    /**
      @notice Fund the farm, anyone call fund sig token.
      @param _amount amount of the token to fund.
     */
    function fund(uint256 _amount) external whenNotPaused nonReentrant {
        require(block.number < endBlock, "fund: too late, the farm is closed");
        require(_amount > 0, "Funding amount should be bigger than 0");

        endBlock += _amount / rewardPerBlock;
        sig.safeTransferFrom(address(msg.sender), address(this), _amount);

        emit Funded(msg.sender, _amount, endBlock);
    }

    /* ========== Lockdrop related ====================== */

    function forwardLpTokensFromLockdrop(
        address _user,
        uint256 _amount,
        uint256 _lockingPeriod
    ) external override {
        require(_amount > 0, "Deposit lp amount should be bigger than 0");
        require(
            lockdropProxy == msg.sender,
            "This function should be called from lockdrop proxy."
        );

        PoolInfo storage pool = poolInfo[LOCKDROP_POOL_INDEX];
        UserInfo storage user = userInfo[LOCKDROP_POOL_INDEX][_user];
        _updatePool(LOCKDROP_POOL_INDEX);
        if (user.amount > 0) {
            uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) /
                1e36) - user.rewardDebt;

            transferSIG(_user, pendingAmount);
        }

        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        user.amount += _amount;
        user.lockdropAmount = _amount;
        user.lockingPeriod = _lockingPeriod;

        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;

        _updateBoostWeight(_user, LOCKDROP_POOL_INDEX);

        emit LockdropDeposit(msg.sender, _amount);
    }

    /**
        @notice withdrow lockdrop lp token at Lockdrop page 
    */
    function withdrawLockdropLPTokens() external nonReentrant whenNotPaused {
        UserInfo storage user = userInfo[LOCKDROP_POOL_INDEX][msg.sender];
        require(user.lockdropAmount > 0, "lockdrop amount is not existing.");
        require(
            LOCKDROP_ENDTIME + user.lockingPeriod < block.timestamp,
            "Lock period did not ended yet."
        );
        require(
            !user.isLockdropLPTokenClaimed,
            "You already claimed Lockdrop LPToken."
        );

        PoolInfo storage pool = poolInfo[LOCKDROP_POOL_INDEX];

        _updatePool(LOCKDROP_POOL_INDEX);

        uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) / 1e36) -
            user.rewardDebt;

        transferSIG(msg.sender, pendingAmount);

        user.amount -= user.lockdropAmount;
        user.lockdropAmount = 0;
        user.isLockdropLPTokenClaimed = true;

        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;

        _updateBoostWeight(msg.sender, LOCKDROP_POOL_INDEX);

        pool.lpToken.safeTransfer(address(msg.sender), user.lockdropAmount);
        emit WithdrawLockdropLP(msg.sender, user.lockdropAmount);
    }

    /* ========== Internal & Private Function  ========== */

    /**
      @notice update pool both with base,boost. anyone can update pool.
      @param _pid pool id
     */
    function _updatePool(uint256 _pid) private {
        _updatePoolWithBaseReward(_pid);
        _updatePoolWithBoostReward(_pid);
    }

    /**
      @notice Update reward variables for all pools. Be careful of gas spending! anyone can update pool.
     */
    function _massUpdatePools() private {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    /**
      @notice update boost weight of all existing pool
      @param _addr address of the user
      @param _pid pool id 
     */
    function _updateBoostWeight(address _addr, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_addr];

        _updatePoolWithBoostReward(_pid);

        uint256 vxAmount = vxSIG.balanceOf(_addr);
        uint256 oldBoostWeight = user.boostWeight;

        if (oldBoostWeight > 0) {
            uint256 boostPendingAmount = (oldBoostWeight *
                pool.boostAccERC20PerShare) /
                1e36 -
                user.boostRewardDebt;
            transferSIG(_addr, boostPendingAmount);
        }

        uint256 newBoostWeight = _sqrt(user.amount * vxAmount);

        user.boostRewardDebt =
            (newBoostWeight * pool.boostAccERC20PerShare) /
            1e36;
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
    function transferSIG(address _to, uint256 _amount) internal {
        paidOut += _amount;
        sig.safeTransfer(_to, _amount);
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

        uint256 erc20Reward = (nrOfBlocks * rewardPerBlock * pool.allocPoint) /
            totalAllocPoint;

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

        uint256 nrOfBlocks = lastBlock - pool.boostLastRewardBlock;

        uint256 erc20Reward = (nrOfBlocks *
            rewardPerBlock *
            pool.boostAllocPoint) / totalAllocPoint;

        pool.boostAccERC20PerShare =
            pool.boostAccERC20PerShare +
            (erc20Reward * 1e36) /
            totalBoostWeight;
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
    function totalProtocolPending() external view returns (uint256) {
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
     @notice user total pending reward including base and boost reward..
     @param _pid pool id
     @param _user user address 
     */
    function getUserTotalPendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        uint256 totalPending = 0;
        totalPending += getUserBasePending(_pid, _user);
        totalPending += getUserBoostPending(_pid, _user);

        return totalPending;
    }

    /**
     @notice pending amount with base reward.
     @param _pid pool id
     @param _user user address 
     */
    function getUserBasePending(uint256 _pid, address _user)
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
                rewardPerBlock *
                pool.allocPoint) / totalAllocPoint;
            accERC20PerShare =
                accERC20PerShare +
                ((erc20Reward * 1e36) / lpSupply);
        }

        return ((user.amount * accERC20PerShare) / 1e36) - user.rewardDebt;
    }

    /**
     @notice pending amount with boost reward.
     */
    function getUserBoostPending(uint256 _pid, address _user)
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
            uint256 nrOfBlocks = lastBlock - pool.boostLastRewardBlock;

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

    /**
     @notice withdrawable amount of LP Token for certain pool.
     */
    function lockdropWithdrawable(address _user)
        external
        view
        returns (uint256, uint256)
    {
        UserInfo memory user = userInfo[LOCKDROP_POOL_INDEX][_user];

        if (LOCKDROP_ENDTIME + user.lockingPeriod < block.timestamp) {
            return (user.amount - user.lockdropAmount, user.lockdropAmount);
        } else {
            return (user.amount - user.lockdropAmount, 0);
        }
    }
}
