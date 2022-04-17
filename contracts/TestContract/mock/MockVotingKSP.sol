//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/klayswap/IVotingKSP.sol";

//I made this contract for the test since the original source code is not available for now.
//It contains simple code.

//[Features]
//1. ERC20 Token
//2. Lock Token
//3. Get Locked KSP amount
contract MockVotingKSP is IERC20, IVotingKSP {
    string public constant name = "Voting KlaySwap Protocol";
    string public constant symbol = "vKSP";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override(IVotingKSP, IERC20) balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    //ksp
    IERC20 public immutable kspToken;

    struct Item {
        uint256 amount;
        uint256 lockePeriodRequest;
        uint256 mintedvKSP;
    }

    mapping(address => Item) public KSPVault;

    event LockedToken(
        address user,
        uint256 amount,
        uint256 lockPeriodRequested
    );

    constructor(IERC20 _kspToken) {
        kspToken = _kspToken;
    }

    //amount 는 정수로 들어온다. amount:1 은 1KSP 를 의미 함.
    function lockKSP(uint256 amount, uint256 lockPeriodRequested) external {
        require(amount > 0, "Amount should be bigger than 0");
        require(
            lockPeriodRequested > 0,
            "LockPErioudRequested should be bigger than 0"
        );

        kspToken.transferFrom(msg.sender, address(this), (amount * 1 ether));

        KSPVault[msg.sender].amount = amount * 1 ether;
        KSPVault[msg.sender].lockePeriodRequest = lockPeriodRequested;

        //원래는 lockedPEriodRequested 마다 다 vKSP 양이 다르지만 시그마에서는 최대로 하므로 v8KSP 라고 가정
        _mint(msg.sender, amount * 8 ether);

        KSPVault[msg.sender].mintedvKSP = amount * 8 ether;

        emit LockedToken(msg.sender, amount * 1 ether, lockPeriodRequested);
    }

    function lockedKSP(address account) external view returns (uint256) {
        Item memory item = KSPVault[account];
        return item.amount;
    }

    function _mint(address _user, uint256 _amount) internal {
        balanceOf[_user] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _user, _amount);
    }

    function approve(address _spender, uint256 _value)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /** shared logic for transfer and transferFrom */
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

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function unlockKSP() external override {}

    function refixBoosting(uint256 lockPeriodRequested) external override {}

    function claimReward() external override {}

    function getCurrentBalance(address account)
        external
        view
        returns (uint256)
    {}

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        require(
            allowance[_from][msg.sender] >= _value,
            "Insufficient allowance"
        );
        if (allowance[_from][msg.sender] != type(uint256).max) {
            allowance[_from][msg.sender] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }
}
