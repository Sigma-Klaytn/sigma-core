//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "./dependencies/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/sigma/ISigKSPStaking.sol";
import "./interfaces/sigma/ISigFarm.sol";
import "./interfaces/klayswap/IFactory.sol";
import "./interfaces/klayswap/IExchange.sol";

contract FeeDistributor is Ownable {
    using SafeERC20 for IERC20;

    ISigKSPStaking public sigKSPStaking;
    address public treasury;
    ISigFarm public sigFarm;
    IFactory public factory;
    IExchange public exchange;
    IERC20 public kusdt;
    IERC20 public sig;
    IERC20 public ksp;

    mapping(address => bool) public operators;

    // Voting Fee allocation
    uint256 public constant ALLOC_TOTAL = 1000;
    uint256 public ALLOC_TREASURY = 700;
    uint256 public ALLOC_SIGKSP_STAKING = 250;
    uint256 public ALLOC_SIG_FARM = 50;

    /* ========== Public | External Function  ========== */

    /**
        @notice Receive Klay
     */
    receive() external payable {}

    /**
        @notice Deposit protocol fees into the contract, to be distributed to lockers
        @dev Caller must have given approval for this contract to transfer `_token`
        @param _token Token being deposited
        @param _amount Amount of the token to deposit
     */
    function depositERC20(address _token, uint256 _amount) external {
        require(_amount > 0, "Deposit amount should be bigger than 0.");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function depositKlay() external payable {
        uint256 _amount = msg.value;
        require(_amount > 0, "Deposit Amount should be bigger than 0");
    }

    /* ========== Restricted Function  ========== */

    /**
     @notice Approve contracts to mint and renounce ownership
     */
    function setOperator(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators[_operators[i]] = true;
        }
    }

    /**
     @notice Revoke authority to mint and burn the given token.
     */
    function revokeOperator(address _operator) external onlyOwner {
        require(operators[_operator], "This address is not an operator");
        operators[_operator] = false;
    }

    function setInitialInfo(
        ISigKSPStaking _sigKSPStaking,
        address _treasury,
        ISigFarm _sigFarm,
        IFactory _factory,
        IExchange _exchange,
        IERC20 _kusdt,
        IERC20 _sig,
        IERC20 _ksp
    ) external onlyOwner {
        sigKSPStaking = _sigKSPStaking;
        treasury = _treasury;
        sigFarm = _sigFarm;
        kusdt = _kusdt;
        factory = _factory;
        exchange = _exchange;
        sig = _sig;
        ksp = _ksp;

        // approve
        kusdt.approve(address(factory), type(uint256).max);
        kusdt.approve(address(exchange), type(uint256).max);
        sig.approve(address(exchange), type(uint256).max);
        sig.approve(address(sigFarm), type(uint256).max);
    }

    function distributeSIG(uint256 _amount) external onlyOperator {
        uint256 sigBalance = sig.balanceOf(address(this));
        require(sigBalance >= _amount, "No sig to distribute");

        uint256 sigFarmAllocAmount = (_amount * ALLOC_SIG_FARM * 1e5) /
            (ALLOC_SIG_FARM + ALLOC_SIGKSP_STAKING);
        uint256 sigKSPStakingAllocAmount = (_amount *
            ALLOC_SIGKSP_STAKING *
            1e5) / (ALLOC_SIG_FARM + ALLOC_SIGKSP_STAKING);

        require(
            sigFarmAllocAmount > 0,
            "sigFarmAllocAmount should be bigger than 0."
        );
        require(
            sigKSPStakingAllocAmount > 0,
            "sigKSPStakingAllocAmount should be bigger than 0."
        );

        sigFarm.depositFee(sigFarmAllocAmount / 1e5);
        sig.safeTransfer(
            address(sigKSPStaking),
            sigKSPStakingAllocAmount / 1e5
        );
        sigKSPStaking.updateRewardAmount();
    }

    function distributeKSP(uint256 _amount) external onlyOperator {
        uint256 kspBalance = ksp.balanceOf(address(this));
        require(_amount >= kspBalance, "insufficient ksp balance");
        ksp.safeTransfer(address(sigKSPStaking), _amount);
        sigKSPStaking.updateRewardAmount();
    }

    function distributeLP(
        IERC20 lp,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        uint256 lpBalance = lp.balanceOf(address(this));
        require(_amount >= lpBalance, "insufficient lp balance");
        lp.safeTransfer(_to, lpBalance);
    }

    /**
     * @notice Transfers an amount of an ERC20 from this contract to an address
     *
     * @param _token address of the ERC20 token
     * @param _to address of the receiver
     * @param _amount amount of the transaction
     */
    function transferERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOperator {
        _token.safeTransfer(_to, _amount);
    }

    function transferKlay(address _to, uint256 _amount) external onlyOperator {
        uint256 balanceOfKLAY = address(this).balance;
        require(
            balanceOfKLAY > _amount,
            "There is no withdrawable amount of KLAY"
        );

        payable(_to).transfer(_amount);
    }

    function setVotingFeeAlloc(
        uint256 _ALLOC_TREASURY,
        uint256 _ALLOC_SIGKSP_STAKING,
        uint256 _ALLOC_SIG_FARM
    ) external onlyOwner {
        require(
            _ALLOC_TREASURY + _ALLOC_SIGKSP_STAKING + _ALLOC_SIG_FARM ==
                ALLOC_TOTAL,
            "ALLOC_TOTAL should be 1000"
        );
        ALLOC_TREASURY = _ALLOC_TREASURY;
        ALLOC_SIGKSP_STAKING = _ALLOC_SIGKSP_STAKING;
        ALLOC_SIG_FARM = _ALLOC_SIG_FARM;
    }

    //IFactory
    function exchangeKlayPos(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable onlyOperator {
        factory.exchangeKlayPos(token, amount, path);
    }

    function exchangeKlayNeg(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable onlyOperator {
        factory.exchangeKlayNeg(token, amount, path);
    }

    function exchangeKctNeg(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external onlyOperator {
        factory.exchangeKctNeg(tokenA, amountA, tokenB, amountB, path);
    }

    function exchangeKctPos(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external onlyOperator {
        factory.exchangeKctPos(tokenA, amountA, tokenB, amountB, path);
    }

    //IExchange : create SIG/KUSDT LP

    function addKctLiquidity(uint256 amountA, uint256 amountB)
        external
        onlyOperator
    {
        exchange.addKctLiquidity(amountA, amountB);
    }

    function addKctLiquidityWithLimit(
        uint256 amountA,
        uint256 amountB,
        uint256 minAmountA,
        uint256 minAmountB
    ) external onlyOperator {
        exchange.addKctLiquidityWithLimit(
            amountA,
            amountB,
            minAmountA,
            minAmountB
        );
    }

    function approveToken(address _token, address _to) external onlyOperator {
        IERC20(_token).approve(address(_to), type(uint256).max);
    }

    // Modifier
    modifier onlyOperator() {
        require(operators[msg.sender], "This address is not an operator");
        _;
    }
}
