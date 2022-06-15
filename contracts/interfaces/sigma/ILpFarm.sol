//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ILpFarm {
    function updateBoostWeight() external;

    function forwardLpTokensFromLockdrop(
        address _user,
        uint256 _amount,
        uint256 _lockingPeriod
    ) external;
}
