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

            VOTING_PERIOD = new BN(100)
            QUORUM_VOTES = new BN(10)
            GAP_TIME = new BN(100)
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
            expectEqual(await klayswapGovern.votingPeriod(), new BN(100));
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
            console.log(currentBlockNum);
            const startBlock = (new BN(currentBlockNum)).add(new BN(10))
            const klayswapProposalId = new BN(10)
            let receipt = klayswapGovern.addKlayswapProposal(klayswapProposalId, startBlock)

            expectEqual(await klayswapGovern.proposalCount(), new BN(1))


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

            console.log(proposal)






            //2. Check Variables.

            //3. Check Revert. 




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

