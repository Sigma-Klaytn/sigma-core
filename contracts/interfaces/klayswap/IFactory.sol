//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IFactory {
    function createKctPool(address tokenA, uint amountA, address tokenB, uint amountB, uint fee) external;
    function exchangeKctPos(address tokenA, uint amountA, address tokenB, uint amountB, address[] memory path) external;
}