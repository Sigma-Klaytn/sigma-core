//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IVotingKSP {
    function lockKSP(uint256 amount, uint256 lockPeriodRequested) external;

    function lockedKSP(address account) external view returns (uint256);

    function unlockKSP() external;

    function refixBoosting(uint256 lockPeriodRequested) external;

    function claimReward() external;

    function getCurrentBalance(address account) external view returns (uint256);

    // function compoundReward() external;

    function getPriorBalance(address user, uint256 blockNumber)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface IPoolVoting {
    function addVoting(address exchange, uint256 amount) external;

    function removeVoting(address exchange, uint256 amount) external;

    function claimReward(address exchange) external;

    function userVotingPoolAmount(address user, uint256 poolIndex)
        external
        view
        returns (uint256);

    function userVotingPoolAddress(address user, uint256 poolIndex)
        external
        view
        returns (address);

    function userVotingPoolCount(address user) external view returns (uint256);

    function claimRewardAll() external;

    function removeAllVoting() external;
}

interface ISigmaVoter {
    function getCurrentVotes()
        external
        view
        returns (
            uint256 weightsTotal,
            address[] memory pools,
            uint256[] memory weights
        );

    function getUserVotesCount(address _user) external view returns (uint256);

    function deleteAllPoolVoteFromXSIGFarm(address _user) external;
}

interface IFactory {
    function exchangeKlayPos(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable;

    function exchangeKlayNeg(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable;

    function exchangeKctNeg(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external;

    function exchangeKctPos(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external;
}

interface IFeeDistributor {
    function depositERC20(address _token, uint256 _amount) external;

    function depositKlay() external payable;
}

interface IKlayswapGovernor {
    function castVote(uint256 proposalId, bool support) external;
}

interface IEcoPotVoting {
    function addVoting(address ecoPot, uint256 amount) external;

    function removeAllVoting() external;

    function claimRewardAll() external;
}

contract KlayswapEscrowV3 is
    IERC20Upgradeable,
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    string public constant name = "sigKSP: Tokenized vKSP";
    string public constant symbol = "sigKSP";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    //KlaySwap contracts
    IERC20Upgradeable public kspToken;
    IERC20Upgradeable public oUsdtToken;

    IVotingKSP public votingKSP;
    IPoolVoting public poolVoting;
    IFactory public factory;

    ISigmaVoter public sigmaVoter;
    IFeeDistributor public feeDistributor;

    uint256 public constant MAX_LOCK_PERIOD = 1555200000;

    mapping(address => bool) public operators;

    /// @notice [Update] V2 appended values
    /// Sigma contract: KlayswapGovern
    address sigmaKlayswapGovern;

    /// Klayswap contract
    IKlayswapGovernor klayswapGovernor;

    /// @notice [Update] V3 appended values
    IEcoPotVoting klayswapEcopotVoting;

    event DepositKSP(address depositer, uint256 amount);
    event ForwardedFee(uint256 kspAmount, uint256 kusdtAmount);
    event Voted(address pool, uint256 amount);
    event EcopotVoted(address ecopot, uint256 amount);

    modifier onlyOperator() {
        require(operators[msg.sender], "This address is not an operator");
        _;
    }

    /* ========== RESTRICTED SETTING FUNCTIONS ========== */

    /**
     @notice Set operator to run functions.
     @param _operators list of operator to give an authority.
     */
    function setOperator(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators[_operators[i]] = true;
        }
    }

    /**
     @notice [V3 ADDED] set the klayswap ecopot voting contract address.
     @param _ecopotVotingAddr the new klayswap ecopot voting address.
     */

    function setKlayswapEcopotVoting(address _ecopotVotingAddr)
        external
        onlyOwner
    {
        klayswapEcopotVoting = IEcoPotVoting(_ecopotVotingAddr);
    }

    /**
     @notice [V2 ADDED] set the klayswap govern contract address.
     @param _sigmaKlayswapGovernAddr the new klayswap govern address.
     */

    function setSigmaKlayswapGovern(address _sigmaKlayswapGovernAddr)
        external
        onlyOwner
    {
        sigmaKlayswapGovern = _sigmaKlayswapGovernAddr;
    }

    /**
     @notice [V2 ADDED] set the klayswap governor contract address.
     @param _klayswapGovernorAddr the new klayswap govern address.
     */

    function setKlayswapGovernor(address _klayswapGovernorAddr)
        external
        onlyOwner
    {
        klayswapGovernor = IKlayswapGovernor(_klayswapGovernorAddr);
    }

    /**
     @notice Revoke authority to run functions.
     @param _operator : operator to revoke permission from.
     */
    function revokeOperator(address _operator) external onlyOwner {
        require(operators[_operator], "This address is not an operator");
        operators[_operator] = false;
    }

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    /**
        @notice Set Initial info of KlayswapEscrow Contract and approve tokens.
     */
    function setInitialInfo(
        IERC20Upgradeable _kspToken,
        IERC20Upgradeable _kusdtToken,
        IVotingKSP _votingKSP,
        IPoolVoting _poolVoting,
        ISigmaVoter _sigmaVoter,
        IFactory _factory,
        IFeeDistributor _feeDistributor
    ) external onlyOwner {
        kspToken = _kspToken;
        oUsdtToken = _kusdtToken;
        votingKSP = _votingKSP;
        poolVoting = _poolVoting;
        sigmaVoter = _sigmaVoter;
        factory = _factory;
        feeDistributor = _feeDistributor;

        kspToken.approve(address(votingKSP), type(uint256).max);
        oUsdtToken.approve(address(feeDistributor), type(uint256).max);
        kspToken.approve(address(feeDistributor), type(uint256).max);
    }

    /**
        @notice restrict upgrade to only owner.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}

    /**
        @notice pause contract functions.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
        @notice unpause contract functions.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /**
        @notice Forward Fees that has been collected to this contract. It forwards KSP and oUSDT.
     */
    function forwardFeeToFeeDistributor() external onlyOperator {
        uint256 kspTokenBalance = kspToken.balanceOf(address(this));
        uint256 oUsdtTokenBalance = oUsdtToken.balanceOf(address(this));

        require(
            kspTokenBalance != 0 || oUsdtTokenBalance != 0,
            "No ksp and oUSDT to send to fee distributor."
        );

        if (kspTokenBalance > 0) {
            feeDistributor.depositERC20(address(kspToken), kspTokenBalance);
        }

        if (oUsdtTokenBalance > 0) {
            feeDistributor.depositERC20(address(oUsdtToken), oUsdtTokenBalance);
        }

        emit ForwardedFee(kspTokenBalance, oUsdtTokenBalance);
    }

    /* ========== IERC20 TOKEN RELATED FUNCTIONS ========== */

    function approve(address _spender, uint256 _value)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
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
        @notice sigKSP only minted when user deposit KSP. The exchange ratio is 1:1.
     */
    function _mint(address _user, uint256 _amount) internal {
        balanceOf[_user] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), _user, _amount);
    }

