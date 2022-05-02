// //SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./interfaces/sigma/Whitelist.sol";
// import "./interfaces/sigma/IxSIGFarm.sol";
// import "./interfaces/sigma/IvxERC20.sol";
// import "./libraries/DSMath.sol";

// contract sigKSPFarm is Ownable {
//     /* ========== STATE VARIABLES ========== */

//     IERC20 public sigKSP;
//     IvxERC20 public vxSIG;
//     IERC20 public sig;

//     /// @notice the rate of vxSIG generated per second
//     uint256 public generationRate;
//     uint256 public basePoolRatio;

//     struct UserInfo {
//         uint256 stakedSigKSP; // staked sigKSP of the user
//     }

//     struct DepositInfo {
//         uint256 unlockTime;
//         uint256 stakedSigKSP;
//         uint256 lastRelease;
//     }

//     uint256 constant DAY = 86400;

//     /// @notice UserInfo mapping
//     mapping(address => UserInfo) public userInfoOf;
//     mapping(address => DepositInfo[]) public depositInfoOf;

//     /// @notice events describing staking, unstaking and claiming
//     event Staked(
//         address indexed user,
//         uint256 indexed amount,
//         uint256 indexed totalStakedAmount
//     );
//     event Unstaked(
//         address indexed user,
//         uint256 indexed amount,
//         uint256 indexed totalStakedAmount
//     );
//     event Claimed(address indexed user, uint256 indexed amount);

//     /* ========== External Function  ========== */

//     /**
//      @notice stake sigKSP
//      @param _amount the amount of sigKSP to stake
//      */
//     function stake(uint256 _amount) external override {
//         require(_amount > 0, "stake sigKSP amount should be bigger than 0");

//         UserInfo storage userInfo = userInfoOf[msg.sender];
//         if (userInfo.stakedSigKSP == 0) {
//             userInfo.startTime = block.timestamp;
//             userInfo.lastRelease = block.timestamp;
//         }

//         sigKSP.transferFrom(msg.sender, address(this), _amount);
//         userInfo.stakedSigKSP += _amount;

//         emit Staked(msg.sender, _amount, userInfo.stakedSigKSP);
//     }

//     /**
//      @notice withdraws staked sigKSP
//      @param _amount the amount of sigKSP to unstake
//      */
//     function unstake(uint256 _amount) external override {
//         require(_amount > 0, "Unstake amount should be bigger than 0");
//         UserInfo storage userInfo = userInfoOf[msg.sender];
//         require(
//             userInfo.stakedSigKSP >= _amount,
//             "Insuffcient stakedSigKSP to unstake"
//         );

//         userInfo.stakedSigKSP -= _amount;

//         if (userInfo.stakedSigKSP == 0) {
//             userInfo.startTime = 0;
//             userInfo.lastRelease = 0;
//         } else {
//             userInfo.startTime = block.timestamp;
//             userInfo.lastRelease = block.timestamp;
//         }

//         sigKSP.transfer(msg.sender, _amount);

//         emit Unstaked(msg.sender, _amount, userInfo.stakedSigKSP);
//     }

//     /**
//      @notice claims accumulated vxSIG
//      */
//     function claim() external override {
//         require(isUser(msg.sender), "User didn't stake any sigKSP.");
//         _claim(msg.sender);
//     }

//     /* ========== Restricted Function  ========== */

//     /**
//      @notice sets initialInfo of the contract.
//      */
//     function setInitialInfo(
//         address _sigKSP,
//         address _vxSIG,
//         address _SIG,
//         uint256 _generationRate,
//         uint256 _basePoolRatio
//     ) external onlyOwner {
//         sigKSP = IERC20(_sigKSP);
//         vxSIG = IvxERC20(_vxSIG);
//         sig = IERC20(_SIG);

//         //Initial generation rate. 0.014 vxSIG per hour
//         generationRate = _generationRate;
//         basePoolRatio = _basePoolRatio;
//     }

//     /**
//      @notice sets generation rate
//      @param _generationRate the new generation rate. how much vxSIG going to be added per second.
//      */
//     function setGenerationRate(uint256 _generationRate) external onlyOwner {
//         require(_generationRate != 0, "generation rate cannot be zero");
//         require(
//             _generationRate != generationRate,
//             "new generation is same with old one"
//         );

//         generationRate = _generationRate;
//     }

//     /**
//      @notice sets basePoolRatio
//      @param _basePoolRatio base pool ratio of the reward pool. it should be between 0 to 100
//      */
//     function setBasePoolRatio(uint256 _basePoolRatio) external onlyOwner {
//         require(
//             _basePoolRatio >= 0 && _basePoolRatio <= 100,
//             "Base pool ratio should be between 0 to 100"
//         );
//         basePoolRatio = _basePoolRatio;
//     }

//     /* ========== Internal & Private Function  ========== */

//     /**
//         @notice private claim SIG function
//         @param _address the address of the user to claim from
//      */
//     function _claim(address _address) private {
//         uint256 amount = _claimable(_address);

//         // update last release time
//         userInfoOf[_address].lastRelease = block.timestamp;

//         if (amount > 0) {
//             emit Claimed(_address, amount);
//             vxSIG.mint(_address, amount);
//         }
//     }

//     /**
//      @notice private claim function
//      @param _address the address of the user to claim from
//      */
//     function _claimable(address _address) private view returns (uint256) {
//         UserInfo memory user = userInfoOf[_address];

//         // get seconds elapsed since last claim
//         uint256 secondsElapsed = block.timestamp - user.lastRelease;

//         // DSMath.wmul used to multiply wad numbers
//         uint256 pending = DSMath.wmul(
//             user.stakedSigKSP,
//             secondsElapsed * generationRate
//         );
//         // get user's vxSIG balance
//         uint256 userVxSIGBalance = vxSIG.balanceOf(_address);

//         // user vxSIG balance cannot go above user.amount * maxCap
//         uint256 maxVxSIGCap = DSMath.wmul(user.stakedSigKSP, maxVxSIGPerXSIG);

//         // first, check that user hasn't reached the max limit yet
//         if (userVxSIGBalance < maxVxSIGCap) {
//             // then, check if pending amount will make user balance overpass maximum amount
//             if ((userVxSIGBalance + pending) > maxVxSIGCap) {
//                 return maxVxSIGCap - userVxSIGBalance;
//             } else {
//                 return pending;
//             }
//         }
//         return 0;
//     }

//     /* ========== View Function  ========== */

//     /**
//      @notice checks wether user _address has sigKSP staked
//      @param _address the user address to check
//      @return true if the user has sigKSP in stake, false otherwise
//     */
//     function isUser(address _address) public view override returns (bool) {
//         return userInfoOf[_address].stakedSigKSP > 0;
//     }

//     /**
//      @notice Calculate the amount of vxSIG that can be claimed by user
//      @param _address the address to check
//      @return amount of vxSIG that can be claimed by user
//      */

//     function claimable(address _address) external view returns (uint256) {
//         require(_address != address(0), "zero address");
//         return _claimable(_address);
//     }

//     /**
//      @notice Check Staked sigKSP of the user
//      @param _address the user address to check
//      */
//     function getstakedSigKSP(address _address)
//         external
//         view
//         override
//         returns (uint256)
//     {
//         require(_address != address(0), "zero address");
//         return userInfoOf[_address].stakedSigKSP;
//     }
// }
