//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPoolVoting {
    function addVoting(address exchange, uint256 amount) external;

    function removeVoting(address exchange, uint256 amount) external;

    function claimReward(address exchange) external;

    function userVotingPoolCount(address user) external view returns (uint256);

    // function claimRewardAll() external;

    // function removeAllVoting() external;
}
