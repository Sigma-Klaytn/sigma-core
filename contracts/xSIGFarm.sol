//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/sigma/IWhitelist.sol";
import "./interfaces/sigma/IxSIGFarm.sol";
import "./interfaces/sigma/IvxERC20.sol";

import "./interfaces/sigma/ISigmaVoter.sol";
import "./interfaces/sigma/ISigKSPFarm.sol";
import "./interfaces/sigma/ILpFarm.sol";

import "./libraries/DSMath.sol";

contract xSIGFarm is Ownable, IxSIGFarm {
    /* ========== STATE VARIABLES ========== */

    IERC20 public xSIG;
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

    /* ========== External Function  ========== */

    /**
     @notice stake xSIG
     @notice if user already staked xSIG, claim vxSIG first and then stake.
     @param _amount the amount of xSIG to stake
     */
    function stake(uint256 _amount) external override {
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
        xSIG.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount, userInfo.stakedXSIG);
    }

    /**
     @notice withdraws staked xSIG
     @notice You should be aware that you are going to lose all of your vxSIG if you unstake any amount of xSIG.
     @param _amount the amount of xSIG to unstake
     */
    function unstake(uint256 _amount) external override {
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

        xSIG.transfer(msg.sender, _amount);

        uint256 userVotedCount = sigmaVoter.getUserVotesCount(msg.sender);
        if (userVotedCount > 0) {
            sigmaVoter.deleteAllPoolVoteFromXSIGFarm(msg.sender);
        }

        lpFarm.updateBoostWeight(msg.sender);
        sigKSPFarm.updateBoostWeight();

        emit Unstaked(msg.sender, _amount, userInfo.stakedXSIG);
    }

    /**
     @notice claims accumulated vxSIG
     */
    function claim() external override {
        require(isUser(msg.sender), "User didn't stake any xSIG.");
        _claim(msg.sender);
    }

    /* ========== Restricted Function  ========== */

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
        xSIG = IERC20(_xSIG);
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

    /* ========== Internal & Private Function  ========== */

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
