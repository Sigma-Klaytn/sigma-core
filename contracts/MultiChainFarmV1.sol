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
}

/// @notice  Farm distributes the oSHO rewards based on staked vxSIG to each user.
// Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by LTO Network to work for non-mintable sig.
// Modified by Sigma to work for boosted rewards with vxSIG.
contract MultichainFarmV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* ========== STATE VARIABLES ========== */

    IvxERC20 public vxSIG;

    /// @notice Address of the oSHO Token contract.
    IERC20Upgradeable public oSHO;
    /// @notice Last block number that ERC20s distribution occurs.
    uint256 public lastRewardBlock;
    /// @notice  Accumulated ERC20s per share, times 1e36.
    uint256 public accERC20PerShare;

    /// @notice The total amount of oSHO that's paid out as base reward.
    uint256 public paidOut;
    /// @notice oSHO tokens rewarded per block.
    uint256 public rewardPerBlock;

    /// @notice Info of each user that activates vxSIG tokens.
    mapping(address => UserInfo) public userInfo;

    /// @notice The block number when farming starts.
    uint256 public startBlock;
    /// @notice The block number when farming ends.
    uint256 public endBlock;

    /// @notice Total VxSIG Amount.
    uint256 public totalVxSIGAmount;

    /// @notice Info of each user.
    struct UserInfo {
        uint256 amount; // How many vxSIG tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event Funded(address indexed from, uint256 amount, uint256 newEndBlock);
    event RewardPerBlockSet(uint256 rewardPerBlock, uint256 endBlock);
    event InitialInfoSet(
        uint256 rewardPerBlock,
        uint256 startBlock,
        uint256 endBlock
    );

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
        address _oSHO,
        address _vxSIG,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) external onlyOwner {
        require(
            _startBlock > block.number,
            "Start block should be in the future"
        );
        oSHO = IERC20Upgradeable(_oSHO);
        vxSIG = IvxERC20(_vxSIG);
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock;
        lastRewardBlock = _startBlock;

        emit InitialInfoSet(rewardPerBlock, startBlock, endBlock);
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
        uint256 oSHOBalance = oSHO.balanceOf(address(this));
        endBlock = startBlock + oSHOBalance / rewardPerBlock;
        require(
            endBlock > block.number,
            "endBlock should be greater than current block number"
        );

        _updateReward();

        emit RewardPerBlockSet(rewardPerBlock, endBlock);
    }

    /* ========== External & Public Function  ========== */

    /**
      @notice claim pending sig rewards.
     */
    function claim() external whenNotPaused nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "User didn't deposit in this pool.");
        uint256 pendingAmount = rewardPending(msg.sender);

        require(pendingAmount > 0, "claim: no rewards to claim");

        _updateReward();
        _transferOSHO(msg.sender, pendingAmount);

        user.rewardDebt = (user.amount * accERC20PerShare) / 1e36;
        emit Claim(msg.sender, pendingAmount);
    }

    /**
      @notice update boost vxSIG Amoubnt of the user. 
      @notice This will be called from xSIGFarm if user activate/deactivate boost.
      @notice 
     */
    function updateVxSIGAmount(address _user)
        external
        whenNotPaused
        nonReentrant
    {
        uint256 vxSIGBalance = vxSIG.balanceOf(_user);
        UserInfo storage user = userInfo[_user];
        if (vxSIGBalance > 0 || user.amount > 0) {
            _updateVxSIGAmount(_user);
        }
    }

    /**
      @notice update pool both with base,boost
     */
    function updateReward() external whenNotPaused nonReentrant {
        _updateReward();
    }

    /**
      @notice Fund the farm, anyone call fund sig token.
      @param _amount amount of the token to fund.
     */
    function fund(uint256 _amount) external onlyOwner {
        require(block.number < endBlock, "fund: too late, the farm is closed");
        require(_amount > 0, "Funding amount should be bigger than 0");

        endBlock += _amount / rewardPerBlock;
        oSHO.safeTransferFrom(address(msg.sender), address(this), _amount);

        emit Funded(msg.sender, _amount, endBlock);
    }

    /* ========== Internal & Private Function  ========== */

    /**
      @notice update boost weight of all existing pool
      @param _addr address of the user
     */
    function _updateVxSIGAmount(address _addr) internal {
        UserInfo storage user = userInfo[_addr];

        _updateReward();

        uint256 vxAmount = vxSIG.balanceOf(_addr);
        uint256 oldVxSIGAmount = user.amount;

        if (oldVxSIGAmount > 0) {
            uint256 pendingAmount = (oldVxSIGAmount * accERC20PerShare) /
                1e36 -
                user.rewardDebt;
            _transferOSHO(_addr, pendingAmount);
        }

        user.rewardDebt = (vxAmount * accERC20PerShare) / 1e36;

        user.amount = vxAmount;
        totalVxSIGAmount = totalVxSIGAmount - oldVxSIGAmount + vxAmount;
    }

    /**
      @notice send _amount amount of sig to _to & add up paidOut
      @param _to receiver of the token
      @param _amount amount of the sig token to send 
     */
    function _transferOSHO(address _to, uint256 _amount) internal {
        paidOut += _amount;
        oSHO.safeTransfer(_to, _amount);
    }

    /**
      @notice update boost reward variable of the pool
     */
    function _updateReward() private {
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= lastRewardBlock) {
            return;
        }
        uint256 _totalVxSIGAmount = totalVxSIGAmount;
        if (_totalVxSIGAmount == 0) {
            lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock - lastRewardBlock;
        uint256 erc20Reward = nrOfBlocks * rewardPerBlock;

        accERC20PerShare =
            accERC20PerShare +
            ((erc20Reward * 1e36) / totalVxSIGAmount);
        lastRewardBlock = block.number;
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
     @notice pending amount with boost reward.
     */
    function rewardPending(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];

        if (user.amount == 0) {
            return 0;
        }
        uint256 _accERC20PerShare = accERC20PerShare;
        uint256 _totalVxSIGAmount = totalVxSIGAmount;
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (
            lastBlock > lastRewardBlock &&
            block.number > lastRewardBlock &&
            _totalVxSIGAmount != 0
        ) {
            uint256 nrOfBlocks = lastBlock - lastRewardBlock;
            uint256 erc20Reward = nrOfBlocks * rewardPerBlock;

            _accERC20PerShare =
                _accERC20PerShare +
                (erc20Reward * 1e36) /
                _totalVxSIGAmount;
        }

        return (user.amount * _accERC20PerShare) / 1e36 - user.rewardDebt;
    }

    /**
     @notice activated amount of the vxSIG.
     */
    function deposited(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        return user.amount;
    }
}
