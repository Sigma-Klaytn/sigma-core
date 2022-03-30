//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../dependencies/Ownable.sol";
import "../dependencies/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSale is Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public SIG;
    bool public tokensReleased;
    uint256 totalToken;
    uint256 totalDeposit;
    mapping(address => DepositInfo) depositOf;

    struct DepositInfo {
        uint256 amount;
        bool withdrewAtPhase2;
        bool tokensClaimed;
    }

    uint256 public immutable HOUR = 3600;

    /**
        @notice Deposit KUSDT into this contract, only allowed during Phase1.
     */
    function deposit(uint256 amount) external {}

    /**
        @notice Withdraw KUSDT from this contract, allowed during Phase1 and Phase2.
     */
    function withdraw(uint256 amount) external {}

    /**
        @notice Withdraw pro-rata allocated SIG tokens, only allowed at the end of the launch (after Phase2).
     */
    function withdrawTokens() external {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
        @notice Initialize the contract's basic config parameters, which contains 
        1) Total SIG distribution amount
        2) The phase start/end timestamps. 
     */
    function setInitialInfo() external onlyOwner {}

    /**
        @notice Withdraw the contract's KSUDT balance at the end of the launch.
     */
    function adminWithdraw() external onlyOwner {}

    /**
        @notice Allows depositors to claim their share of the tokens.
     */
    function releaseToken() external onlyOwner {}
}
