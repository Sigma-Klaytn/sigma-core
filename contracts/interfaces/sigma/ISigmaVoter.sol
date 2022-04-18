//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISigmaVoter {
    function currentVotes()
        external
        view
        returns (address[] memory pools, int256[] memory weights);
}
