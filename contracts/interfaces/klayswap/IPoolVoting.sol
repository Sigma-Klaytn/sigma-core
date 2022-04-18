//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPoolVoting {
    function addVoting(address exchange, uint256 amount) external;

    function removeVoting(address exchange, uint256 amount) external;

    function claimReward(address exchange) external;

    function userVotingPoolAmount(address user, uint256 poolIndex)
        external
        view
        returns (uint256);

    function userVotingPoolAddress(address user, uint256 poolIndex)
        external
        view
        returns (address);

    function userVotingPoolCount(address user) external view returns (uint256);

    function claimRewardAll() external;

    function removeAllVoting() external;
}
