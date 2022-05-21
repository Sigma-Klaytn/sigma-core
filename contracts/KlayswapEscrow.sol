//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/klayswap/IVotingKSP.sol";
import "./interfaces/klayswap/IPoolVoting.sol";
import "./interfaces/sigma/ISigmaVoter.sol";
import "./interfaces/klayswap/IFactory.sol";
import "./interfaces/sigma/ISigKSPStaking.sol";
import "./interfaces/sigma/IFeeDistributor.sol";

contract KlayswapEscrow is IERC20, Ownable {
    string public constant name = "sigKSP: Tokenized vKSP";
    string public constant symbol = "sigKSP";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    //KSP contracts
    IERC20 public kspToken;
    IERC20 public kusdtToken;

    IVotingKSP public votingKSP;
    IPoolVoting public poolVoting;
    IFactory public factory;

    ISigmaVoter public sigmaVoter;
    ISigKSPStaking public sigKSPStaking;
    IFeeDistributor public feeDistributor;

    uint256 public constant MAX_LOCK_PERIOD = 1555200000;

    mapping(address => bool) public operators;

    event DepositKSP(address depositer, uint256 amount);
    event ForwardedFee(uint256 kspAmount, uint256 kusdtAmount);
    event Voted(address pool, uint256 amount);

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
        IERC20 _kspToken,
        IERC20 _kusdtToken,
        IVotingKSP _votingKSP,
        IPoolVoting _poolVoting,
        ISigmaVoter _sigmaVoter,
        ISigKSPStaking _sigKSPStaking,
        IFactory _factory,
        IFeeDistributor _feeDistributor
    ) external onlyOwner {
        kspToken = _kspToken;
        kusdtToken = _kusdtToken;
        votingKSP = _votingKSP;
        poolVoting = _poolVoting;
        sigmaVoter = _sigmaVoter;
        sigKSPStaking = _sigKSPStaking;
        factory = _factory;
        feeDistributor = _feeDistributor;

        kspToken.approve(address(votingKSP), type(uint256).max);
        kusdtToken.approve(address(feeDistributor), type(uint256).max);
        kspToken.approve(address(feeDistributor), type(uint256).max);
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

    /* ========== Public | External Function  ========== */

    /**
        @notice Deposit KSP and get sigKSP in return. sigKSP is Tokenized vKSP.
     */
    receive() external payable {}

    /**
        @notice Deposit KSP and get sigKSP in return. sigKSP is Tokenized vKSP.
        @param _amount Amount of ksp to deposit. The unit is 10^18.
     */
    function depositKSP(uint256 _amount) external returns (bool) {
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);
        _mint(msg.sender, _amount * 1 ether);

        emit DepositKSP(msg.sender, _amount * 1 ether);

        return true;
    }

    function forwardFeeToFeeDistributor() external onlyOperator {
        uint256 kspTokenBalance = kspToken.balanceOf(address(this));
        uint256 kusdtTokenBalance = kusdtToken.balanceOf(address(this));

        if (kspTokenBalance > 0) {
            feeDistributor.depositERC20(address(kspToken), kspTokenBalance);
        }

        if (kusdtTokenBalance > 0) {
            feeDistributor.depositERC20(address(kusdtToken), kusdtTokenBalance);
        }

        emit ForwardedFee(kspTokenBalance, kusdtTokenBalance);
    }

    /* ========== Restricted Function  ========== */

    // IVotingKSP

    /**
        @notice It gets KSP from VotingKSP.sol.
     */
    function claimVotingKSPReward() external onlyOperator {
        votingKSP.claimReward();
    }

    // IPoolVoting

    /**
        @notice Submit vote to klayswap.
        @param exchange : Pool address. 
        @param amount : The amount can be entered in integer units  
     */
    function _addVoting(address exchange, uint256 amount) internal {
        poolVoting.addVoting(exchange, amount);
        emit Voted(exchange, amount);
    }

    /**
        @notice Submit votes to klayswap. This will be called regulary by sigma-bot.
     */
    function addAllVotings() external onlyOperator {
        (
            uint256 weightsTotal,
            address[] memory pools,
            uint256[] memory weights
        ) = sigmaVoter.getCurrentVotes();
        require(
            pools.length == weights.length,
            "Pool length and weight length do not match."
        );
        require(pools.length > 0, "Voting arrays are empty.");

        uint256 vKspBalance = votingKSP.balanceOf(address(this)); //in wei
        uint256 usedVKsp = 0;
        for (uint256 i = 0; i < pools.length; i++) {
            address pool = pools[i];
            uint256 voteWeight = weights[i];

            uint256 kspVoteWeight = ((vKspBalance * voteWeight) /
                weightsTotal) / 1e18;
            if (kspVoteWeight != 0) {
                _addVoting(pool, kspVoteWeight);
                usedVKsp += kspVoteWeight;
            }
        }

        if (vKspBalance / 1e18 > 0) {
            if (vKspBalance / 1e18 - usedVKsp > 0) {
                uint256 leftvKSP = vKspBalance / 1e18 - usedVKsp;
                _addVoting(pools[pools.length - 1], leftvKSP);
            }
        }
    }

    function removeVoting(address exchange, uint256 amount)
        external
        onlyOperator
    {
        poolVoting.removeVoting(exchange, amount);
    }

    function claimPoolVotingReward(address exchange) external onlyOperator {
        poolVoting.claimReward(exchange);
    }

    /**
        @notice Method of all vote pool’s transaction fee reward 
     */
    function claimPoolVotingRewardAll() external onlyOperator {
        poolVoting.claimRewardAll();
    }

    function removeAllVoting() external onlyOperator {
        poolVoting.removeAllVoting();
    }

    function userVotingPoolAmount(address user, uint256 poolIndex)
        external
        view
        returns (uint256)
    {
        return poolVoting.userVotingPoolAmount(user, poolIndex);
    }

    function userVotingPoolAddress(address user, uint256 poolIndex)
        external
        view
        returns (address)
    {
        return poolVoting.userVotingPoolAddress(user, poolIndex);
    }

    function userVotingPoolCount(address user) external view returns (uint256) {
        return poolVoting.userVotingPoolCount(user);
    }

    // IFactory
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

    function approveToken(address _token, address _to) external onlyOperator {
        IERC20(_token).approve(address(_to), type(uint256).max);
    }

    //IVotingKSP

    function unlockKSP() external onlyOperator {
        votingKSP.unlockKSP();
    }

    function refixBoosting(uint256 lockPeriodRequested) external onlyOperator {
        votingKSP.refixBoosting(lockPeriodRequested);
    }

    //Modifier
    modifier onlyOperator() {
        require(operators[msg.sender], "This address is not an operator");
        _;
    }
}
