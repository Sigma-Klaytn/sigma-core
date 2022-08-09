//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IKlayswapGovernor {
    function castVote(uint256 proposalId, bool support) external;
}
