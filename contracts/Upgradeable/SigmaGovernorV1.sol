// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

/// @notice SigmaGovernorV1 contract is for collect user's opinions and serve them.
contract SigmaGovernorV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    struct Proposal {
        /// @notice Unique id for looking up a proposal
        uint256 id;
        /// @notice Creator of the proposal
        address proposer;
        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;
        /// @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
        /// @notice latest updated vxSIG Total Supply. This is how quorum satisfaction is going to be calculated.
        uint256 lastestVxSIGTotalSupply;
        /// @notice Result of the proposal
        ProposalResult result;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        /// @notice Whether or not a vote has been cast
        bool hasVoted;
        /// @notice Whether or not the voter supports the proposal
        bool support;
        /// @notice The number of votes the voter had, which were cast
        uint256 votes;
        /// @notice Whether or not a vote has been canceled after vxSIG balance goes to 0. User can't re-vote on same proposal after this.
        bool canceled;
    }

    struct ProposalResult {
        /// @notice result of the proposal
        Result result;
        /// @notice block number when the contract ended.
        uint256 endBlockNubmer;
    }

    event InitialInfoSet(
        address vxSIG,
        uint256 quorumVotes,
        uint256 votingPeriod,
        address xSIGFarm
    );

    event ProposalAdded(
        uint256 proposalId,
        uint256 startBlock,
        uint256 endBlock,
        address proposer
    );

    /**
        Pending : Not started yet.
        Active : The proposal has been activated. 
        Canceled : The proposal has been canceled.
        Ended : The Proposal voting perioud has been ended.
        */
    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Ended
    }

    /**
        Succeded : Proposal has passed.
        Defeated : Proposal has failed.
        Expired : Proposal didn't meet the quorum and failed to pass.
        */
    /// @notice Possible states that a proposal may be in
    enum Result {
        Succedeed, // Pass the quorum, and For > Against.
        Defeated, // Passed the quorum, but For <= Against.
        Expired // Didn't meet the quorum.
    }

    /// @notice An event emitted when a vote has been cast on a proposal
    event VoteCast(
        address voter,
        uint256 proposalId,
        bool support,
        uint256 votes
    );

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint256 id);

    /// @notice The name of this contract
    string public constant name = "Sigma Govern";
    /// @notice Address of the vxSIG Token contract.
    IvxERC20 public vxSIG;
    /// @notice Address of xSIG farm.
    address public xSIGFarm;

    /// @notice The percentage of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed. It should be between 0 to 100.
    uint256 public quorumVotes;
    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod;
    /// @notice total count of proposal
    uint256 public proposalCount;
    /// @notice total proposal list
    uint256[] public proposalList;

    /// @notice voting info of user which indicate the list of voted proposal.
    mapping(address => uint256[]) public userVoteList;

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) public proposals;

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
        address _vxSIG,
        uint256 _quorumVotes,
        uint256 _votingPeriod,
        address _xSIGFarm
    ) external onlyOwner {
        require(
            _quorumVotes >= 0 && _quorumVotes <= 100,
            "QuorumVotes should be between 0 to 100."
        );
        require(_votingPeriod > 0, "Voting period should be bigger than 0");
        vxSIG = IvxERC20(_vxSIG);
        quorumVotes = _quorumVotes;
        votingPeriod = _votingPeriod;
        xSIGFarm = _xSIGFarm;
        emit InitialInfoSet(_vxSIG, quorumVotes, votingPeriod, xSIGFarm);
    }

    /**
     @notice sets quorumVotes 
    */
    //TODO : SHOULD BE CALLED BY GOVERNOR
    function setQuorumVotes(uint256 _quorumVotes) external onlyOwner {
        require(
            _quorumVotes >= 0 && _quorumVotes <= 100,
            "QuorumVotes should be between 0 to 100."
        );
        quorumVotes = _quorumVotes;
    }

    /**
     @notice sets quorumVotes 
     */
    //TODO : SHOULD BE CALLED BY GOVERNOR
    function setVotingPeriod(uint256 _votingPeriod) external onlyOwner {
        votingPeriod = _votingPeriod;
    }

    /**
     @notice sets start block of proposal 
     */
    //TODO : SHOULD BE CALLED BY GOVERNOR
    function setStartBlockOfProposal(uint256 _proposalId, uint256 _startBlock)
        external
        onlyOwner
    {
        require(
            _proposalId > 0 && proposals[_proposalId].id != 0,
            "invalid proposal id"
        );
        proposals[_proposalId].startBlock = _startBlock;
    }

    /**
     @notice sets end block of proposal 
     */
    //TODO : SHOULD BE CALLED BY GOVERNOR
    function setEndBlockOfProposal(uint256 _proposalId, uint256 _endBlock)
        external
        onlyOwner
    {
        require(
            _proposalId > 0 && proposals[_proposalId].id != 0,
            "invalid proposal id"
        );
        proposals[_proposalId].endBlock = _endBlock;
    }

    function addProposal(uint256 _startBlock, address _proposer)
        external
        onlyOwner
    {
        uint256 id = ++proposalCount;
        Proposal storage newProposal = proposals[id];
        newProposal.id = id;
        newProposal.startBlock = _startBlock;
        newProposal.endBlock = _startBlock + votingPeriod;
        newProposal.proposer = _proposer;
        newProposal.lastestVxSIGTotalSupply = vxSIG.totalSupply();

        proposalList.push(id);
        emit ProposalAdded(id, _startBlock, newProposal.endBlock, _proposer);
    }

    /* ========== External Public Function  ========== */

    function finalizeProposal(uint256 _proposalId) external {
        require(
            state(_proposalId) == ProposalState.Ended,
            "Currently this proposal is not Ended."
        );
        // Check if that pass the minimum participation rate
        Proposal storage proposal = proposals[_proposalId];
        ProposalResult storage result = proposal.result;
        require(
            result.endBlockNubmer == 0,
            "This proposal has been already finalized."
        );

        // Set result : endBlocknumber
        result.endBlockNubmer = block.number;

        // If that pass the minimum participation rate
        if (quorumVotes != 0) {
            uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
            uint256 vxSIGTotalSupply = proposal.lastestVxSIGTotalSupply / 1e18;
            uint256 votePercentage = ((totalVotes * 1e18 * 100) /
                vxSIGTotalSupply) / 1e18;

            if (votePercentage >= quorumVotes) {
                if (proposal.forVotes > proposal.againstVotes) {
                    result.result = Result.Succedeed;
                } else {
                    result.result = Result.Defeated;
                }
            } else {
                result.result = Result.Expired;
            }
        } else {
            if (proposal.forVotes > proposal.againstVotes) {
                result.result = Result.Succedeed;
            } else {
                result.result = Result.Defeated;
            }
        }
    }

    function cancel(uint256 proposalId) external onlyOwner {
        ProposalState mState = state(proposalId);

        require(
            mState != ProposalState.Canceled,
            "Cannot cancel canceled proposal"
        );

        require(mState != ProposalState.Ended, "Cannot cancel ended proposal");

        Proposal storage proposal = proposals[proposalId];
        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
    }

    function cancelUserVotes(address _user) external {
        require(
            msg.sender == xSIGFarm,
            "This contract should be called from xSIG Farm."
        );

        uint256[] storage userVoteInfo = userVoteList[_user];
        if (userVoteInfo.length > 0) {
            for (uint256 i = 0; i < userVoteInfo.length; i++) {
                uint256 proposalId = userVoteInfo[i];
                if (state(proposalId) == ProposalState.Active) {
                    Proposal storage proposal = proposals[proposalId];
                    Receipt storage receipt = proposal.receipts[_user];
                    if (receipt.support) {
                        proposal.forVotes = sub256(
                            proposal.forVotes,
                            receipt.votes
                        );
                    } else {
                        proposal.againstVotes = sub256(
                            proposal.againstVotes,
                            receipt.votes
                        );
                    }
                    receipt.canceled = true;

                    proposal.lastestVxSIGTotalSupply = vxSIG.totalSupply();
                }
            }

            delete userVoteList[_user];
        }
    }

    function castVote(uint256 proposalId, bool support) public {
        return _castVote(msg.sender, proposalId, support);
    }

    /* ========== Internal Function  ========== */

    function _castVote(
        address voter,
        uint256 proposalId,
        bool support
    ) internal {
        require(
            state(proposalId) == ProposalState.Active,
            "Voting is not active."
        );

        uint256 votes = vxSIG.balanceOf(voter) / 1e18;
        require(votes > 0, "No vxSIG to vote. It should be >= 1");

        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "Voter already voted");

        if (support) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        userVoteList[voter].push(proposalId);

        proposal.lastestVxSIGTotalSupply = vxSIG.totalSupply();

        emit VoteCast(voter, proposalId, support, votes);
    }

    /* ========== View & Pure Function  ========== */

    function add256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getReceipt(uint256 proposalId, address voter)
        public
        view
        returns (Receipt memory)
    {
        return proposals[proposalId].receipts[voter];
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        require(
            proposalId > 0 && proposals[proposalId].id != 0,
            "invalid proposal id"
        );

        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else {
            return ProposalState.Ended;
        }
    }

    function getUserVoteList(address _voter)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory userVotes = userVoteList[_voter];
        if (userVotes.length != 0) {
            uint256[] memory votes = new uint256[](userVotes.length);
            for (uint256 i = 0; i < userVotes.length; i++) {
                votes[i] = userVotes[i];
            }
            return votes;
        } else {
            uint256[] memory votes = new uint256[](0);
            return votes;
        }
    }

    function getProposalResult(uint256 _proposalId)
        external
        view
        returns (Result, uint256)
    {
        require(
            state(_proposalId) == ProposalState.Ended,
            "Proposal should be ended to get an proposal result"
        );
        Proposal storage proposal = proposals[_proposalId];
        ProposalResult memory result = proposal.result;
        require(
            result.endBlockNubmer != 0,
            "Proposal has not been officially ended by the admin. Please call finalizeProposal()"
        );

        return (result.result, result.endBlockNubmer);
    }

    function isProposalFinalized(uint256 _proposalId)
        external
        view
        returns (bool)
    {
        require(
            _proposalId > 0 && proposals[_proposalId].id != 0,
            "invalid proposal id"
        );
        Proposal storage proposal = proposals[_proposalId];
        ProposalResult memory result = proposal.result;
        if (result.endBlockNubmer > 0) {
            return true;
        } else {
            return false;
        }
    }
}
