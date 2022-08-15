// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KlayswapEscrowGovernTest {
    address public kga;
    address public klayswapGovernor;
    event CastVote(uint256 proposalId, bool support);

    function setKlayswapGoverAddr(address _addr) public {
        kga = _addr;
    }

    function setklayswapGovernorAddr(address _addr) public {
        klayswapGovernor = _addr;
    }

    function castVote(uint256 proposalId, bool support) external {
        require(msg.sender == kga, "caller is not kga");
        emit CastVote(proposalId, support);
    }
}

interface IKlayswapGovern {
    function cancelUserVotes(address _user) external;
}

contract xSIGFarmGovernTest {
    IKlayswapGovern public kga;

    function setKlayswapGov(address _addr) public {
        kga = IKlayswapGovern(_addr);
    }

    function unstake() external {
        // it goes to 0
        kga.cancelUserVotes(msg.sender);
    }
}

contract BlockNumber {
    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}
