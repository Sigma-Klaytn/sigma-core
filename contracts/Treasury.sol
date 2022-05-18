//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.9;

import "./dependencies/Ownable.sol";
import "./dependencies/SafeERC20.sol";

contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    /**
     * @notice Triggered when an amount of an ERC20 has been transferred from this contract to an address
     *
     * @param token               ERC20 token address
     * @param to                  Address of the receiver
     * @param amount              Amount of the transaction
     */
    event TransferERC20(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    /**
     * @notice Triggered when an amount of an klay has been transferred from this contract to an address
     *
     * @param to                  Address of the receiver
     * @param amount              Amount of the transaction
     */
    event TransferKlay(address indexed to, uint256 amount);

    /**
     * @notice Used to initialize a new Treasury contract
     */
    function initialize() public onlyOwner {}

    /**
     * @notice Transfers an amount of an ERC20 from this contract to an address
     *
     * @param _token address of the ERC20 token
     * @param _to address of the receiver
     * @param _amount amount of the transaction
     */
    function transfer(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        _token.safeTransfer(_to, _amount);

        emit TransferERC20(address(_token), _to, _amount);
    }

    /**
        @notice Withdraw the contract's KSUDT balance at the end of the launch.
     */
    function klayWithdraw(address _to, uint256 _amount) external onlyOwner {
        uint256 balanceOfKLAY = address(this).balance;
        require(
            balanceOfKLAY > _amount,
            "There is no withdrawable amount of KLAY"
        );

        payable(_to).transfer(_amount);

        emit TransferKlay(_to, _amount);
    }
}
