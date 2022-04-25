//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IFactory {
    function exchangeKctPos(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external;

    function estimatePos(
        address inToken,
        uint256 inAmount,
        address outToken
    ) external view returns (uint256);
}
