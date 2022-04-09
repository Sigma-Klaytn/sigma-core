//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract xSIG is IERC20, Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public SIG;
    uint256 public lockingPeriod;
    uint256 public pendingxSIG;
    uint256 public pendingSIG;

    struct WithdrawInfo {
        uint256 unlockTime;
        uint256 xSIGAmount;
        uint256 SIGAmount;
        bool isWithdrawn;
    }

    mapping(address => WithdrawInfo[]) withdrawInfoOf;

    event Unstake(uint256 RedeemedxSIG, uint256 sigQueued);
    event ClaimUnlockedSIG(uint256 withdrawnSIG, uint256 burnedSIG);
    event Stake(uint256 stakedSIG, uint256 mintedxSIG);

    /* ========== Token Related ========== */

    string public constant name = "Sigma Compounding Token"; // Can be modified.
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

    //TODO: external?
    /**
        @notice Mint xSIG
        @param amount The amount of tokens to be minted and sended to the receiver
     */
    function mint(uint256 amount) internal {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    //TODO: external?
    function burn(uint256 amount) internal {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    /* ========== External Function  ========== */

    /**
        @notice stake SIG for xSIG
        @param _amount The amount of SIG to deposit
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Stake SIG amount should be bigger than 0");
        SIG.transferFrom(msg.sender, address(this), _amount);
        uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG - _amount;
        uint256 xSIGAmount = totalSupply - pendingxSIG;

        uint256 xSIGToGet;
        if (sigAmount == 0) {
            xSIGToGet = _amount;
        } else {
            xSIGToGet = (_amount * xSIGAmount * 1e18) / sigAmount;
            xSIGToGet /= 1e18;
        }

        mint(xSIGToGet);

        emit Stake(_amount, xSIGToGet);
    }

    /**
        @notice Return xSIG for SIG which is compounded over time. It needs unlocking period.
        @param _amount The amount of xSIG to redeem
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Redeem xSIG should be bigger than 0");
        uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG;
        uint256 xSIGAmount = totalSupply - pendingxSIG;

        uint256 sigToReturn = (_amount * sigAmount * 1e18) / xSIGAmount;
        uint256 endTime = block.timestamp + lockingPeriod;

        withdrawInfoOf[msg.sender].push(
            WithdrawInfo({
                unlockTime: endTime,
                xSIGAmount: _amount,
                SIGAmount: sigToReturn / 1e18,
                isWithdrawn: false
            })
        );

        pendingSIG += sigToReturn;
        pendingxSIG += _amount;

        emit Unstake(_amount, sigToReturn);
    }

    /**
        @notice Claim SIG which unlocking period has been ended. 
        TODO: NEED TO DO GAS OPTIMIZATION
     */
    function claimUnlockedSIG() external {
        (
            uint256 withdrawableSIG,
            uint256 totalBurningxSIG
        ) = _computeWithdrawableSIG(msg.sender);
        require(withdrawableSIG > 0, "This address has no withdrawalbe SIG");

        burn(totalBurningxSIG);
        SIG.transferFrom(address(this), msg.sender, withdrawableSIG);

        emit ClaimUnlockedSIG(withdrawableSIG, totalBurningxSIG);
    }

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

    /* ========== Internal Function  ========== */
    function _computeWithdrawableSIG(address _user)
        internal
        returns (uint256, uint256)
    {
        WithdrawInfo[] storage withdrawableInfos = withdrawInfoOf[_user];
        uint256 withdrawableSIG = 0;
        uint256 totalBurningxSIG = 0;

        for (uint256 i = 0; i < withdrawableInfos.length; i++) {
            WithdrawInfo storage withdrawInfo = withdrawableInfos[i];
            if (!withdrawInfo.isWithdrawn) {
                if (withdrawInfo.unlockTime < block.timestamp) {
                    withdrawableSIG += withdrawInfo.SIGAmount;
                    totalBurningxSIG += withdrawInfo.xSIGAmount;
                    withdrawInfo.isWithdrawn = true;
                }
            }
        }

        if (withdrawableSIG != 0 && totalBurningxSIG != 0) {
            pendingSIG -= withdrawableSIG;
            pendingxSIG -= totalBurningxSIG;
        }
        return (withdrawableSIG, totalBurningxSIG);
    }

    /* ========== View Function  ========== */
    /**
        @notice Compute Withdrawable SIG at given time.
     */

    function getRedeemableSIG() external view returns (uint256) {
        WithdrawInfo[] memory withdrawableInfos = withdrawInfoOf[msg.sender];
        uint256 withdrawableSIG;

        for (uint256 i = 0; i < withdrawableInfos.length; i++) {
            WithdrawInfo memory withdrawInfo = withdrawableInfos[i];
            if (!withdrawInfo.isWithdrawn) {
                if (withdrawInfo.unlockTime < block.timestamp) {
                    withdrawableSIG += withdrawInfo.SIGAmount;
                }
            }
        }
        return withdrawableSIG;
    }

    /**
        @notice You should devide return value by 10^7 to get a percentage.
     */
    function getxSIGExchangeRate() external view returns (uint256) {
        uint256 sigAmount = SIG.balanceOf(address(this)) - pendingSIG;
        uint256 xSIGAmount = totalSupply - pendingxSIG;

        return (sigAmount * 1e7) / xSIGAmount;
    }
}
