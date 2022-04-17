// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @dev Interface of the VePtp
 */
interface IxSIGFarm {
    function isUser(address _addr) external view returns (bool);

    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

    function claim() external;

    function getStakedXSIG(address _addr) external view returns (uint256);

    function startTime() external view returns (uint256);
}
