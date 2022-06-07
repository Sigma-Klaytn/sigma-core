//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISigmaVoter {
    function getCurrentVotes()
        external
        view
        returns (
            uint256 weightsTotal,
            address[] memory pools,
            uint256[] memory weights
        );

    function getUserVotesCount(address _user) external view returns (uint256);

    function deleteAllPoolVote() external;
}
