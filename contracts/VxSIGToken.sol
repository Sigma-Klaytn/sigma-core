// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./interfaces/sigma/IvxERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title VxSIG
/// @notice Modified version of ERC20 where transfers and allowances are disabled.
contract vxSIGToken is IvxERC20, Ownable {
    string public constant name = "Sigma Voting Power Token"; // Can be modified.
    string public constant symbol = "vxSIG";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) public operators;
    /**
     * @dev Emitted when `value` tokens are burned and minted
     */
    event Burn(address indexed account, uint256 value);
    event Mint(address indexed beneficiary, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
        @notice Approve contracts to mint and burn the given token.
        @dev In production the only minters should be `xSIGFarm`
             Addresses are given via dynamic array to allow extra minters during testing
     */
    function setOperator(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators[_operators[i]] = true;
        }
    }

    /**
        @notice Revoke authority to mint and burn the given token.
     */
    function revokeOperator(address _operator) external onlyOwner {
        require(operators[_operator], "This address is not an operator");
        operators[_operator] = false;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function mint(address account, uint256 amount) external override {
        require(operators[msg.sender], "Not a operators");
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Mint(account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 amount) external override {
        require(operators[msg.sender], "Not a operators");
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balanceOf[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Burn(account, amount);
    }
}
