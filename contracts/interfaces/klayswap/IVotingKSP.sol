//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IVotingKSP {
    function lockKSP(uint256 amount, uint256 lockPeriodRequested) external;

    function lockedKSP(address account) external view returns (uint256);

    //TODO: 아래는 ABI 받고 주석 풀면됨.
    // function unlockKSP() external;

    // function refixBoosting(uint256 lockPeriodRequested) external;

    // function claimReward() external;

    // function compoundReward() external;

    function balanceOf(address account) external view returns (uint256);
}
