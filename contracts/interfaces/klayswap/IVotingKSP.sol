//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IVotingKSP {
    function lockKSP(uint256 amount, uint256 lockPeriodRequested) external;

    function lockedKSP(address account) external view returns (uint256);

    function unlockKSP() external;

    function refixBoosting(uint256 lockPeriodRequested) external;

    function claimReward() external;

    function getCurrentBalance(address account) external view returns (uint256);

    // function compoundReward() external;

    function getPriorBalance(address user, uint256 blockNumber)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}
