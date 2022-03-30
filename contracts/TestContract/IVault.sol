//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {
    function lockTokens(
        IERC20 _token,
        address _withdrawer,
        uint256 _amount,
        uint256 _unlockTimestamp
    ) external returns (uint256 _id);

    function getVaultsByWithdrawer(address _withdrawer)
        external
        view
        returns (uint256[] memory);

    function withdrawTokens(uint256 _id) external;
}
