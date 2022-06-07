// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.9;

// import "./dependencies/SafeERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "./interfaces/sigma/IvxERC20.sol";
// import "./interfaces/sigma/ISigKSPFarm.sol";

// /// @notice  Farm distributes the sig rewards based on staked sigKSP to each user.
// /// @notice variable name with prefix "boost" means that's related to boost reward. Others are related to base reward.
// // Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// // Modified by LTO Network to work for non-mintable sig.
// // Modified by Sigma to work for boosted rewards with vxSIG.
// contract SigKSPFarm is Ownable, ISigKSPFarm {
//     using SafeERC20 for IERC20;

//     IvxERC20 public vxSIG;

//     /// @notice address of sigKSP token contract.
//     IERC20 public sigKSP;
//     /// @notice Address of the sig Token contract.
//     IERC20 public sig;
//     /// @notice Last block number that ERC20s distribution occurs.
//     uint256 public lastRewardBlock;
//     /// @notice  Accumulated ERC20s per share, times 1e36.
//     uint256 public accERC20PerShare;
//     /// @notice Last block number that ERC20s distribution occurs.
//     uint256 public boostLastRewardBlock;
//     /// @notice Accumulated ERC20s per share, times 1e36.
//     uint256 public boostAccERC20PerShare;
//     /// @notice Total boost weight of the pool
//     uint256 public totalBoostWeight;

//     /// @notice The total amount of SIG that's paid out as base reward.
//     uint256 public paidOut;
//     /// @notice sig tokens rewarded per block.
//     uint256 public rewardPerBlock;

//     /// @notice Reward per block will be divided by totalAllocPoint

//     uint256 public totalAllocPoint;
//     uint256 public baseAllocPoint;
//     uint256 public boostAllocPoint;

//     /// @notice Info of each user that stakes sigKSP tokens.
//     mapping(address => UserInfo) public userInfo;

//     /// @notice The block number when farming starts.
//     uint256 public startBlock;
//     /// @notice The block number when farming ends.
//     uint256 public endBlock;

//     /// @notice Info of each user.
//     struct UserInfo {
//         uint256 amount; // How many sigKSP tokens the user has provided.
//         uint256 rewardDebt; // Reward debt.
//         uint256 boostRewardDebt; // Boosted Reward debt.
//         uint256 boostWeight;
//     }

//     event Deposit(address indexed user, uint256 amount);
//     event Withdraw(address indexed user, uint256 amount);
//     event Claim(address indexed user, uint256 amount);
//     event Funded(address indexed from, uint256 amount, uint256 newEndBlock);
//     event RewardPerBlockSet(uint256 rewardPerBlock, uint256 endBlock);
//     event InitialInfoSet(
//         uint256 rewardPerBlock,
//         uint256 startBlock,
//         uint256 endBlock
//     );

//     /* ========== External & Public Function  ========== */

//     /**
//       @notice deposit sigKSP token in the pool
//       @param _amount amount of the sigKSP token to deposit
//      */
//     function deposit(uint256 _amount) external {
//         UserInfo storage user = userInfo[msg.sender];
//         updateReward();
//         if (user.amount > 0) {
//             uint256 pendingAmount = ((user.amount * accERC20PerShare) / 1e36) -
//                 user.rewardDebt;

//             //if user has boost,
//             if (user.boostWeight > 0) {
//                 uint256 boostPendingAmount = (user.boostWeight *
//                     boostAccERC20PerShare) /
//                     1e36 -
//                     user.boostRewardDebt;

//                 pendingAmount += boostPendingAmount;
//             }
//             _transferSIG(msg.sender, pendingAmount);
//         }
//         sigKSP.safeTransferFrom(address(msg.sender), address(this), _amount);
//         user.amount += _amount;
//         user.rewardDebt = (user.amount * accERC20PerShare) / 1e36;
//         if (user.boostWeight > 0) {
//             user.boostRewardDebt =
//                 (user.boostWeight * boostAccERC20PerShare) /
//                 1e36;
//         }

//         emit Deposit(msg.sender, _amount);
//     }

//     /**
//       @notice withdraw sigKSP token and gets pending token.
//       @param _amount amount of the sigKSP token to withdraw
//      */
//     function withdraw(uint256 _amount) external {
//         UserInfo storage user = userInfo[msg.sender];
//         require(
//             user.amount >= _amount,
//             "withdraw: can't withdraw more than deposit"
//         );
//         updateReward();

//         uint256 pendingAmount = ((user.amount * accERC20PerShare) / 1e36) -
//             user.rewardDebt;

//         //if user has boost,
//         if (user.boostWeight > 0) {
//             uint256 boostPendingAmount = (user.boostWeight *
//                 boostAccERC20PerShare) /
//                 1e36 -
//                 user.boostRewardDebt;
//             pendingAmount += boostPendingAmount;
//         }

//         _transferSIG(msg.sender, pendingAmount);

