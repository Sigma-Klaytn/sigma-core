//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFeeDistributor {
    function depositERC20(address _token, uint256 _amount) external;

    function depositKlay() external payable;
}
