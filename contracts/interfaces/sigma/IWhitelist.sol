// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IWhitelist {
    function approveWallet(address _wallet) external;

    function revokeWallet(address _wallet) external;

    function check(address _wallet) external view returns (bool);
}
