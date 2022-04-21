//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISigmaVoter {
    function getCurrentVotes()
        external
        view
        returns (address[] memory pools, uint256[] memory weights);
}
