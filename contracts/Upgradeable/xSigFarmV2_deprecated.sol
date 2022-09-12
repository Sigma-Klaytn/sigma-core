//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IWhitelist {
    function approveWallet(address _wallet) external;

    function revokeWallet(address _wallet) external;

    function check(address _wallet) external view returns (bool);
}

interface IxSIGFarm {
    function isUser(address _addr) external view returns (bool);

    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

    function claimAndActivateBoost() external;

    function getStakedXSIG(address _addr) external view returns (uint256);
}

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
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

interface ISigKSPFarm {
    function updateBoostWeight(address _user) external;
}

interface ILpFarm {
    function updateBoostWeight(address _user) external;

    function forwardLpTokensFromLockdrop(
        address _user,
        uint256 _amount,
        uint256 _lockingPeriod
    ) external;
}

interface IKlayswapGovern {
    function cancelUserVotes(address _user) external;
}

library DSMath {
    uint256 public constant WAD = 10**18;
    uint256 public constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * y) + (WAD / 2)) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256) {
        return ((x * WAD) + (y / 2)) / y;
    }

    function reciprocal(uint256 x) internal pure returns (uint256) {
        return wdiv(WAD, x);
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = ((x * y) + (RAY / 2)) / RAY;
    }
}

contract xSigFarmV2 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    IxSIGFarm
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /* ========== STATE VARIABLES ========== */

    IERC20Upgradeable public xSIG;
    IvxERC20 public vxSIG;
    ISigmaVoter public sigmaVoter;
    ISigKSPFarm public sigKSPFarm;
    ILpFarm public lpFarm;

    /// @notice the rate of vxSIG generated per second
    uint256 public generationRate;

    /// @notice max vxSIG per SIG
    uint256 public maxVxSIGPerXSIG;

    /// @notice whitelist wallet checker
    /// @dev contract addresses are by default unable to stake xSIG, they must be previously whitelisted to stake xSIG
    IWhitelist public whitelist;

    struct UserInfo {
        uint256 stakedXSIG; // staked xSIG of the user
        uint256 lastRelease; // last release timestamp for checking pending vxSIG. last vxSIG claim time or first deposit time.
        uint256 startTime; // initial xSIG stake timestamp.
    }

    /// @notice UserInfo mapping
    mapping(address => UserInfo) public userInfoOf;

    /// @notice [Update] V2 appended value
    IKlayswapGovern public klayswapGovern;

    /// @notice events describing staking, unstaking and claiming
    event Staked(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed totalStakedAmount
    );
    event Unstaked(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed totalStakedAmount
    );
    event Claimed(address indexed user, uint256 indexed amount);

    /* ========== Restricted Function  ========== */

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
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
     @notice sets initialInfo of the contract.
     */
    function setInitialInfo(
        address _xSIG,
        address _vxSIG,
        address _sigmaVoter,
        address _sigKSPFarm,
        address _lpFarm
    ) external onlyOwner {
        xSIG = IERC20Upgradeable(_xSIG);
        vxSIG = IvxERC20(_vxSIG);

        sigmaVoter = ISigmaVoter(_sigmaVoter);
        sigKSPFarm = ISigKSPFarm(_sigKSPFarm);
        lpFarm = ILpFarm(_lpFarm);

        //Initial generation rate. 0.014 vxSIG per hour
        generationRate = 3888888888888;

        //Initial vxSIG per xSIG is 100
        maxVxSIGPerXSIG = 100000000000000000000;
    }

    /**
     @notice sets generation rate
     @param _generationRate the new generation rate. how much vxSIG going to be added per second.
     */
    function setGenerationRate(uint256 _generationRate) external onlyOwner {
        require(_generationRate != 0, "generation rate cannot be zero");
        require(
            _generationRate != generationRate,
            "new generation is same with old one"
        );

        generationRate = _generationRate;
    }

    /**
     @notice sets maxBoosterPerSIG
     @param _maxVxSIGPerXSIG the new max vxSIG per 1 xSIG
     */
    function setMaxVxSIGPerXSIG(uint256 _maxVxSIGPerXSIG) external onlyOwner {
        require(_maxVxSIGPerXSIG != 0, "_maxVxSIGPerXSIG cannot be zero");
        require(
            _maxVxSIGPerXSIG != maxVxSIGPerXSIG,
            "new maxVxSIGPerXSIG is same with old one"
        );
        maxVxSIGPerXSIG = _maxVxSIGPerXSIG;
    }

    /**
     @notice sets whitelist address
     @param _whitelistAddr the new whitelist address
     */
    function setWhitelist(address _whitelistAddr) external onlyOwner {
        require(_whitelistAddr != address(0), "zero address");
        whitelist = IWhitelist(_whitelistAddr);
    }

    /**
     @notice [V2 ADDED] set the klayswap govern contract address.
     @param _klayswapGovernAddr the new klayswap govern address.
     */

    function setKlayswapGovern(address _klayswapGovernAddr) external onlyOwner {
        klayswapGovern = IKlayswapGovern(_klayswapGovernAddr);
    }

    /* ========== External Function  ========== */

    /**
     @notice stake xSIG
     @notice if user already staked xSIG, claim vxSIG first and then stake.
     @param _amount the amount of xSIG to stake
     */
    function stake(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
    {
        require(_amount > 0, "stake xSIG amount should be bigger than 0");

        _assertNotContract(msg.sender);
        UserInfo storage userInfo = userInfoOf[msg.sender];
        if (userInfo.stakedXSIG > 0) {
            _claim(msg.sender);
        } else {
            // Add user and set initial info
            userInfo.startTime = block.timestamp;
            userInfo.lastRelease = block.timestamp;
        }

        userInfo.stakedXSIG += _amount;
        xSIG.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount, userInfo.stakedXSIG);
    }

    /**
     @notice withdraws staked xSIG
     @notice You should be aware that you are going to lose all of your vxSIG if you unstake any amount of xSIG.
     @param _amount the amount of xSIG to unstake
     */
    function unstake(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
    {
        require(_amount > 0, "Unstake amount should be bigger than 0");
        UserInfo storage userInfo = userInfoOf[msg.sender];
        require(userInfo.stakedXSIG >= _amount, "Insuffcient xSIG to unstake");

        userInfo.stakedXSIG -= _amount;

        if (userInfo.stakedXSIG == 0) {
            userInfo.startTime = 0;
            userInfo.lastRelease = 0;
        } else {
            userInfo.startTime = block.timestamp;
            userInfo.lastRelease = block.timestamp;
        }

        //burn vxSIG of user. balance goes to 0
        uint256 uservxSIGBalance = vxSIG.balanceOf(msg.sender);
        vxSIG.burn(msg.sender, uservxSIGBalance);

        xSIG.safeTransfer(msg.sender, _amount);

        uint256 userVotedCount = sigmaVoter.getUserVotesCount(msg.sender);
        if (userVotedCount > 0) {
            sigmaVoter.deleteAllPoolVoteFromXSIGFarm(msg.sender);
        }

        lpFarm.updateBoostWeight(msg.sender);
        sigKSPFarm.updateBoostWeight(msg.sender);
        klayswapGovern.cancelUserVotes(msg.sender);

        emit Unstaked(msg.sender, _amount, userInfo.stakedXSIG);
    }

    function claimAndActivateBoost()
        external
        override
        whenNotPaused
        nonReentrant
    {
        _claim();
        _activateBoost();
    }

    /* ========== Internal & Private Function  ========== */

    /**
     @notice claims accumulated vxSIG
     */
    function _claim() private {
        require(isUser(msg.sender), "User didn't stake any xSIG.");
        _claim(msg.sender);
    }

    /**
     @notice update user's vxSIG of lpFarm and sigKSPFarm.
     */
    function _activateBoost() private {
        require(isUser(msg.sender), "User didn't stake any xSIG.");
        require(vxSIG.balanceOf(msg.sender) > 0, "No vxSIG to activate boost");

        lpFarm.updateBoostWeight(msg.sender);
        sigKSPFarm.updateBoostWeight(msg.sender);
    }

    /**
     @notice asserts address in param is not a smart contract. if it is a smart contract, check that it is whitelisted
     @param _address the address to check 
     */
    function _assertNotContract(address _address) private view {
        if (_address != tx.origin) {
            require(
                address(whitelist) != address(0) && whitelist.check(_address),
                "Smart contract depositors not allowed, ask for whitelisting if you are smart contract."
            );
        }
    }

    /**
        @notice private claim vxSIG function
        @param _address the address of the user to claim from
     */
    function _claim(address _address) private {
        uint256 amount = _claimable(_address);

        // update last release time
        userInfoOf[_address].lastRelease = block.timestamp;

        if (amount > 0) {
            vxSIG.mint(_address, amount);
            emit Claimed(_address, amount);
        }
    }

    /**
     @notice private claim function
     @param _address the address of the user to claim from
     */
    function _claimable(address _address) private view returns (uint256) {
        UserInfo memory user = userInfoOf[_address];

        // get seconds elapsed since last claim
        uint256 secondsElapsed = block.timestamp - user.lastRelease;

        // DSMath.wmul used to multiply wad numbers
        uint256 pending = DSMath.wmul(
            user.stakedXSIG,
            secondsElapsed * generationRate
        );
        // get user's vxSIG balance
        uint256 userVxSIGBalance = vxSIG.balanceOf(_address);

        // user vxSIG balance cannot go above user.amount * maxCap
        uint256 maxVxSIGCap = DSMath.wmul(user.stakedXSIG, maxVxSIGPerXSIG);

        // first, check that user hasn't reached the max limit yet
        if (userVxSIGBalance < maxVxSIGCap) {
            // then, check if pending amount will make user balance overpass maximum amount
            if ((userVxSIGBalance + pending) > maxVxSIGCap) {
                return maxVxSIGCap - userVxSIGBalance;
            } else {
                return pending;
            }
        }
        return 0;
    }

    /* ========== View Function  ========== */

    /**
     @notice checks wether user _address has xSIG staked
     @param _address the user address to check
     @return true if the user has xSIG in stake, false otherwise
    */
    function isUser(address _address) public view override returns (bool) {
        return userInfoOf[_address].stakedXSIG > 0;
    }

    /**
     @notice Calculate the amount of vxSIG that can be claimed by user
     @param _address the address to check
     @return amount of vxSIG that can be claimed by user
     */

    function claimable(address _address) external view returns (uint256) {
        require(_address != address(0), "zero address");
        return _claimable(_address);
    }

    /**
     @notice Check Staked xSIG of the user
     @param _address the user address to check
     */
    function getStakedXSIG(address _address)
        external
        view
        override
        returns (uint256)
    {
        require(_address != address(0), "zero address");
        return userInfoOf[_address].stakedXSIG;
    }
}
