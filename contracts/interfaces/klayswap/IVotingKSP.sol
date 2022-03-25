//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IVotingKSP {
    function lockKSP(uint amount, uint lockPeriodRequested) external;
    function unlockKSP() external;
    function refixBoosting(uint lockPeriodRequested) external;
    function claimReward() external;
    function compoundReward() external;
    function lockedKSP(address account) external view returns(uint256);

}