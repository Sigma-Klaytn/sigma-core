//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../interfaces/klayswap/IExchange.sol";

contract TreasuryV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IExchange public exchange;

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
        @notice Receive Klay
     */
    receive() external payable {}

    /**
     * @notice Used to initialize a new Treasury contract
     */
    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
    }

    /**
        @notice restrict upgrade to only owner.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}

    function setInitialInfo(IExchange _exchange) external onlyOwner {
        exchange = _exchange;
    }

    /**
     * @notice Transfers an amount of an ERC20 from this contract to an address
     *
     * @param _token address of the ERC20 token
     * @param _to address of the receiver
     * @param _amount amount of the transaction
     */
    function transferERC20(
        IERC20Upgradeable _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        _token.safeTransfer(_to, _amount);

        emit TransferERC20(address(_token), _to, _amount);
    }

    function approveToken(address _token, address _to) external onlyOwner {
        IERC20Upgradeable(_token).approve(address(_to), type(uint256).max);
    }

    /**
        @notice Withdraw the contract's KSUDT balance at the end of the launch.
     */
    function transferKlay(address _to, uint256 _amount) external onlyOwner {
        uint256 balanceOfKLAY = address(this).balance;
        require(
            balanceOfKLAY >= _amount,
            "There is no withdrawable amount of KLAY"
        );

        payable(_to).transfer(_amount);
        emit TransferKlay(_to, _amount);
    }

    function claimLPReward() external onlyOwner {
        exchange.claimReward();
    }
}
