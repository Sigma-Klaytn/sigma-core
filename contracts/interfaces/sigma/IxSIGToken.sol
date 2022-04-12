//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IxSIGToken is IERC20 {
    function mint(address _to, uint256 _value) external returns (bool);

    function burn(uint256 _value) external returns (bool);
}
