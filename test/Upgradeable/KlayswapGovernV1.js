const {
    makeVxSIGToken,
    UUPSProxy,
    vxSIGToken,
    KlayswapGovernV1,
    makeKlayswapGovernV1,
    MockERC20,
    makeUUPSProxy,
    KlayswapEscrowGovernTest,
    xSIGFarmGovernTest,
    makeKlayswapEscrowGovernTest,
    makeXSIGFarmGovernTest
} = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual,
    time
} = require('../Utils/JS');
const { MAX_INT256 } = require('@openzeppelin/test-helpers/src/constants');
const { BigNumber } = require('ethers');

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Add klayswap proposal (Admin)
 * 2. Cast vote (User)
 * 3. Cancel all votes (User)
 * 4. Forward Vote Result to Klayswap (Public)
 *
 * <View Function>
 * 1. getReceipt
 * 2. state 
 * 3. userVoteList
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.


contract('KlayswapGovernV1', function (accounts) {
    let root = accounts[0];
    let userA = accounts[1];
    let userB = accounts[2];
    let userC = accounts[3];
    let userD = accounts[4];


    let vxSIGToken;

    let KlayswapGovernImpl;
    let KlayswapGovernProxy;
    let klayswapGovern;
    let KlayswapEscrowGovern;
    let xSIGFarmGovern;

    let VOTING_PERIOD;
    let QUORUM_VOTES;
    let GAP_TIME;

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {

            // [Test Scenario]
            // 1. Deploy xSIGFarmGovernTest -> KlayswapEscorwGovernTest -> KlayswapGovern
            // 2. Execute setInitialInfo of Klayswap Govern
            // 3. Set KlayswapGovern Address for xSIGFarm and KlayswapEscorw
            // 4. Add Proposal to Klayswap Govern By Admin
            // 5. Vote for the proposal using vxSIG
            // 6. Forward vote result to klayswap. 


            //Deploy from the start.
            vxSIGToken = await makeVxSIGToken();

            KlayswapGovernImpl = await makeKlayswapGovernV1();
            KlayswapGovernProxy = await makeUUPSProxy(KlayswapGovernImpl.address, "0x")
            klayswapGovern = await KlayswapGovernV1.at(KlayswapGovernProxy.address);

            await klayswapGovern.initialize()

            KlayswapEscrowGovern = await makeKlayswapEscrowGovernTest();
            xSIGFarmGovern = await makeXSIGFarmGovernTest();

            VOTING_PERIOD = new BN(30)
            QUORUM_VOTES = new BN(10)
            GAP_TIME = new BN(100)

            await vxSIGToken.setOperator([root]);
        });

        it('Test : 0.SetInitialInfo', async () => {

            // 1. Check onlyOwner Function 
            await expectRevert(klayswapGovern.setInitialInfo(vxSIGToken.address, KlayswapEscrowGovern.address, QUORUM_VOTES, VOTING_PERIOD, xSIGFarmGovern.address, GAP_TIME, { from: userA }), 'Ownable: caller is not the owner')

            // 2. Check Reverts
            await expectRevert(klayswapGovern.setInitialInfo(vxSIGToken.address, KlayswapEscrowGovern.address, new BN(101), VOTING_PERIOD, xSIGFarmGovern.address, GAP_TIME, { from: root }), 'QuorumVotes should be between 0 to 100.')
            await expectRevert(klayswapGovern.setInitialInfo(vxSIGToken.address, KlayswapEscrowGovern.address, QUORUM_VOTES, new BN(0), xSIGFarmGovern.address, GAP_TIME, { from: root }), 'Voting period should be bigger than 0')


            // 2. Check if Initial Info has been set. 
            await klayswapGovern.setInitialInfo(vxSIGToken.address, KlayswapEscrowGovern.address, QUORUM_VOTES, VOTING_PERIOD, xSIGFarmGovern.address, GAP_TIME, { from: root })

            expectEqual(await klayswapGovern.quorumVotes(), new BN(10));
            expectEqual(await klayswapGovern.votingPeriod(), new BN(30));
            expectEqual(await klayswapGovern.proposalCount(), new BN(0));
            expectEqual(await klayswapGovern.vxSIG(), vxSIGToken.address);
            expectEqual(await klayswapGovern.xSIGFarm(), xSIGFarmGovern.address);
            expectEqual(await klayswapGovern.klayswapEscrow(), KlayswapEscrowGovern.address);
        });

        it('Test : 1.Set Klayswap Govern Address', async () => {

            await KlayswapEscrowGovern.setKlayswapGoverAddr(klayswapGovern.address);
            await KlayswapEscrowGovern.setklayswapGovernorAddr(vxSIGToken.address); // Just for the test. It should be klayswap governor address in production.

            expectEqual(await KlayswapEscrowGovern.kga(), klayswapGovern.address);
            expectEqual(await KlayswapEscrowGovern.klayswapGovernor(), vxSIGToken.address);

            await xSIGFarmGovern.setKlayswapGov(klayswapGovern.address);
            expectEqual(await xSIGFarmGovern.kga(), klayswapGovern.address);

        });

        it('Test : 2.Add Proposal', async () => {

            //1. Add Proposal with start block. 
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            const startBlock = (new BN(currentBlockNum)).add(new BN(10))
            const klayswapProposalId = new BN(10)
            let receipt = await klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)

            expectEqual(await klayswapGovern.proposalCount(), new BN(1))

            expectEvent(receipt, "KlayswapProposalAdded", {
                proposalId: klayswapProposalId,
                startBlock: startBlock,
                endBlock: startBlock.add(VOTING_PERIOD)
            })


            /** Proposal 
             * 
             *  struct Proposal {
                uint256 id;
                uint256 startBlock;
                uint256 endBlock;
                uint256 forVotes;
                uint256 againstVotes;
                bool canceled;
                bool forwarded;
                mapping(address => Receipt) receipts; }
             *  */

            let proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[1], startBlock);
            expectEqual(proposal[2], startBlock.add(VOTING_PERIOD));
            expectEqual(proposal[3], new BN(0));
            expectEqual(proposal[4], new BN(0));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            console.log(proposal[7])


            //3. Check Revert. 
            await expectRevert(klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock), "Proposal collision. There is already proposal with the given _proposalId")

            //4. Check Proposal's state.
            console.log("current proposal state : ", (await klayswapGovern.state(klayswapProposalId)).toString())
        });

        it('Test : 3 . User Vote for the Proposal', async () => {
            await vxSIGToken.mint(userA, bnMantissa(100), { from: root })
            await vxSIGToken.mint(userB, bnMantissa(200), { from: root })
            await vxSIGToken.mint(userC, bnMantissa(300), { from: root })

            const klayswapProposalId = new BN(10)

            // 0. Check Reverts.
            await expectRevert(klayswapGovern.castVote(new BN(0), false), "invalid proposal id")
            await expectRevert(klayswapGovern.castVote(klayswapProposalId, false), "Voting is not active.")


            // 1. User A Cast vote.
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            for (let i = 0; i < 10; i++) {
                evmMine()
            }
            await expectRevert(klayswapGovern.castVote(klayswapProposalId, true, { from: root }), "No vxSIG to vote. It should be >= 1")

            let receipt = await klayswapGovern.castVote(klayswapProposalId, true, { from: userA })

            // try to revote. 
            await expectRevert(klayswapGovern.castVote(klayswapProposalId, true, { from: userA }), "Voter already voted")

            // 2. Check event and variable of the proposal. 
            expectEvent(receipt, "VoteCast", {
                voter: userA,
                proposalId: klayswapProposalId,
                support: true,
                votes: new BN(100)
            })



            // 3. Get receipt

            let voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userA)
            expectEqual(voteReceipt[0], true)
            expectEqual(voteReceipt[1], true)
            expectEqual(voteReceipt[2], new BN(100))
            expectEqual(voteReceipt[3], false)

            // 4. Check Proposal Variables

            let proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(100));
            expectEqual(proposal[4], new BN(0));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            // 4-1. Check that unvote user receipt

            voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userB)
            expectEqual(voteReceipt[0], false)
            expectEqual(voteReceipt[1], false)
            expectEqual(voteReceipt[2], new BN(0))
            expectEqual(voteReceipt[3], false)

            // 5. User B cast Vote
            let receipt2 = await klayswapGovern.castVote(klayswapProposalId, true, { from: userB })
            expectEvent(receipt2, "VoteCast", {
                voter: userB,
                proposalId: klayswapProposalId,
                support: true,
                votes: new BN(200)
            })

            // 6. Check User B Vote 
            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(300));
            expectEqual(proposal[4], new BN(0));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userB)
            expectEqual(voteReceipt[0], true)
            expectEqual(voteReceipt[1], true)
            expectEqual(voteReceipt[2], new BN(200))
            expectEqual(voteReceipt[3], false)

            // 7. User C cast vote 
            let receipt3 = await klayswapGovern.castVote(klayswapProposalId, false, { from: userC })
            expectEvent(receipt3, "VoteCast", {
                voter: userC,
                proposalId: klayswapProposalId,
                support: false,
                votes: new BN(300)
            })

            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(300));
            expectEqual(proposal[4], new BN(300));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userC)
            expectEqual(voteReceipt[0], true)
            expectEqual(voteReceipt[1], false)
            expectEqual(voteReceipt[2], new BN(300))
            expectEqual(voteReceipt[3], false)

            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number after voting', currentBlockNum);
        })


        it('Test : 4. Forward Vote to Klayswap ', async () => {

            const klayswapProposalId = new BN(10)

            let proposal = await klayswapGovern.proposals(klayswapProposalId);
            console.log("Proposal Start Block : ", proposal[1].toString());
            console.log("Proposal End Block : ", proposal[2].toString());
            console.log("Proposal state : ", (await klayswapGovern.state(klayswapProposalId)).toString())

            // 0. Check Reverts.

            await expectRevert(klayswapGovern.forwardVoteResultToKlayswap(klayswapProposalId), "Currently this proposal is not forwardable.")

            // 1. Qurom Check. 
            for (let i = 0; i < VOTING_PERIOD; i++) {
                evmMine()
            }

            console.log("Proposal state : Should be 3 ", (await klayswapGovern.state(klayswapProposalId)).toString())


            // Change vxSIG Total supply to 6100. So that Quorum doesn't pass. 
            console.log('before vxSIG Total Supply : ', (await vxSIGToken.totalSupply()).toString())
            await vxSIGToken.mint(userD, bnMantissa(5500), { from: root })
            console.log('after vxSIG Total Supply : ', (await vxSIGToken.totalSupply()).toString())

            await expectRevert(klayswapGovern.forwardVoteResultToKlayswap(klayswapProposalId), "Quorum has not been satisfied.")

            // 2.  Change Quorum to 5 
            await expectRevert(klayswapGovern.setQuorumVotes(new BN(5), { from: userA }), 'Ownable: caller is not the owner')
            await klayswapGovern.setQuorumVotes(new BN(5), { from: root })

            // 3. proposal forwarding. 

            let receipt = await klayswapGovern.forwardVoteResultToKlayswap(klayswapProposalId)
            await expectEvent.inTransaction(receipt.tx, KlayswapEscrowGovernTest, "CastVote", {
                proposalId: klayswapProposalId,
                support: false
            })

            // Check Variable
            expectEqual(await klayswapGovern.state(klayswapProposalId), new BN(4))
            expectEqual((await klayswapGovern.proposals(klayswapProposalId))[6], true)

            // 4. Check reverts agian.
            await expectRevert(klayswapGovern.forwardVoteResultToKlayswap(klayswapProposalId), "Currently this proposal is not forwardable.")
        });

        it('Test : 5. Add Proposal & Cancel Proposal ', async () => {

            //1. Add Proposal with start block. 
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            let startBlock = (new BN(currentBlockNum)).add(new BN(0))
            let klayswapProposalId = new BN(11)
            let receipt = await klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)

            expectEqual(await klayswapGovern.proposalCount(), new BN(2))

            expectEvent(receipt, "KlayswapProposalAdded", {
                proposalId: klayswapProposalId,
                startBlock: startBlock,
                endBlock: startBlock.add(VOTING_PERIOD)
            })

            let proposal = await klayswapGovern.proposals(klayswapProposalId);
            console.log("Proposal Start Block : ", proposal[1].toString());
            console.log("Proposal End Block : ", proposal[2].toString());
            console.log("Proposal state : ", (await klayswapGovern.state(klayswapProposalId)).toString())


            // 1. User Vote for the newly active proposal
            await klayswapGovern.castVote(klayswapProposalId, true, { from: userA })
            await klayswapGovern.castVote(klayswapProposalId, false, { from: userB })

            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(100));
            expectEqual(proposal[4], new BN(200));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            // 2. Check Revert (Only Owner)
            await expectRevert(klayswapGovern.cancel(klayswapProposalId, { from: userA }), 'Ownable: caller is not the owner')

            // 3. Cancel the proposal 
            receipt = await klayswapGovern.cancel(klayswapProposalId, { from: root })

            expectEvent(receipt, "ProposalCanceled", { id: klayswapProposalId })

            // 4. CHeck REvert (Try to re-cancel the canceled proposal)
            await expectRevert(klayswapGovern.cancel(klayswapProposalId, { from: root }), "Cannot cancel canceled proposal")

            // 5. Check the variable
            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(100));
            expectEqual(proposal[4], new BN(200));
            expectEqual(proposal[5], true);
            expectEqual(proposal[6], false);

            // 6. Check the state. 
            expectEqual(await klayswapGovern.state(klayswapProposalId), new BN(2))

            // 7. Forward the proposal and check the revert and state. 

            // Add Proposal with start block. 
            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            startBlock = (new BN(currentBlockNum)).add(new BN(0))
            klayswapProposalId = new BN(12)
            receipt = await klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)
            expectEqual(await klayswapGovern.proposalCount(), new BN(3))

            // User Vote for the newly active proposal
            await klayswapGovern.castVote(klayswapProposalId, true, { from: userA })
            await klayswapGovern.castVote(klayswapProposalId, false, { from: userB })
            await klayswapGovern.castVote(klayswapProposalId, false, { from: userC })

            // Mine
            for (let i = 0; i < VOTING_PERIOD; i++) {
                evmMine()
            }

            //Forward 
            receipt = await klayswapGovern.forwardVoteResultToKlayswap(klayswapProposalId)
            await expectEvent.inTransaction(receipt.tx, KlayswapEscrowGovernTest, "CastVote", {
                proposalId: klayswapProposalId,
                support: false
            })

            // Check Variable
            expectEqual(await klayswapGovern.state(klayswapProposalId), new BN(4))
            expectEqual((await klayswapGovern.proposals(klayswapProposalId))[6], true)

            // Check revert (Shouldn't be fowarded)
            await expectRevert(klayswapGovern.cancel(klayswapProposalId, { from: root }), "Cannot cancel forwarded proposal")

            // 8. Expire the proposal and check the revert and state.
            // Add Proposal with start block. 
            const newGapAndVotingTime = 5
            await klayswapGovern.setGapTime(new BN(newGapAndVotingTime), { from: root })
            await klayswapGovern.setVotingPeriod(new BN(newGapAndVotingTime), { from: root })

            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            startBlock = (new BN(currentBlockNum)).add(new BN(0))
            klayswapProposalId = new BN(13)
            receipt = await klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)
            expectEqual(await klayswapGovern.proposalCount(), new BN(4))


            // Mine
            for (let i = 0; i < newGapAndVotingTime * 2 + 1; i++) {
                evmMine()
            }

            expectEqual(await klayswapGovern.state(klayswapProposalId), new BN(5)) // expired
            await expectRevert(klayswapGovern.cancel(klayswapProposalId, { from: root }), "Cannot cancel expired proposal")


        });

        it('Test : 6. Add Proposals & User unstake xSIG which cause vxSIG initialization.', async () => {

            // 0. reset new gap and voting time.
            const newGapAndVotingTime = 10
            await klayswapGovern.setGapTime(new BN(newGapAndVotingTime), { from: root })
            await klayswapGovern.setVotingPeriod(new BN(newGapAndVotingTime), { from: root })


            //1. Add Proposal with start block. 
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log('current block number ', currentBlockNum);
            let startBlock = (new BN(currentBlockNum)).add(new BN(0))
            let klayswapProposalId = new BN(14)
            let receipt = await klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)

            expectEqual(await klayswapGovern.proposalCount(), new BN(5))

            let proposal = await klayswapGovern.proposals(klayswapProposalId);
            console.log("Proposal Start Block : ", proposal[1].toString());
            console.log("Proposal End Block : ", proposal[2].toString());
            console.log("Proposal state : ", (await klayswapGovern.state(klayswapProposalId)).toString())


            // 1. User Vote for the newly active proposal
            await klayswapGovern.castVote(klayswapProposalId, true, { from: userA })
            await klayswapGovern.castVote(klayswapProposalId, false, { from: userB })

            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(100));
            expectEqual(proposal[4], new BN(200));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            // 2. Check User A Vote Receipt

            let voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userA)
            let beforeUserVoteList = await klayswapGovern.getUserVoteList(userA)
            console.log('beforeUserVoteList : ', beforeUserVoteList.length)
            expectEqual(voteReceipt[0], true)
            expectEqual(voteReceipt[1], true)
            expectEqual(voteReceipt[2], new BN(100))
            expectEqual(voteReceipt[3], false)

            // 3. Check Revert 
            await expectRevert(klayswapGovern.cancelUserVotes(userA), "This contract should be called from xSIG Farm.")

            // 4. Unstake vxSIG 
            await xSIGFarmGovern.unstake({ from: userA })

            let afterUserVoteList = await klayswapGovern.getUserVoteList(userA)
            console.log('afterUserVoteList : ', afterUserVoteList.length)
            expectEqual(afterUserVoteList.length, 0)

            voteReceipt = await klayswapGovern.getReceipt(klayswapProposalId, userA)
            expectEqual(voteReceipt[0], true)
            expectEqual(voteReceipt[1], true)
            expectEqual(voteReceipt[2], new BN(100))
            expectEqual(voteReceipt[3], true)

            // 5. Check proposal values
            proposal = await klayswapGovern.proposals(klayswapProposalId);
            expectEqual(proposal[0], klayswapProposalId);
            expectEqual(proposal[3], new BN(0)); // changed.
            expectEqual(proposal[4], new BN(200));
            expectEqual(proposal[5], false);
            expectEqual(proposal[6], false);

            // 6. Try to revote to the canceled one
            await expectRevert(klayswapGovern.castVote(klayswapProposalId, true, { from: userA }), "Voter already voted")

        });
    })

});

// async function getAllPoolVote() {
//     for (let i = 1; i < 17; i++) {
//         let poolInfo = await sigmaVoter.poolInfos(await sigmaVoter.poolAddresses(i))
//         console.log('pool info : listpointer', poolInfo[2].toString(), ' vxSIGAmount : ', poolInfo[0].toString())
//     }
// }

function evmMine() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_mine",
            id: new Date().getTime()
        }, (error, result) => {
            if (error) {
                return reject(error);
            }
            return resolve(result);
        });
    });
};