    /* ========== Public | External Function  ========== */

    /**
        @notice Receive Klay.
     */
    receive() external payable {}

    /**
        @notice Deposit KSP and get sigKSP in return. sigKSP is Tokenized vKSP.
        @param _amount Amount of ksp to deposit. The unit is 10^18.
     */
    function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Deposit KSP should be bigger than 0.");
        _mint(msg.sender, _amount * 1 ether);
        kspToken.safeTransferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);

        emit DepositKSP(msg.sender, _amount * 1 ether);
    }

    /**
     @notice [V2 ADDED] forward proposal vote to klayswap governor.
     */

    function castVote(uint256 proposalId, bool support) external {
        require(
            msg.sender == sigmaKlayswapGovern,
            "Caller is not sigma's klayswap govern."
        );
        klayswapGovernor.castVote(proposalId, support);
    }

    /* ========== Delegate to Klayswap Function  ========== */

    /**
        @notice It gets KSP from VotingKSP.sol of Klayswap.
     */
    function claimVotingKSPReward() external onlyOperator {
        votingKSP.claimReward();
    }

    /**
        @notice Submit vote to klayswap.
        @dev It is public cause vote can be forwarded 1 by 1 by operator.
        @param exchange : Pool address. 
        @param amount : The amount can be entered in integer units  
     */
    function addVoting(address exchange, uint256 amount) public onlyOperator {
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
        require(weightsTotal != 0, "Weights Total should not be 0");

        uint256 vKspBalance = votingKSP.balanceOf(address(this)); //in wei
        require(vKspBalance / 1e18 > 0, "No vKSP to vote in this contract.");

        uint256 usedVKsp = 0;

        for (uint256 i = 0; i < pools.length; i++) {
            address pool = pools[i];
            uint256 voteWeight = weights[i];

            uint256 kspVoteWeight = ((vKspBalance * voteWeight) /
                weightsTotal) / 1e18;
            if (kspVoteWeight != 0) {
                addVoting(pool, kspVoteWeight);
                usedVKsp += kspVoteWeight;
            }
        }

        if (vKspBalance / 1e18 - usedVKsp > 0) {
            uint256 leftvKSP = vKspBalance / 1e18 - usedVKsp;
            addVoting(pools[pools.length - 1], leftvKSP);
        }
    }

    /**
        @notice Remove Voting from Klayswap. This function also claim reward internally.
     */
    function removeVoting(address exchange, uint256 amount)
        external
        onlyOperator
    {
        poolVoting.removeVoting(exchange, amount);
    }

    /**
        @notice Claim Reward from a pool voting from klayswap.
     */
    function claimPoolVotingReward(address exchange) external onlyOperator {
        poolVoting.claimReward(exchange);
    }

    /**
        @notice Method of all vote pool’s transaction fee reward 
     */
    function claimPoolVotingRewardAll() external onlyOperator {
        poolVoting.claimRewardAll();
    }

    /**
        @notice Remove All Voting from Klayswap. This function also claim reward internally.
     */
    function removeAllVoting() external onlyOperator {
        poolVoting.removeAllVoting();
    }

    /**
        @notice Exchange Fees to oUSDT
     */
    function exchangeKlayPos(
        address token,
        uint256 amount,
        address[] memory path,
        uint256 klayAmount
    ) external payable onlyOperator {
        factory.exchangeKlayPos{value: klayAmount}(token, amount, path);
    }

    /**
        @notice Exchange Fees to oUSDT
     */
    function exchangeKlayNeg(
        address token,
        uint256 amount,
        address[] memory path,
        uint256 klayAmount
    ) external payable onlyOperator {
        factory.exchangeKlayNeg{value: klayAmount}(token, amount, path);
    }

    /**
        @notice Exchange Fees to oUSDT
     */
    function exchangeKctNeg(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external onlyOperator {
        factory.exchangeKctNeg(tokenA, amountA, tokenB, amountB, path);
    }

    /**
        @notice Exchange Fees to oUSDT
     */
    function exchangeKctPos(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external onlyOperator {
        factory.exchangeKctPos(tokenA, amountA, tokenB, amountB, path);
    }

    /**
        @notice Approve Token to External Contract.
        @param _token : token that approved.
        @param _to : address that approve token to.
     */
    function approveToken(address _token, address _to) external onlyOperator {
        IERC20Upgradeable(_token).approve(address(_to), type(uint256).max);
    }

    /**
        @notice Unlock KSP that is expired.
     */
    function unlockKSP() external onlyOperator {
        votingKSP.unlockKSP();
    }

    /**
        @notice Refix boosting period.
     */
    function refixBoosting(uint256 lockPeriodRequested) external onlyOperator {
        votingKSP.refixBoosting(lockPeriodRequested);
    }

    // ECOPOT RELATED FUNCTIONS
    /**
     @notice [V3 ADDED] add voting for ecopot.
     @param _ecopotAddr ecopot address
     */
    function ecopotAddVoting(address _ecopotAddr) external onlyOperator {
        uint256 vKspBalance = votingKSP.balanceOf(address(this)); //in wei
        require(vKspBalance / 1e18 > 0, "No vKSP to vote in this contract.");

        uint256 kspVoteWeight = vKspBalance / 1e18;
        klayswapEcopotVoting.addVoting(_ecopotAddr, kspVoteWeight);
        emit EcopotVoted(_ecopotAddr, kspVoteWeight);
    }

    /**
     @notice [V3 ADDED] add voting for ecopot.
     */
    function ecopotRemoveAllVoting() external onlyOperator {
        klayswapEcopotVoting.removeAllVoting();
    }

    /**
     @notice [V3 ADDED] claim reward for ecopot.
     */
    function ecopotClaimRewardAll() external onlyOperator {
        klayswapEcopotVoting.claimRewardAll();
    }
}