//         user.amount -= _amount;
//         user.rewardDebt = (user.amount * accERC20PerShare) / 1e36;
//         if (user.boostWeight > 0) {
//             user.boostRewardDebt =
//                 (user.boostWeight * boostAccERC20PerShare) /
//                 1e36;

//             _updateBoostWeight(msg.sender);
//         }

//         sigKSP.safeTransfer(address(msg.sender), _amount);
//         emit Withdraw(msg.sender, _amount);
//     }

//     /**
//       @notice claim pending sig rewards.
//      */
//     function claim() external {
//         UserInfo storage user = userInfo[msg.sender];
//         require(user.amount > 0, "User didn't deposit in this pool.");
//         uint256 pendingAmount = basePending(msg.sender);
//         if (user.boostWeight > 0) {
//             pendingAmount += boostPending(msg.sender);
//         }
//         require(pendingAmount > 0, "claim: no rewards to claim");

//         updateReward();
//         _transferSIG(msg.sender, pendingAmount);

//         user.rewardDebt = (user.amount * accERC20PerShare) / 1e36;
//         if (user.boostWeight > 0) {
//             user.boostRewardDebt =
//                 (user.boostWeight * boostAccERC20PerShare) /
//                 1e36;
//         }
//         emit Claim(msg.sender, pendingAmount);
//     }

//     /**
//       @notice update boost weight of the user. 
//       @notice This will be called from xSIGFarm if user activate/deactivate boost.
//      */
//     function updateBoostWeight() external override {
//         UserInfo memory user = userInfo[msg.sender];
//         //0. if user has amount
//         if (user.amount > 0) {
//             _updateBoostWeight(msg.sender);
//         }
//     }

//     /**
//       @notice update pool both with base,boost
//      */
//     function updateReward() public {
//         _updateBaseReward();
//         _updateBoostReward();
//     }

//     /**
//       @notice Fund the farm, anyone call fund sig token.
//       @param _amount amount of the token to fund.
//      */
//     function fund(uint256 _amount) public {
//         require(block.number < endBlock, "fund: too late, the farm is closed");
//         require(_amount > 0, "Funding amount should be bigger than 0");

//         endBlock += _amount / rewardPerBlock;
//         sig.safeTransferFrom(address(msg.sender), address(this), _amount);

//         emit Funded(msg.sender, _amount, endBlock);
//     }

//     /* ========== Restricted Function  ========== */
//     /**
//      @notice sets initialInfo of the contract.
//      */
//     function setInitialInfo(
//         IERC20 _sig,
//         IERC20 _sigKSP,
//         IvxERC20 _vxSIG,
//         uint256 _rewardPerBlock,
//         uint256 _startBlock,
//         uint256 _baseAllocPoint,
//         uint256 _boostAllocPoint
//     ) external onlyOwner {
//         require(
//             _startBlock > block.number,
//             "Start block should be in the future"
//         );
//         sig = _sig;
//         vxSIG = _vxSIG;
//         sigKSP = _sigKSP;
//         rewardPerBlock = _rewardPerBlock;
//         startBlock = _startBlock;
//         endBlock = _startBlock;
//         lastRewardBlock = _startBlock;
//         boostLastRewardBlock = _startBlock;

//         baseAllocPoint = _baseAllocPoint;
//         boostAllocPoint = _boostAllocPoint;
//         totalAllocPoint = baseAllocPoint + boostAllocPoint;

//         emit InitialInfoSet(rewardPerBlock, startBlock, endBlock);
//     }

//     /**
//      @notice sets baseAllocPoint and boostAllocPoint of the contract.
//      */
//     function setBaseAndBoostAllocPoint(
//         uint256 _baseAllocPoint,
//         uint256 _boostAllocPoint
//     ) external onlyOwner {
//         updateReward();
//         baseAllocPoint = _baseAllocPoint;
//         boostAllocPoint = _boostAllocPoint;
//         totalAllocPoint = baseAllocPoint + boostAllocPoint;
//     }

//     /**
//      @notice set rewardPerBlock. It will change endblock as well.
//      */
//     function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
//         require(
//             _rewardPerBlock > 0,
//             "reward per block should be bigger than 0"
//         );
//         rewardPerBlock = _rewardPerBlock;
//         uint256 sigBalance = sig.balanceOf(address(this));
//         endBlock = startBlock + sigBalance / rewardPerBlock;

//         emit RewardPerBlockSet(rewardPerBlock, endBlock);
//     }

//     /* ========== Internal & Private Function  ========== */

//     /**
//       @notice update boost weight of all existing pool
//       @param _addr address of the user
//      */
//     function _updateBoostWeight(address _addr) internal {
//         UserInfo storage user = userInfo[msg.sender];

//         _updateBoostReward();

//         uint256 vxAmount = vxSIG.balanceOf(_addr);
//         uint256 oldBoostWeight = user.boostWeight;

//         uint256 newBoostWeight = _sqrt(user.amount * vxAmount);
//         user.boostWeight = newBoostWeight;
//         totalBoostWeight = totalBoostWeight - oldBoostWeight + newBoostWeight;
//     }

