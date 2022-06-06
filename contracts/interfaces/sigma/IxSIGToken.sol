//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IxSIGToken is IERC20Upgradeable {
    function mint(address _to, uint256 _value) external returns (bool);

    function burn(address _from, uint256 _value) external returns (bool);
}
