//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IUtils {
    function getPoolData(address lp)
        external
        view
        returns (
            uint256 miningRate,
            uint256 rateDecimals,
            address tokenA,
            uint256 reserveA,
            address tokenB,
            uint256 reserveB,
            uint256 airdropCount,
            address[] memory airdropTokens,
            uint256[] memory airdropSettings
        );
}
