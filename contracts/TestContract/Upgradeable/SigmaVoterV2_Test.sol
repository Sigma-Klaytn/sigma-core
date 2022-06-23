//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../../interfaces/sigma/IvxERC20.sol";
import "../../interfaces/sigma/ISigmaVoter.sol";

// [Changed feature]
//1. when user vote "Pool length should be smaller than 4."

contract SigmaVoterV2_Test is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ISigmaVoter
{
    IvxERC20 public vxSIG;

    /// @notice Total pool count submitting to klayswap
    uint256 public constant MAX_SUBMIT_POOL = 10;
    /// @notice pools that is determined by Sigma Vote among the MAX_SUBMIT_POOL
    uint256 public constant TOP_VOTES_POOL_COUNT = 7;
    /// @notice pools that is expected to have top yield. this is will be used for abstentions or votes that was not made it to TOP_VOTE.
    uint256 public constant TOP_YIELD_POOL_COUNT = 3;

    /// @notice save more vote pool for buffer. This is for when user withdraw votes from the pool.
    uint256 public constant MAX_VOTES_WITH_BUFFER =
        TOP_VOTES_POOL_COUNT + 5 + 1;

    uint256 public USER_MAX_VOTE_POOL;

    /// @notice total used vxSIG for vote
    uint256 public totalUsedVxSIG;

    /// @notice pool -> total vxSIG allocated
    mapping(address => PoolInfo) public poolInfos;
    address[] public poolAddresses;

    /// @notice user -> total voted vxSIG
    mapping(address => uint256) public userTotalUsedVxSIG;
    /// @notice user -> PoolData vxSIG for a pool
    mapping(address => PoolVote[]) public userPoolVotes;
    /// @notice user -> pool -> isVoted
    mapping(address => mapping(address => UserPoolInfo)) public userPoolInfos;

    address[] public topYieldPools;
    /// always first one is 0;
    uint64[MAX_VOTES_WITH_BUFFER] public topVotes;

    uint256 public topVotesLength; // actual number of items stored in `topVotes`
    uint256 public minTopVote; // smallest vote-weight for pools included in `topVotes`
    uint256 public minTopVoteIndex; // `topVotes` index where the smallest vote is stored (always +1 cause it has 0 at first)

    address xSIGFarm; // address of xSIG Farm

    struct PoolVote {
        address pool;
        uint256 vxSIGAmount;
    }

    struct UserPoolInfo {
        uint256 poolVoteIndex;
        bool isVoted;
    }

    struct PoolInfo {
        uint256 vxSIGAmount;
        bool isInitiated;
        uint256 listPointer;
        uint8 topVotesIndex;
    }

    event PoolAdded(address indexed poolAddress, uint256 totalPoolLength);
    event VoteWithdrawn(
        address indexed user,
        address indexed poolAddress,
        uint256 withdrawnAmount,
        uint256 newPoolVxSIGAmount
    );
    event AllVoteWithdrawn(address indexed user);

    /* ========== Restricted Function  ========== */

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __Pausable_init();

        // poolAddress[0] is always empty. So if (poolInfo[x].listPointer == 0) means no pool set yet.
        poolAddresses.push(address(0));
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

    function setInitialInfo(
        address[] calldata _lpPools,
        address[] calldata _topYieldPools,
        IvxERC20 _vxSIG,
        uint256 _userMaxVote,
        address _xSIGFarm
    ) external onlyOwner {
        require(
            _topYieldPools.length == TOP_YIELD_POOL_COUNT,
            "Top yield pool length doesn't match with TOP_YIELD_POOL_COUNT"
        );
        vxSIG = _vxSIG;
        topYieldPools = _topYieldPools;
        USER_MAX_VOTE_POOL = _userMaxVote;
        xSIGFarm = _xSIGFarm;

        // Add pools
        for (uint256 i = 0; i < _lpPools.length; i++) {
            addPool(_lpPools[i]);
        }
    }

    /**
     @notice sets pools that is going to take abstentions. Set all pool at once.
    */
    function setTopYieldPools(address[] calldata _pools) external onlyOwner {
        topYieldPools = _pools;
    }

    /**
     @notice set USER_MAX_VOTE_POOL
     */
    function setUserMaxVotePool(uint256 _value) external onlyOwner {
        USER_MAX_VOTE_POOL = _value;
    }

    /**
        @notice add pool and initiate.
     */
    function addPool(address _pool) public onlyOwner {
        require(!isPool(_pool), "This pool already has been added.");

        poolInfos[_pool] = PoolInfo({
            vxSIGAmount: 0,
            isInitiated: true,
            listPointer: poolAddresses.length,
            topVotesIndex: 0
        });
        poolAddresses.push(_pool);
        uint256 length = poolAddresses.length - 1;
        emit PoolAdded(_pool, length);
    }

    /* ========== External / Public Function  ========== */

    /**
     @notice withdraws staked xSIG
     @notice You should be aware that amount unit is ETH not wei.
     @param _pools array of pools to vote.
     @param _vxSIGAmounts array of the amount of vxSIG to vote. IT SHOULD BE ETH. 
     */
    function addAllPoolVote(
        address[] calldata _pools,
        uint256[] calldata _vxSIGAmounts
    ) external whenNotPaused {
        require(
            _pools.length == _vxSIGAmounts.length,
            "Pool length doesn't match with vxSIGAmounts length."
        );
        require(_pools.length > 0, "Must vote for at least one pool");
        require(_pools.length < 4, "Pool length should be smaller than 4.");

        uint256 _totalVxSIGUsed;

        // copy values to minimize gas fee.
        uint256 _topVotesLengthMem = topVotesLength;
        uint256 _minTopVoteMem = minTopVote;
        uint256 _minTopVoteIndexMem = minTopVoteIndex;
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes;

        for (uint256 i = 0; i < _pools.length; i++) {
            address _pool = _pools[i];
            uint256 _vxSIG = _vxSIGAmounts[i];
            require(_vxSIG > 0, "Vote vxSIG should be bigger than 0");
            _updatePoolVote(_pool, _vxSIG);
            _totalVxSIGUsed += _vxSIG;
            userTotalUsedVxSIG[msg.sender] += _vxSIG;

            //Update top vote logic.
            uint256 newPoolVxSIGAmount = poolInfos[_pool].vxSIGAmount;
            uint256 poolAddressIndex = poolInfos[_pool].listPointer;
            if (poolInfos[_pool].topVotesIndex > 0) {
                uint256 poolTopVoteIndex = poolInfos[_pool].topVotesIndex;

                t[poolTopVoteIndex] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );

                if (poolTopVoteIndex == _minTopVoteIndexMem) {
                    // if this pool was the minTopVoteIndex, as there is newly added votes, findMinTopVote again.
                    (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                        t,
                        _topVotesLengthMem + 1
                    );
                }
            } else if (_topVotesLengthMem < MAX_VOTES_WITH_BUFFER - 1) {
                _topVotesLengthMem += 1;

                t[_topVotesLengthMem] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                poolInfos[_pool].topVotesIndex = uint8(_topVotesLengthMem);

                if (
                    newPoolVxSIGAmount < _minTopVoteMem ||
                    _topVotesLengthMem == 1 // If this is first top vote added,
                ) {
                    _minTopVoteMem = newPoolVxSIGAmount;
                    _minTopVoteIndexMem = _topVotesLengthMem;
                }
            } else if (newPoolVxSIGAmount > _minTopVoteMem) {
                uint256 addressIndex = t[_minTopVoteIndexMem] >> 40;
                poolInfos[poolAddresses[addressIndex]].topVotesIndex = 0;
                t[_minTopVoteIndexMem] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                poolInfos[_pool].topVotesIndex = uint8(_minTopVoteIndexMem);

                // // iterate to find the new _minTopVoteMem and _minTopVoteIndexMem
                (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                    t,
                    MAX_VOTES_WITH_BUFFER
                );
            }
        }

        totalUsedVxSIG += _totalVxSIGUsed;

        topVotes = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;
    }

    /**
        @notice withdraw certain amount of vxSIGVote from the pool
        @param _pool pool address to add. 
        @param _vxSIGAmount vxSIG Amount to withdraw in ETH not wei. 
     */
    function deletePoolVote(address _pool, uint256 _vxSIGAmount)
        public
        whenNotPaused
    {
        require(isPool(_pool), "This pool is not registred by the admin.");
        require(
            userPoolInfos[msg.sender][_pool].isVoted,
            "User never voted to this pool."
        );

        totalUsedVxSIG -= _vxSIGAmount;
        userTotalUsedVxSIG[msg.sender] -= _vxSIGAmount;
        uint256 newPoolVxSIGAmount = poolInfos[_pool].vxSIGAmount -
            _vxSIGAmount;

        // copy values to minimize gas fee.
        uint256 _topVotesLengthMem = topVotesLength;
        uint256 _minTopVoteMem = minTopVote;
        uint256 _minTopVoteIndexMem = minTopVoteIndex;
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes;

        uint256 poolAddressIndex = poolInfos[_pool].listPointer;
        uint256 poolTopVotesIndex = poolInfos[_pool].topVotesIndex;

        if (newPoolVxSIGAmount == 0) {
            if (poolTopVotesIndex > 0) {
                // If this pool was in topVotes
                if (poolTopVotesIndex == _topVotesLengthMem) {
                    // If this pool was at the end of the topVotes
                    delete t[_topVotesLengthMem];
                } else {
                    t[poolTopVotesIndex] = t[_topVotesLengthMem];
                    uint256 addressIndex = t[poolTopVotesIndex] >> 40;
                    poolInfos[poolAddresses[addressIndex]]
                        .topVotesIndex = uint8(poolTopVotesIndex);
                    delete t[_topVotesLengthMem];
                    if (_minTopVoteIndexMem == _topVotesLengthMem) {
                        //if minTopVoteIndexMem was the one moved, change the minTopvoteIndex to moved index.
                        _minTopVoteIndexMem = poolTopVotesIndex;
                    }
                }
                _topVotesLengthMem -= 1;
                if (_topVotesLengthMem == 0) {
                    _minTopVoteMem = 0;
                    _minTopVoteIndexMem = 0;
                }
                poolInfos[_pool].topVotesIndex = 0;
            }
            _updatePoolVxSIGAmount(_pool, 0);
        } else {
            if (poolTopVotesIndex > 0) {
                t[poolTopVotesIndex] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                if (newPoolVxSIGAmount < _minTopVoteMem) {
                    _minTopVoteMem = newPoolVxSIGAmount;
                    _minTopVoteIndexMem = poolTopVotesIndex;
                }
            }
            _updatePoolVxSIGAmount(_pool, newPoolVxSIGAmount);
        }

        topVotes = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;

        uint256 poolVoteIndex = userPoolInfos[msg.sender][_pool].poolVoteIndex;
        PoolVote storage userPoolVote = userPoolVotes[msg.sender][
            poolVoteIndex
        ];
        require(
            userPoolVote.vxSIGAmount >= _vxSIGAmount,
            "User didn't vote _vxSIGAmount in this pool"
        );
        userPoolVote.vxSIGAmount -= _vxSIGAmount;

        if (userPoolVote.vxSIGAmount == 0) {
            //delete from userPoolInfos
            userPoolInfos[msg.sender][_pool].isVoted = false;
            userPoolInfos[msg.sender][_pool].poolVoteIndex = 0;

            PoolVote[] storage poolVotes = userPoolVotes[msg.sender];
            if (poolVotes.length != 2) {
                PoolVote memory poolVoteToMove = poolVotes[
                    poolVotes.length - 1
                ];
                poolVotes[poolVoteIndex] = poolVoteToMove;
                userPoolInfos[msg.sender][poolVoteToMove.pool]
                    .poolVoteIndex = poolVoteIndex;
                poolVotes.pop();
            } else {
                delete userPoolVotes[msg.sender];
            }
        }

        emit VoteWithdrawn(msg.sender, _pool, _vxSIGAmount, newPoolVxSIGAmount);
    }

    /**
        @notice withdraw user's all of vxSIG vote.
     */
    function deleteAllPoolVote() external whenNotPaused {
        PoolVote[] memory userVotes = userPoolVotes[msg.sender];
        require(userVotes.length > 0, "User didn't vote yet");

        for (uint256 i = 1; i < userVotes.length; i++) {
            deletePoolVote(userVotes[i].pool, userVotes[i].vxSIGAmount);
        }

        emit AllVoteWithdrawn(msg.sender);
    }

    /**
        @notice withdraw user's all of vxSIG vote.
     */
    function deleteAllPoolVoteFromXSIGFarm(address _user)
        external
        override
        whenNotPaused
    {
        require(
            msg.sender == xSIGFarm,
            "This is not a transaction from xSIGFarm"
        );
        PoolVote[] memory userVotes = userPoolVotes[_user];
        require(userVotes.length > 0, "User didn't vote yet");

        for (uint256 i = 1; i < userVotes.length; i++) {
            _deletePoolVote(_user, userVotes[i].pool, userVotes[i].vxSIGAmount);
        }

        emit AllVoteWithdrawn(_user);
    }

    /* ========== Internal & Private Function  ========== */
    /**
        @notice withdraw certain amount of vxSIGVote from the pool
        @param _pool pool address to add. 
        @param _vxSIGAmount vxSIG Amount to withdraw in ETH not wei. 
     */
    function _deletePoolVote(
        address _user,
        address _pool,
        uint256 _vxSIGAmount
    ) private whenNotPaused {
        require(isPool(_pool), "This pool is not registred by the admin.");
        require(
            userPoolInfos[_user][_pool].isVoted,
            "User never voted to this pool."
        );

        totalUsedVxSIG -= _vxSIGAmount;
        userTotalUsedVxSIG[_user] -= _vxSIGAmount;
        uint256 newPoolVxSIGAmount = poolInfos[_pool].vxSIGAmount -
            _vxSIGAmount;

        // copy values to minimize gas fee.
        uint256 _topVotesLengthMem = topVotesLength;
        uint256 _minTopVoteMem = minTopVote;
        uint256 _minTopVoteIndexMem = minTopVoteIndex;
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes;

        uint256 poolAddressIndex = poolInfos[_pool].listPointer;
        uint256 poolTopVotesIndex = poolInfos[_pool].topVotesIndex;

        if (newPoolVxSIGAmount == 0) {
            if (poolTopVotesIndex > 0) {
                // If this pool was in topVotes
                if (poolTopVotesIndex == _topVotesLengthMem) {
                    // If this pool was at the end of the topVotes
                    delete t[_topVotesLengthMem];
                } else {
                    t[poolTopVotesIndex] = t[_topVotesLengthMem];
                    uint256 addressIndex = t[poolTopVotesIndex] >> 40;
                    poolInfos[poolAddresses[addressIndex]]
                        .topVotesIndex = uint8(poolTopVotesIndex);
                    delete t[_topVotesLengthMem];
                    if (_minTopVoteIndexMem == _topVotesLengthMem) {
                        //if minTopVoteIndexMem was the one moved, change the minTopvoteIndex to moved index.
                        _minTopVoteIndexMem = poolTopVotesIndex;
                    }
                }
                _topVotesLengthMem -= 1;
                if (_topVotesLengthMem == 0) {
                    _minTopVoteMem = 0;
                    _minTopVoteIndexMem = 0;
                }
                poolInfos[_pool].topVotesIndex = 0;
            }
            _updatePoolVxSIGAmount(_pool, 0);
        } else {
            if (poolTopVotesIndex > 0) {
                t[poolTopVotesIndex] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                if (newPoolVxSIGAmount < _minTopVoteMem) {
                    _minTopVoteMem = newPoolVxSIGAmount;
                    _minTopVoteIndexMem = poolTopVotesIndex;
                }
            }
            _updatePoolVxSIGAmount(_pool, newPoolVxSIGAmount);
        }

        topVotes = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;

        uint256 poolVoteIndex = userPoolInfos[_user][_pool].poolVoteIndex;
        PoolVote storage userPoolVote = userPoolVotes[_user][poolVoteIndex];
        require(
            userPoolVote.vxSIGAmount >= _vxSIGAmount,
            "User didn't vote _vxSIGAmount in this pool"
        );
        userPoolVote.vxSIGAmount -= _vxSIGAmount;

        if (userPoolVote.vxSIGAmount == 0) {
            //delete from userPoolInfos
            userPoolInfos[_user][_pool].isVoted = false;
            userPoolInfos[_user][_pool].poolVoteIndex = 0;

            PoolVote[] storage poolVotes = userPoolVotes[_user];
            if (poolVotes.length != 2) {
                PoolVote memory poolVoteToMove = poolVotes[
                    poolVotes.length - 1
                ];
                poolVotes[poolVoteIndex] = poolVoteToMove;
                _setUserPoolInfoPoolVoteIndex(
                    _user,
                    poolVoteToMove.pool,
                    poolVoteIndex
                );

                poolVotes.pop();
            } else {
                delete userPoolVotes[_user];
            }
        }

        emit VoteWithdrawn(_user, _pool, _vxSIGAmount, newPoolVxSIGAmount);
    }

    function _setUserPoolInfoPoolVoteIndex(
        address _user,
        address _poolAddress,
        uint256 _newPoolVoteIndex
    ) private {
        userPoolInfos[_user][_poolAddress].poolVoteIndex = _newPoolVoteIndex;
    }

    function _updatePoolVxSIGAmount(address _pool, uint256 newVxSIGAmount)
        internal
    {
        require(isPool(_pool), "This pool is not registred by the admin.");
        poolInfos[_pool].vxSIGAmount = newVxSIGAmount;
    }

    function _findMinTopVote(
        uint64[MAX_VOTES_WITH_BUFFER] memory t,
        uint256 length
    ) internal pure returns (uint256, uint256) {
        uint256 _minTopVoteMem = type(uint256).max;
        uint256 _minTopVoteIndexMem = 0;
        for (uint256 i = 1; i < length; i++) {
            uint256 value = t[i] % 2**40;
            if (value < _minTopVoteMem) {
                _minTopVoteMem = value;
                _minTopVoteIndexMem = i;
            }
        }
        return (_minTopVoteMem, _minTopVoteIndexMem);
    }

    /**
        @notice update PoolInfo and userPoolInfo,userVotes. 
        @param _pool pool address to add. 
        @param _vxSIGAmount vxSIG Amount in ETH not wei. 
     */
    function _updatePoolVote(address _pool, uint256 _vxSIGAmount) internal {
        require(isPool(_pool), "This pool is not registred by the admin.");
        require(
            availableVotes(msg.sender) >= _vxSIGAmount,
            "insufficient vxSIG to vote"
        );

        uint256 newVxSIGAmount = poolInfos[_pool].vxSIGAmount + _vxSIGAmount;

        _updatePoolVxSIGAmount(_pool, newVxSIGAmount);

        PoolVote[] storage userVotes = userPoolVotes[msg.sender];

        //if userVotes.length ==0 add empty userPoolInfo.
        if (userVotes.length == 0) {
            userVotes.push(PoolVote({pool: address(0), vxSIGAmount: 0}));
        }

        if (userPoolInfos[msg.sender][_pool].isVoted) {
            // If already voted to this pool
            userVotes[userPoolInfos[msg.sender][_pool].poolVoteIndex]
                .vxSIGAmount += _vxSIGAmount;
        } else {
            require(
                userVotes.length < USER_MAX_VOTE_POOL + 1,
                "User exceeded max vote pool count."
            );
            // If never been voted to this pool

            userVotes.push(PoolVote({pool: _pool, vxSIGAmount: _vxSIGAmount}));
            uint256 index = userVotes.length - 1;

            userPoolInfos[msg.sender][_pool] = UserPoolInfo({
                poolVoteIndex: index,
                isVoted: true
            });
        }
    }

    function pack(uint256 id, uint256 vxSIGAmount)
        internal
        pure
        returns (uint64)
    {
        uint64 value = uint64((id << 40) + vxSIGAmount);
        return value;
    }

    function unpack(uint256 value)
        internal
        pure
        returns (uint256 id, uint256 vxSIGAmount)
    {
        id = (value >> 40);
        vxSIGAmount = uint256(value % 2**40);
        return (id, vxSIGAmount);
    }

    /* ========== View Function  ========== */
    /**
     @notice get current top votes.
     */
    function getCurrentTopVotes()
        external
        view
        returns (
            address[MAX_VOTES_WITH_BUFFER] memory,
            uint256[MAX_VOTES_WITH_BUFFER] memory
        )
    {
        uint256[MAX_VOTES_WITH_BUFFER] memory weights;
        address[MAX_VOTES_WITH_BUFFER] memory addresses;

        for (uint256 i = 1; i < topVotesLength + 1; i++) {
            (uint256 addressIndex, uint256 weight) = unpack(topVotes[i]);
            weights[i - 1] = uint256(weight);
            addresses[i - 1] = poolAddresses[addressIndex];
        }
        return (addresses, weights);
    }

    /**
        @notice getCurrentVotes for submit to Klayswap. It contains pre-setted TOP_YIELD_POOLS.
     */
    function getCurrentVotes()
        external
        view
        override
        returns (
            uint256 _vxSIGTotalSupply,
            address[] memory pools,
            uint256[] memory weights
        )
    {
        uint256 length = TOP_YIELD_POOL_COUNT;
        length += topVotesLength;

        pools = new address[](length);
        weights = new uint256[](length);

        for (uint256 i = 1; i < length - TOP_YIELD_POOL_COUNT + 1; i++) {
            (uint256 addressIndex, uint256 weight) = unpack(topVotes[i]);
            pools[i - 1] = poolAddresses[addressIndex];
            weights[i - 1] = weight;
        }
        if (length > MAX_SUBMIT_POOL) {
            while (length > MAX_SUBMIT_POOL) {
                uint256 minValue = type(uint256).max;
                uint256 minIndex = 0;
                for (uint256 i = 0; i < length - TOP_YIELD_POOL_COUNT; i++) {
                    uint256 weight = weights[i];
                    if (weight < minValue) {
                        minValue = weight;
                        minIndex = i;
                    }
                }
                uint256 idx = length - TOP_YIELD_POOL_COUNT - 1;
                weights[minIndex] = weights[idx];
                pools[minIndex] = pools[idx];
                delete weights[idx];
                delete pools[idx];
                length -= 1;
            }

            assembly {
                mstore(pools, length)
                mstore(weights, length)
            }
        }

        // Valid VxSIG which is actually vote to klayswap.
        uint256 totalValidVxSIG = 0;
        for (uint256 i = 0; i < length - TOP_YIELD_POOL_COUNT; i++) {
            totalValidVxSIG += weights[i];
        }

        uint256 vxSIGTotalSupply = vxSIG.totalSupply() / 1e18;
        uint256 vxSIGNotUsedOrNotValid = vxSIGTotalSupply - totalValidVxSIG;

        uint256 eachDisributedVxSIG = vxSIGNotUsedOrNotValid /
            TOP_YIELD_POOL_COUNT;

        length -= TOP_YIELD_POOL_COUNT;

        for (uint256 i = 0; i < TOP_YIELD_POOL_COUNT; i++) {
            pools[length + i] = topYieldPools[i];
            weights[length + i] = eachDisributedVxSIG;
        }

        return (vxSIGTotalSupply, pools, weights);
    }

    /**
        @notice check if the given address is registered pool.
     */
    function isPool(address _pool) public view returns (bool) {
        return poolInfos[_pool].isInitiated;
    }

    /**
        @notice return pool count in sigma vote. -1 because index 0 is empty.
     */
    function getPoolCount() public view returns (uint256) {
        return poolAddresses.length - 1;
    }

    /**
        @notice Get an account's unused vote weight for for the current week
        @param _user Address to query
        @return uint Amount of unused weight
     */
    function availableVotes(address _user) public view returns (uint256) {
        uint256 userUsedVxSIG = userTotalUsedVxSIG[_user];
        uint256 totalWeight = vxSIG.balanceOf(_user) / 1e18;
        return totalWeight - userUsedVxSIG;
    }

    /**
        @notice get user total pool vote count.
     */
    function getUserVotesCount(address _user)
        external
        view
        override
        returns (uint256)
    {
        if (userPoolVotes[_user].length == 0) {
            return 0;
        } else {
            return userPoolVotes[_user].length - 1;
        }
    }
}
