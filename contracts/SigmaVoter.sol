pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "./interfaces/sigma/IvxERC20.sol";
import "./interfaces/sigma/IxSIGFarm.sol";
import "./interfaces/klayswap/IPoolVoting.sol";
import "./interfaces/klayswap/IVotingKSP.sol";
import "./interfaces/sigma/ISigmaVoter.sol";

// import "./interfaces/solidly/IBaseV1Voter.sol";

contract SigmaVoter is Ownable, ISigmaVoter {
    IvxERC20 public vxSIG;
    IPoolVoting public poolVoting;
    IVotingKSP public votingKSP;
    IxSIGFarm public xSIGFarm;

    uint256 constant WEEK = 86400 * 7;
    uint256 public startTime;

    // the maximum number of pools to submit a vote for
    // must be low enough that `submitVotes` can submit the vote
    // data without the call reaching the block gas limit
    uint256 public constant MAX_SUBMITTED_VOTES = 50;

    // beyond the top `MAX_SUBMITTED_VOTES` pools, we also record several
    // more highest-voted pools. this mitigates against inaccuracies
    // in the lower end of the vote weights that can be caused by negative voting.
    uint256 constant MAX_VOTES_WITH_BUFFER = MAX_SUBMITTED_VOTES + 10;

    // token -> week -> weight allocated
    mapping(address => mapping(uint256 => int256)) public poolVotes;
    // user -> week -> weight used
    mapping(address => mapping(uint256 => uint256)) public userVotes;

    //user -> week ->  pool -> weight used
    mapping(address => mapping(uint256 => mapping(address => uint256))) userPoolVotes;

    // [uint24 id][int40 poolVotes]
    // handled as an array of uint64 to allow memory-to-storage copy
    mapping(uint256 => uint64[MAX_VOTES_WITH_BUFFER]) topVotes;

    address[] poolAddresses;
    mapping(address => PoolData) poolData;

    uint256 lastWeek; // week of the last received vote (+1)
    uint256 topVotesLength; // actual number of items stored in `topVotes`
    uint256 minTopVote; // smallest vote-weight for pools included in `topVotes`
    uint256 minTopVoteIndex; // `topVotes` index where the smallest vote is stored (+1)

    struct Vote {
        address pool;
        int256 weight;
    }

    struct PoolData {
        uint24 addressIndex; // address index : 이 pool 의 주소 데이터의 인덱스
        uint16 currentWeek; // 그 주에 투표를 했었는지 안했었는지를 확인하는 데이터
        uint8 topVotesIndex; // 이건 모르겠음.. Top Vote 에서 얘가 몇번째인지 확인하는 걸까..? 예를 들어 탑보트가 20 개 있는데 이게 30 개 한다던지 이런거..
    }

    event VotedForPoolIncentives(
        address indexed voter,
        address[] pools,
        int256[] voteWeights,
        uint256 usedWeight,
        uint256 totalWeight
    );
    event PoolProtectionSet(
        address address1,
        address address2,
        uint40 lastUpdate
    );
    event SubmittedVote(address caller, address[] pools, int256[] weights);

    constructor() {
        // position 0 is empty so that an ID of 0 can be interpreted as unset
        poolAddresses.push(address(0));
    }

    function setInitialInfo(
        IvxERC20 _vxSIG,
        IPoolVoting _poolVoting,
        IVotingKSP _votingKSP,
        IxSIGFarm _IxSIGFarm
    ) external onlyOwner {
        vxSIG = _vxSIG;
        poolVoting = _poolVoting;
        votingKSP = _votingKSP;
        IxSIGFarm = _IxSIGFarm;
        startTime = IxSIGFarm.startTime();
    }

    function getWeek() public view returns (uint256) {
        if (startTime == 0) return 0;
        return (block.timestamp - startTime) / WEEK;
    }

    /**
        @notice The current pools and weights that would be submitted
                when calling `submitVotes`
     */
    function getCurrentVotes()
        external
        view
        override
        returns (Vote[] memory votes)
    {
        (address[] memory pools, int256[] memory weights) = _currentVotes();
        votes = new Vote[](pools.length);
        for (uint256 i = 0; i < votes.length; i++) {
            votes[i] = Vote({pool: pools[i], weight: weights[i]});
        }
        return votes;
    }

    /**
        @notice Get an account's unused vote weight for for the current week
        @param _user Address to query
        @return uint Amount of unused weight
     */
    function availableVotes(address _user) external view returns (uint256) {
        uint256 week = getWeek();
        uint256 usedWeight = userVotes[_user][week];
        uint256 totalWeight = vxSIG.balanceOf(_user);
        return totalWeight - usedWeight;
    }

    /**
        @notice Vote for one or more pools
        @dev Vote-weights received via this function are aggregated but not sent to Klayswap.
             To submit the vote to Klayswap you must call `submitVotes`.
             Voting does not carry over between weeks, votes must be resubmitted.
        @param _pools Array of pool addresses to vote for
        @param _weights Array of vote weights.
     */
    function voteForPools(address[] calldata _pools, int256[] calldata _weights)
        external
    {
        require(
            _pools.length == _weights.length,
            "_pools.length != _weights.length"
        );
        require(_pools.length > 0, "Must vote for at least one pool");

        uint256 week = getWeek();
        uint256 totalUserWeight;

        // copy these values into memory to avoid repeated SLOAD / SSTORE ops
        uint256 _topVotesLengthMem = topVotesLength; // 현재 예를 들어 topVote가 3개있다고 치자
        uint256 _minTopVoteMem = minTopVote; // top vote 에 들어가기 위해 필요한 vote 의 최소값
        uint256 _minTopVoteIndexMem = minTopVoteIndex; // 몇 번째가 가장 최소 vote 가 들어있는 곳인지 저장
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes[week]; // topVotes 저장됨

        if (week + 1 > lastWeek) {
            // it means there has no votes this week
            _topVotesLengthMem = 0;
            _minTopVoteMem = 0;
            lastWeek = week + 1;
        }
        for (uint256 x = 0; x < _pools.length; x++) {
            address _pool = _pools[x];
            int256 _weight = _weights[x];
            totalUserWeight += _weight;

            require(_weight != 0, "Cannot vote zero");

            // update accounting for this week's votes
            int256 poolWeight = poolVotes[_pool][week];
            uint256 id = poolData[_pool].addressIndex;
            if (poolWeight == 0 || poolData[_pool].currentWeek <= week) {
                if (id == 0) {
                    id = poolAddresses.length;
                    poolAddresses.push(_pool);
                }
                poolData[_pool] = PoolData({
                    addressIndex: uint24(id),
                    currentWeek: uint16(week + 1),
                    topVotesIndex: 0
                });
            }

            int256 newPoolWeight = poolWeight + _weight;
            assert(newPoolWeight < 2**39); // this should never be possible

            poolVotes[_pool][week] = newPoolWeight;

            if (poolData[_pool].topVotesIndex > 0) {
                // pool already exists within the list
                uint256 voteIndex = poolData[_pool].topVotesIndex - 1;

                if (newPoolWeight == 0) {
                    // pool has a new vote-weight of 0 and so is being removed
                    poolData[_pool] = PoolData({
                        addressIndex: uint24(id),
                        currentWeek: 0,
                        topVotesIndex: 0
                    });
                    _topVotesLengthMem -= 1;
                    if (voteIndex == _topVotesLengthMem) {
                        delete t[voteIndex];
                    } else {
                        t[voteIndex] = t[_topVotesLengthMem];
                        uint256 addressIndex = t[voteIndex] >> 40;
                        poolData[poolAddresses[addressIndex]]
                            .topVotesIndex = uint8(voteIndex + 1);
                        delete t[_topVotesLengthMem];
                        if (_minTopVoteIndexMem > _topVotesLengthMem) {
                            // the value we just shifted was the minimum weight
                            _minTopVoteIndexMem = voteIndex + 1;
                            // continue here to avoid iterating to locate the new min index
                            continue;
                        }
                    }
                } else {
                    // modify existing record for this pool within `topVotes`
                    t[voteIndex] = pack(id, newPoolWeight);
                    if (absNewPoolWeight < _minTopVoteMem) {
                        // if new weight is also the new minimum weight
                        _minTopVoteMem = absNewPoolWeight;
                        _minTopVoteIndexMem = voteIndex + 1;
                        // continue here to avoid iterating to locate the new min voteIndex
                        continue;
                    }
                }
                if (voteIndex == _minTopVoteIndexMem - 1) {
                    // iterate to find the new minimum weight
                    (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                        t,
                        _topVotesLengthMem
                    );
                }
            } else if (_topVotesLengthMem < MAX_VOTES_WITH_BUFFER) {
                // pool is not in `topVotes`, and `topVotes` contains less than
                // MAX_VOTES_WITH_BUFFER items, append
                t[_topVotesLengthMem] = pack(id, newPoolWeight); // 새롭게 추가해서 저장
                _topVotesLengthMem += 1; // top vote length 를 저장
                poolData[_pool].topVotesIndex = uint8(_topVotesLengthMem); // top vote 에서 내 위치를 저장
                if (absNewPoolWeight < _minTopVoteMem || _minTopVoteMem == 0) {
                    // 만약 새로운 풀의 투표수가 최소 투표수 보다 작거나 최소 투표수 기준이 0이면
                    // new weight is the new minimum weight
                    // 새로운 min topvote 가 new pool weight 가 됨
                    _minTopVoteMem = absNewPoolWeight;

                    // min top vote index 는 현재 풀의 top vote index 가 됨
                    _minTopVoteIndexMem = poolData[_pool].topVotesIndex;
                }
            } else if (absNewPoolWeight > _minTopVoteMem) {
                // `topVotes` contains MAX_VOTES_WITH_BUFFER items,
                // pool is not in the array, and weight exceeds current minimum weight

                // replace the pool at the current minimum weight index
                uint256 addressIndex = t[_minTopVoteIndexMem - 1] >> 40;
                poolData[poolAddresses[addressIndex]] = PoolData({
                    addressIndex: uint24(addressIndex),
                    currentWeek: 0,
                    topVotesIndex: 0
                });
                t[_minTopVoteIndexMem - 1] = pack(id, newPoolWeight);
                poolData[_pool].topVotesIndex = uint8(_minTopVoteIndexMem);

                // iterate to find the new minimum weight
                (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                    t,
                    MAX_VOTES_WITH_BUFFER
                );
            }
        }

        // make sure user has not exceeded available weight
        totalUserWeight += userVotes[msg.sender][week];
        uint256 totalWeight = tokenLocker.userWeight(msg.sender) / 1e18;
        require(totalUserWeight <= totalWeight, "Available votes exceeded");

        // write memory vars back to storage
        topVotes[week] = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;
        userVotes[msg.sender][week] = totalUserWeight;

        emit VotedForPoolIncentives(
            msg.sender,
            _pools,
            _weights,
            totalUserWeight,
            totalWeight
        );
    }

    /**
        @notice Submit the current votes to Solidly
        @dev This function is unguarded and so votes may be submitted at any time.
             Solidly has no restriction on the frequency that an account may vote,
             however emissions are only calculated from the active votes at the
             beginning of each epoch week.
     */
    function submitVotes() external returns (bool) {
        (address[] memory pools, int256[] memory weights) = _currentVotes();
        //klayswap vote
        emit SubmittedVote(msg.sender, pools, weights);
        return true;
    }

    function _currentVotes()
        internal
        view
        returns (address[] memory pools, int256[] memory weights)
    {
        uint256 week = getWeek();
        uint256 length = 0;
        if (week + 1 == lastWeek) {
            // `lastWeek` only updates on a call to `voteForPool`
            // if the current week is > `lastWeek`, there have not been any votes this week
            length += topVotesLength;
        }

        uint256[MAX_VOTES_WITH_BUFFER] memory absWeights;
        pools = new address[](length);
        weights = new int256[](length);

        // unpack `topVotes`
        for (uint256 i = 0; i < length - 2; i++) {
            (uint256 id, int256 weight) = unpack(topVotes[week][i]);
            pools[i] = poolAddresses[id];
            weights[i] = weight;
            absWeights[i] = abs(weight);
        }

        // if more than `MAX_SUBMITTED_VOTES` pools have votes, discard the lowest weights
        if (length > MAX_SUBMITTED_VOTES) {
            while (length > MAX_SUBMITTED_VOTES) {
                uint256 minValue = type(uint256).max;
                uint256 minIndex = 0;
                for (uint256 i = 0; i < length; i++) {
                    uint256 weight = absWeights[i];
                    if (weight < minValue) {
                        minValue = weight;
                        minIndex = i;
                    }
                }
                uint256 idx = length - 1;
                weights[minIndex] = weights[idx];
                pools[minIndex] = pools[idx];
                absWeights[minIndex] = absWeights[idx];
                delete weights[idx];
                delete pools[idx];
                length -= 1;
            }
            assembly {
                mstore(pools, length)
                mstore(weights, length)
            }
        }

        // calculate absolute total weight and find the indexes for the hardcoded pools
        // uint256 totalWeight;
        // uint256[2] memory fixedVoteIds;
        // address[2] memory _fixedVotePools = fixedVotePools;
        // for (uint256 i = 0; i < length - 2; i++) {
        //     totalWeight += absWeights[i];
        //     if (pools[i] == _fixedVotePools[0]) fixedVoteIds[0] = i + 1;
        //     else if (pools[i] == _fixedVotePools[1]) fixedVoteIds[1] = i + 1;
        // }

        // // add 5% hardcoded vote for SOLIDsex/SOLID and SEX/WFTM
        // int256 fixedWeight = int256((totalWeight * 11) / 200);
        // if (fixedWeight == 0) fixedWeight = 1;
        // length -= 2;
        // for (uint256 i = 0; i < 2; i++) {
        //     if (fixedVoteIds[i] == 0) {
        //         pools[length + i] = _fixedVotePools[i];
        //         weights[length + i] = fixedWeight;
        //     } else {
        //         weights[fixedVoteIds[i] - 1] += fixedWeight;
        //     }
        // }

        //TODO high ksp goes to에 남은 vxSIG 를 투자

        return (pools, weights);
    }

    function _findMinTopVote(
        uint64[MAX_VOTES_WITH_BUFFER] memory t,
        uint256 length
    ) internal pure returns (uint256, uint256) {
        uint256 _minTopVoteMem = type(uint256).max;
        uint256 _minTopVoteIndexMem;
        for (uint256 i = 0; i < length; i++) {
            uint256 value = t[i] % 2**39;
            if (value < _minTopVoteMem) {
                _minTopVoteMem = value;
                _minTopVoteIndexMem = i + 1;
            }
        }
        return (_minTopVoteMem, _minTopVoteIndexMem);
    }

    function abs(int256 value) internal pure returns (uint256) {
        return uint256(value > 0 ? value : -value);
    }

    function pack(uint256 id, int256 weight) internal pure returns (uint64) {
        // tightly pack as [uint24 id][int40 weight] for storage in `topVotes`
        uint64 value = uint64((id << 40) + abs(weight));
        // if (weight < 0) value += 2**39;
        return value;
    }

    function unpack(uint256 value)
        internal
        pure
        returns (uint256 id, int256 weight)
    {
        // unpack a value in `topVotes`
        id = (value >> 40);
        weight = int256(value % 2**40);
        if (weight > 2**39) weight = -(weight % 2**39);
        return (id, weight);
    }
}