//     /**
//       @notice send _amount amount of sig to _to & add up paidOut
//       @param _to receiver of the token
//       @param _amount amount of the sig token to send 
//      */
//     function _transferSIG(address _to, uint256 _amount) internal {
//         paidOut += _amount;
//         sig.safeTransfer(_to, _amount);
//     }

//     /**
//       @notice update base reward variable of the pool
//      */
//     function _updateBaseReward() internal {
//         uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

//         if (lastBlock <= lastRewardBlock) {
//             return;
//         }
//         uint256 totalSigKSP = sigKSP.balanceOf(address(this));
//         if (totalSigKSP == 0) {
//             lastRewardBlock = lastBlock;
//             return;
//         }

//         uint256 nrOfBlocks = lastBlock - lastRewardBlock;

//         uint256 erc20Reward = (nrOfBlocks * rewardPerBlock * baseAllocPoint) /
//             totalAllocPoint;

//         accERC20PerShare =
//             accERC20PerShare +
//             (erc20Reward * 1e36) /
//             totalSigKSP;
//         lastRewardBlock = block.number;
//     }

//     /**
//       @notice update boost reward variable of the pool
//      */
//     function _updateBoostReward() internal {
//         uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

//         if (lastBlock <= boostLastRewardBlock) {
//             return;
//         }
//         uint256 _totalBoostWeight = totalBoostWeight;
//         if (_totalBoostWeight == 0) {
//             boostLastRewardBlock = lastBlock;
//             return;
//         }

//         uint256 nrOfBlocks = lastBlock - boostLastRewardBlock;

//         uint256 erc20Reward = (nrOfBlocks * rewardPerBlock * boostAllocPoint) /
//             totalAllocPoint;

//         boostAccERC20PerShare =
//             boostAccERC20PerShare +
//             ((erc20Reward * 1e36) / _totalBoostWeight);
//         boostLastRewardBlock = block.number;
//     }

//     function _sqrt(uint256 y) internal pure returns (uint256 z) {
//         if (y > 3) {
//             z = y;
//             uint256 x = y / 2 + 1;
//             while (x < z) {
//                 z = x;
//                 x = (y / x + x) / 2;
//             }
//         } else if (y != 0) {
//             z = 1;
//         }
//     }

//     /* ========== View Function  ========== */

//     /**
//      @notice total pending amount on protocol.
//      */
//     function totalPending() external view returns (uint256) {
//         if (block.number <= startBlock) {
//             return 0;
//         }

//         uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
//         return (rewardPerBlock * (lastBlock - startBlock)) - paidOut;
//     }

//     /**
//      @notice pending amount with base reward.
//      */
//     function basePending(address _user) public view returns (uint256) {
//         UserInfo memory user = userInfo[_user];
//         if (user.amount == 0) {
//             return 0;
//         }
//         uint256 _accERC20PerShare = accERC20PerShare;
//         uint256 totalSigKSP = sigKSP.balanceOf(address(this));
//         uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

//         if (
//             lastBlock > lastRewardBlock &&
//             block.number > lastRewardBlock &&
//             totalSigKSP != 0
//         ) {
//             uint256 nrOfBlocks = lastBlock - lastRewardBlock;
//             uint256 erc20Reward = (nrOfBlocks *
//                 (rewardPerBlock) *
//                 (baseAllocPoint)) / (totalAllocPoint);
//             _accERC20PerShare =
//                 _accERC20PerShare +
//                 ((erc20Reward * 1e36) / totalSigKSP);
//         }

//         return ((user.amount * _accERC20PerShare) / 1e36) - user.rewardDebt;
//     }

//     /**
//      @notice pending amount with boost reward.
//      */
//     function boostPending(address _user) public view returns (uint256) {
//         UserInfo memory user = userInfo[_user];

//         if (user.boostWeight == 0) {
//             return 0;
//         }
//         uint256 _boostAccERC20PerShare = boostAccERC20PerShare;
//         uint256 _totalBoostWeight = totalBoostWeight;
//         uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

//         if (
//             lastBlock > boostLastRewardBlock &&
//             block.number > boostLastRewardBlock &&
//             _totalBoostWeight != 0
//         ) {
//             uint256 nrOfBlocks = lastBlock - boostLastRewardBlock;

//             uint256 erc20Reward = (nrOfBlocks *
//                 rewardPerBlock *
//                 boostAllocPoint) / (totalAllocPoint);

//             _boostAccERC20PerShare =
//                 _boostAccERC20PerShare +
//                 (erc20Reward * 1e36) /
//                 _totalBoostWeight;
//         }

//         return
//             (user.boostWeight * _boostAccERC20PerShare) /
//             1e36 -
//             user.boostRewardDebt;
//     }

//     /**
//      @notice deposited amount of the sigKSP.
//      */
//     function deposited(address _user) external view returns (uint256) {
//         UserInfo memory user = userInfo[_user];
//         return user.amount;
//     }
// }
