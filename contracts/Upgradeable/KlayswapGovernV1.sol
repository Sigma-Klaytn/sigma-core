// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IKlayswapEscorw {
    function castVote(uint256 proposalId, bool support) external;
}

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

/// @notice KlayswapGovern forwards voting result of sigma for klayswap proposals.
contract KlayswapGovernV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    event InitialInfoSet(
        address vxSIG,
        address klayswapEscrow,
        uint256 quorumVotes,
        uint256 votingPeriod,
        address xSIGFarm,
        uint256 gapTime
    );

    event KlayswapProposalAdded(
        uint256 proposalId,
        uint256 startBlock,
        uint256 endBlock
    );

    /// @notice The name of this contract
    string public constant name = "Klayswap Govern";
    /// @notice Address of the vxSIG Token contract.
    IvxERC20 public vxSIG;
    /// @notice Address of xSIG farm.
    address public xSIGFarm;
    /// @notice Address of KlayswapEscorw contract.
    IKlayswapEscorw public klayswapEscrow;

    /// @notice The percentage of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed. It should be between 0 to 100.
    uint256 public quorumVotes;
    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod;
    /// @notice total count of proposal
    uint256 public proposalCount;
    /// @notice gap time with klayswap escorw.
    uint256 public gapTime;

    /// @notice voting info of user which indicate the list of voted proposal.
    mapping(address => uint256[]) public userVoteList;

    struct Proposal {
        /// @notice Unique id for looking up a proposal in Klayswap.
        uint256 id;
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
        /// @notice Flag marking whether the proposal has been forwarded to klayswap.
        bool forwarded;
        /// @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
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

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Forwardable,
        Forwarded,
        Expired
    }

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) public proposals;

    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(uint256 id, uint256 startBlock, uint256 endBlock);

    /// @notice An event emitted when a vote has been cast on a proposal
    event VoteCast(
        address voter,
        uint256 proposalId,
        bool support,
        uint256 votes
    );

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint256 id);

    /// @notice An event emitted when a proposal has been queued in the Timelock
    event ProposalQueued(uint256 id, uint256 eta);

    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint256 id);

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
        address _klayswapEscrow,
        uint256 _quorumVotes,
        uint256 _votingPeriod,
        address _xSIGFarm,
        uint256 _gapTime
    ) external onlyOwner {
        require(
            _quorumVotes >= 0 && _quorumVotes <= 100,
            "QuorumVotes should be between 0 to 100."
        );
        require(_votingPeriod > 0, "Voting period should be bigger than 0");
        vxSIG = IvxERC20(_vxSIG);
        klayswapEscrow = IKlayswapEscorw(_klayswapEscrow);
        quorumVotes = _quorumVotes;
        votingPeriod = _votingPeriod;
        xSIGFarm = _xSIGFarm;
        gapTime = _gapTime;
        emit InitialInfoSet(
            _vxSIG,
            _klayswapEscrow,
            quorumVotes,
            votingPeriod,
            xSIGFarm,
            gapTime
        );
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
     @notice sets quorumVotes 
     */
    //TODO : SHOULD BE CALLED BY GOVERNOR
    function setGapTime(uint256 _gapTime) external onlyOwner {
        gapTime = _gapTime;
    }

    function addKlayswapProposal(uint256 _proposalId, uint256 _startBlock)
        external
        onlyOwner
    {
        require(
            proposals[_proposalId].id == 0,
            "Proposal collision. There is already proposal with the given _proposalId"
        );

        Proposal storage newProposal = proposals[_proposalId];
        newProposal.startBlock = _startBlock;
        newProposal.endBlock = _startBlock + votingPeriod;

        proposalCount++;
        emit KlayswapProposalAdded(
            _proposalId,
            _startBlock,
            newProposal.endBlock
        );
    }

    function forwardVoteResultToKlayswap(uint256 _proposalId) public {
        require(
            state(_proposalId) == ProposalState.Forwardable,
            "Currently this proposal is not forwardable."
        );

        // Check if that pass the minimum participation rate
        Proposal storage proposal = proposals[_proposalId];

        require(
            proposal.forwarded == false,
            "Proposal has been already fowarded"
        );

        // If that pass the minimum participation rate, forward it to klayswap through KlayswapEscrow contract.
        if (quorumVotes != 0) {
            uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
            uint256 vxSIGTotalSupply = vxSIG.totalSupply() / 1e18;
            uint256 votePercentage = ((totalVotes * 1e18 * 100) /
                vxSIGTotalSupply) / 1e18;
            require(
                votePercentage >= quorumVotes,
                "Quorum has not been satisfied."
            );
        }

        if (proposal.forVotes > proposal.againstVotes) {
            klayswapEscrow.castVote(_proposalId, true);
        } else {
            klayswapEscrow.castVote(_proposalId, false);
        }

        proposal.forwarded = true;
    }

    function cancel(uint256 proposalId) public onlyOwner {
        ProposalState mState = state(proposalId);
        require(
            mState != ProposalState.Forwarded,
            "Cannot cancel forwarded proposal"
        );
        require(
            mState != ProposalState.Canceled,
            "Cannot cancel canceled proposal"
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.canceled = true;

        emit ProposalCanceled(proposalId);
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
        /**
        Pending : Not started yet.
        Active : The proposal has been activated. 
        Canceled : The proposal has been canceled.
        Fowarded : The proposal has been forwarded.
        Expired : The proposal has been expired since it has not met minium quorum.
        */
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.forwarded) {
            return ProposalState.Forwarded;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (
            block.number > proposal.endBlock &&
            block.number <= proposal.endBlock + gapTime
        ) {
            return ProposalState.Forwardable;
        } else {
            return ProposalState.Expired;
        }
    }

    function cancelUserVote(address _user) external {
        require(
            msg.sender == xSIGFarm,
            "This contract should be called from xSIG Farm."
        );

        uint256[] storage userVoteInfo = userVoteList[_user];
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
            }
        }

        delete userVoteList[_user];
    }

    function castVote(uint256 proposalId, bool support) public {
        return _castVote(msg.sender, proposalId, support);
    }

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
        require(
            receipt.hasVoted == false && receipt.canceled == false,
            "Voter already voted"
        );

        if (support) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        userVoteList[voter].push(proposalId);

        emit VoteCast(voter, proposalId, support, votes);
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }
}
