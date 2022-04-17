//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/klayswap/IVotingKSP.sol";
import "../interfaces/klayswap/IPoolVoting.sol";

contract KSPVault {
    IVotingKSP public votingKSP;
    IPoolVoting public poolVoting;
    IERC20 public KSP;

    constructor(
        address _votingKSP,
        address _KSP,
        address _poolVoting
    ) {
        votingKSP = IVotingKSP(_votingKSP);
        KSP = IERC20(_KSP);
        poolVoting = IPoolVoting(_poolVoting);
    }

    event LOCK_KSP(uint256 amount, uint256 lockPeriodRequested);

    function lockKSP(uint256 _amount, uint256 _lockPeriodRequested) external {
        KSP.approve(address(votingKSP), type(uint256).max);
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

    function addVoting(address exchange, uint256 amount) public {
        poolVoting.addVoting(exchange, amount);
    }

    // function transfer(address _to, uint256 _amount) external {
    //     IERC20(_token).transfer(_to, _amount);
    // }

    function removeVoting(address exchange, uint256 amount) public {
        poolVoting.removeVoting(exchange, amount);
    }

    function poolVotingClaimReward(address exchange) public {
        poolVoting.claimReward(exchange);
    }

    function votingKSPClaimReward() public {
        votingKSP.claimReward();
    }

    function unlockKSP() public {
        votingKSP.unlockKSP();
    }

    function refixBoosting(uint256 lockPeriodRequested) public {
        votingKSP.refixBoosting(lockPeriodRequested);
    }
}
