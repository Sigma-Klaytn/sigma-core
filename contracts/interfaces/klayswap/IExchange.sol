//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IExchange {
    function claimReward() external;

    function addKctLiquidity(uint256 amountA, uint256 amountB) external;

    function addKctLiquidityWithLimit(
        uint256 amountA,
        uint256 amountB,
        uint256 minAmountA,
        uint256 minAmountB
    ) external;

    function estimatePos(address token, uint256 amount)
        external
        view
        returns (uint256);
}
