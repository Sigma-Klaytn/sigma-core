//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/klayswap/IVotingKSP.sol";

contract KSPVault {
    IVotingKSP public votingKSP;

    constructor(address _votingKSP) {
        votingKSP = IVotingKSP(_votingKSP);
    }

    event LOCK_KSP(uint256 amount, uint256 lockPeriodRequested);

    function lockKSP(uint256 _amount, uint256 _lockPeriodRequested) external {
        votingKSP.lockKSP(_amount, _lockPeriodRequested);
        emit LOCK_KSP(_amount, _lockPeriodRequested);
    }

    function approveToken(
        address _token,
        address to,
        uint256 _amount
    ) external {
        IERC20(_token).approve(to, _amount);
    }

    function transferToken(
        address _token,
        address _to,
        uint256 _amount
    ) external {
        IERC20(_token).transfer(_to, _amount);
    }

    function lockedKSP(address addr) external view returns (uint256) {
        return votingKSP.lockedKSP(addr);
    }
}
