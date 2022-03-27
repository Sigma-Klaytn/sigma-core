//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/klayswap/IVotingKSP.sol";

contract KSPConverter is IERC20, Ownable {
    string public constant name = "sigKSP: Tokenized vKSP";
    string public constant symbol = "sigKSP";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    //KSP contracts
    IERC20 public immutable kspToken;
    IVotingKSP public immutable votingKSP;

    uint256 public constant MAX_LOCK_PERIOD = 1555200000;

    event DepositKSP(address depositer, uint256 amount);

    constructor(IERC20 _kspToken, IVotingKSP _votingKSP) {
        kspToken = _kspToken;
        votingKSP = _votingKSP;

        //approve VotingKSP to transfer KSP
        _kspToken.approve(address(_votingKSP), type(uint256).max);
    }

    function setAddresses() external onlyOwner {
        //do something
        renounceOwnership();
    }

    // [start of] token
    function approve(address _spender, uint256 _value)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool) {
        require(allowance[_from][msg.sender] >= _value, "Insufficient balance");
        if (allowance[_from][msg.sender] != type(uint256).max) {
            //TODO: for what?
            allowance[_from][msg.sender] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    function _mint(address _user, uint256 _amount) internal {
        balanceOf[_user] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _user, _amount);
    }

    //[end] of token

    /**
        @notice Deposit KSP and get sigKSP in return. sigKSP is Tokenized vKSP.
        @param _amount Amount of ksp to deposit. The unit is 10^18.
     */
    function depositKSP(uint256 _amount) external returns (bool) {
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);
        _mint(msg.sender, _amount * 8 ether);

        emit DepositKSP(msg.sender, _amount * 1 ether);

        return true;
    }
}
