//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "./dependencies/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/sigma/ISigKSPStaking.sol";

contract FeeDistributor is Ownable {
    using SafeERC20 for IERC20;

    ISigKSPStaking sigKSPStaking;

    function setInitialInfo(ISigKSPStaking _sigKSPStaking) external onlyOwner {
        sigKSPStaking = _sigKSPStaking;
    }

    // array of all fee tokens that have been added
    address[] public feeTokens;
    // private mapping for tracking which addresses were added to `feeTokens`
    mapping(address => bool) seenFees;

    event FeesReceived(
        address indexed caller,
        address indexed token,
        uint256 indexed week,
        uint256 amount
    );
    event FeesClaimed(
        address indexed caller,
        address indexed receiver,
        address indexed token,
        uint256 amount
    );

    function feeTokensLength() external view returns (uint256) {
        return feeTokens.length;
    }

    /**
        @notice Deposit protocol fees into the contract, to be distributed to lockers
        @dev Caller must have given approval for this contract to transfer `_token`
        @param _token Token being deposited
        @param _amount Amount of the token to deposit
     */
    function depositFee(address _token, uint256 _amount)
        external
        returns (bool)
    {
        if (_amount > 0) {
            if (!seenFees[_token]) {
                seenFees[_token] = true;
                feeTokens.push(_token);
            }
            uint256 received = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
            received = IERC20(_token).balanceOf(address(this)) - received;
            // uint256 week = getWeek();
            // weeklyFeeAmounts[_token][week] += received;
            // emit FeesReceived(msg.sender, _token, week, _amount);
        }
        return true;
    }

    /**
        @notice Deposit ksp staking fees into the contract, and forward it to sigKSP staking vault.
        @param _amount _amount of KSP to send.
     */
    function depositKSPToSigKSPVault(address _ksptoken, uint256 _amount)
        external
    {
        require(_amount > 0, "Amount of KSP should be bigger than 0");
        IERC20(_ksptoken).safeTransferFrom(
            msg.sender,
            address(sigKSPStaking),
            _amount
        );

        sigKSPStaking.updateRewardAmount();
    }

    function depositFees(address[] memory _tokens, uint256[] memory _amounts)
        external
    {
        // 1. 30% change to SIG
        // 1-1. 25% send to sigKSP staking vault.
        // 1-2. 5% send to SIG staking vault.
        // 2. 70% change to SIG / KUSDT LP
        // 2-1. send to treasury.
    }

    function depositKlay(address _forwardingTo) external {
        //some case returns klay.. what you going to do with it?
    }

    function swapToKUSDT(address _pool, uint256 amount)
        external
        returns (uint256 kusdtAmount)
    {}

    function swapToSig(uint256 amount) internal returns (uint256 sigAmount) {}

    function swapToSigLP(uint256 amount)
        internal
        returns (uint256 lpTokenAmount)
    {}
}
