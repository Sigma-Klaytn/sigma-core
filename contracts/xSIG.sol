//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract xSIG is IERC20, Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public SIG;
    uint256 public lockingPeriod;

    struct WithdrawInfo {
        uint256 unlockTime;
        uint256 xSIGAmount;
        uint256 SIGAmount;
        bool isClaimed;
    }

    mapping(address => WithdrawInfo[]) withdrawInfoOf;

    /* ========== Token Related ========== */

    string public constant name = "Sigma Compounding Token"; // Can be change
    string public constant symbol = "xSIG";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor() {}

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

    /* ========== External Function  ========== */

    /**
        @notice stake SIG for xSIG
        @param _amount The amount of SIG to deposit
     */
    function stake(uint256 _amount) external {}

    /**
        @notice Return xSIG for SIG which is compounded over time. It needs unlocking period.
        @param _amount The amount of xSIG to redeem
     */
    function unstake(uint256 _amount) external {}

    /**
        @notice Claim SIG which unlocking period has been ended. 
     */
    function claimUnlockedSIG() external {}

    /* ========== Internal Function  ========== */

    /**
        @notice Mint xSIG
        @param _receiver The address which you want to send tokens to
        @param _amount The amount of tokens to be minted and sended to the receiver
     */
    function _mint(address _receiver, uint256 _amount) internal {}

    /* ========== Restricted Function  ========== */

    function setLockingPeriod(uint256 _lockingPeriod) external onlyOwner {
        lockingPeriod = _lockingPeriod;
    }

    function setInitialInfo(address _SIG, uint256 _lockingPeriod)
        external
        onlyOwner
    {
        SIG = IERC20(_SIG);
        lockingPeriod = _lockingPeriod;
    }

    /* ========== View Function  ========== */
    /**
        @notice Compute Withdrawable SIG at given time.
     */
    function computeWithdrawableSIG(address _user, uint256 _currentTime)
        external
    {}
}
