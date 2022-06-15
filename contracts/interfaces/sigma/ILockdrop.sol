//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ILockdrop {
    // struct DepositInfo {
    //     uint256 amount; // deposited KSP amount
    //     uint256 weight; // weight = lockMonth * amount
    //     uint256 lockMonth; // locked month
    //     uint256 claimedSIG; // released amount sig
    //     bool withdrewAtPhase2; // if it's withdrawn at phase 2
    //     bool isLPTokensClaimed;
    // }

    function depositOf(address _addr)
        external
        view
        returns (
            uint256, // deposited KSP amount
            uint256, // weight = lockMonth * amount
            uint256, // locked month
            uint256, // released amount sig
            bool, // if it's withdrawn at phase 2
            bool
        );

    function getWithdrawableLPTokenAmount() external view returns (uint256);
}
