// //SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./dependencies/SafeERC20.sol";
// import "./interfaces/sigma/IxSIGToken.sol";
// import "./interfaces/sigma/ISigFarm.sol";
contract SIGFarm {

}
// contract SIGFarm is Ownable, ISigFarm {
//     using SafeERC20 for IERC20;
//     using SafeERC20 for IxSIGToken;
//     /* ========== STATE VARIABLES ========== */
//     /// @notice SIG token which will deposited to SigFarm.
//     IERC20 public SIG;
//     /// @notice xSIG token which can be minted in SigFarm.
//     IxSIGToken public xSIG;
//     /// @notice unlocking period is needed to redeem xSIG for SIG.
//     uint256 public lockingPeriod;
//     uint256 public pendingxSIG;
//     uint256 public pendingSIG;

//     mapping(address => WithdrawInfo[]) public withdrawInfoOf;

//     struct WithdrawInfo {
//         uint256 unlockTime;
//         uint256 xSIGAmount;
//         uint256 SIGAmount;
//         bool isWithdrawn;
//     }

//     event Unstake(uint256 redeemedxSIG, uint256 sigQueued);
//     event ClaimUnlockedSIG(uint256 withdrawnSIG, uint256 burnedxSIG);
//     event Stake(uint256 stakedSIG, uint256 mintedxSIG);
//     event FeesReceived(address indexed caller, uint256 amount);

//     /* ========== External Function  ========== */

//     /**
//         @notice stake SIG for xSIG
//         @param _amount The amount of SIG to deposit
//      */
//     function stake(uint256 _amount) external {
//         require(_amount > 0, "Stake SIG amount should be bigger than 0");
//         require(
//             SIG.balanceOf(msg.sender) > _amount,
//             "Not enough SIG amount to stake."
//         );
//         SIG.safeTransferFrom(msg.sender, address(this), _amount);
//         uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG - _amount;
//         uint256 xSIGAmount = xSIG.totalSupply() - pendingxSIG;

//         uint256 xSIGToGet;
//         if (sigAmount == 0) {
//             xSIGToGet = _amount;
//         } else {
//             xSIGToGet = (_amount * xSIGAmount * 1e18) / sigAmount;
//             xSIGToGet /= 1e18;
//         }

//         xSIG.mint(msg.sender, xSIGToGet);

//         emit Stake(_amount, xSIGToGet);
//     }

//     /**
//         @notice Return xSIG for SIG which is compounded over time. It needs unlocking period.
//         @param _amount The amount of xSIG to redeem
//      */
//     function unstake(uint256 _amount) external {
//         require(_amount > 0, "Redeem xSIG should be bigger than 0");
//         require(
//             xSIG.balanceOf(msg.sender) > _amount,
//             "Not enough xSIG amount to unstake."
//         );

//         xSIG.safeTransferFrom(msg.sender, address(this), _amount);

//         uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG;
//         uint256 xSIGAmount = xSIG.totalSupply() - pendingxSIG;

//         uint256 sigToReturn = (_amount * sigAmount * 1e18) / xSIGAmount;
//         uint256 endTime = block.timestamp + lockingPeriod;

//         sigToReturn /= 1e18;

//         withdrawInfoOf[msg.sender].push(
//             WithdrawInfo({
//                 unlockTime: endTime,
//                 xSIGAmount: _amount,
//                 SIGAmount: sigToReturn,
//                 isWithdrawn: false
//             })
//         );

//         pendingSIG += sigToReturn;
//         pendingxSIG += _amount;

//         emit Unstake(_amount, sigToReturn);
//     }

//     /**
//         @notice Claim SIG which unlocking period has been ended.
//      */
//     function claimUnlockedSIG() external {
//         (
//             uint256 withdrawableSIG,
//             uint256 totalBurningxSIG
//         ) = _computeWithdrawableSIG(msg.sender);
//         require(
//             withdrawableSIG > 0 && totalBurningxSIG > 0,
//             "This address has no withdrawalbe SIG"
//         );

//         xSIG.burn(address(this), totalBurningxSIG);
//         SIG.safeTransfer(msg.sender, withdrawableSIG);

//         emit ClaimUnlockedSIG(withdrawableSIG, totalBurningxSIG);
//     }

//     /**
//         @notice Deposit protocol fees into the contract, to be distributed to stakers.
//         @param _amount Amount of the token to deposit
//      */
//     function depositFee(uint256 _amount) external override {
//         require(_amount > 0, "Deposit amount should be bigger than 0");
//         SIG.safeTransferFrom(msg.sender, address(this), _amount);
//         emit FeesReceived(msg.sender, _amount);
//     }

//     /* ========== Restricted Function  ========== */

//     function setLockingPeriod(uint256 _lockingPeriod) external onlyOwner {
//         lockingPeriod = _lockingPeriod;
//     }

//     function setInitialInfo(
//         address _SIG,
//         uint256 _lockingPeriod,
//         address _xSIG
//     ) external onlyOwner {
//         xSIG = IxSIGToken(_xSIG);
//         SIG = IERC20(_SIG);
//         lockingPeriod = _lockingPeriod;
//     }

//     /* ========== Internal Function  ========== */

//     /**
//         @notice Update user's withdrawable info when inidividual unlocking is expired.
//         @param _user address of user which update withdrawable SIG array.
//      */
//     function _computeWithdrawableSIG(address _user)
//         internal
//         returns (uint256, uint256)
//     {
//         WithdrawInfo[] storage withdrawableInfos = withdrawInfoOf[_user];
//         uint256 withdrawableSIG = 0;
//         uint256 totalBurningxSIG = 0;

//         for (uint256 i = 0; i < withdrawableInfos.length; i++) {
//             WithdrawInfo storage withdrawInfo = withdrawableInfos[i];
//             if (!withdrawInfo.isWithdrawn) {
//                 if (withdrawInfo.unlockTime < block.timestamp) {
//                     withdrawableSIG += withdrawInfo.SIGAmount;
//                     totalBurningxSIG += withdrawInfo.xSIGAmount;
//                     withdrawInfo.isWithdrawn = true;
//                 }
//             }
//         }

//         if (withdrawableSIG != 0 && totalBurningxSIG != 0) {
//             pendingSIG -= withdrawableSIG;
//             pendingxSIG -= totalBurningxSIG;
//         }
//         return (withdrawableSIG, totalBurningxSIG);
//     }

//     /* ========== View Function  ========== */

//     /**
//         @notice Compute Withdrawable SIG at given time.
//      */
//     function getRedeemableSIG() external view returns (uint256) {
//         WithdrawInfo[] memory withdrawableInfos = withdrawInfoOf[msg.sender];
//         uint256 withdrawableSIG;

//         for (uint256 i = 0; i < withdrawableInfos.length; i++) {
//             WithdrawInfo memory withdrawInfo = withdrawableInfos[i];
//             if (!withdrawInfo.isWithdrawn) {
//                 if (withdrawInfo.unlockTime < block.timestamp) {
//                     withdrawableSIG += withdrawInfo.SIGAmount;
//                 }
//             }
//         }
//         return withdrawableSIG;
//     }

//     /**
//         @notice You should devide return value by 10^7 to get a right number.
//      */
//     function getxSIGExchangeRate() external view returns (uint256) {
//         uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG;
//         if (sigAmount == 0) {
//             return 1 * 1e7;
//         } else {
//             uint256 xSIGAmount = xSIG.totalSupply() - pendingxSIG;
//             return (sigAmount * 1e7) / xSIGAmount;
//         }
//     }
// }
