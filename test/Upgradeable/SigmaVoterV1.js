const {
    makeVxSIGToken,
    makeSigmaVoterV1,
    makeSigmaVoterV2_Test,
    UUPSProxy,
    makeErc20Token,
    vxSIGToken,
    SigmaVoterV1,
    SigmaVoterV2_Test,
    MockERC20,
    makeUUPSProxy
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
 * 1. Add pool / Set pool (Admin)
 * 2. addAllPoolVote (User)
 * 3. deletePoolVote (User)
 * 4. deleteAllPoolVote(User)
 *
 * <View Function>
 * 1. getCurrentTopVotes
 * 2. getCurrentVotes 
 * 3. getPoolCount
 * 4. availableVotes
 * 5. getUserVotesCount
 * 
 * <Boost Reward>
 * 1. update boost weight
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.


contract('SigmaVoter', function (accounts) {
    let root = accounts[0];
    let userA = accounts[1];
    let userB = accounts[2];
    let userC = accounts[3];
    let userD = accounts[4];


    let vxSIGToken;

    let sigmaVoterImpl;
    let sigmaVoterProxy;
    let sigmaVoter;

    let lpPools = new Array(16);

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {

            // [Test Scenario]
            // 1. Total Votable LP Pool : 15(at setInitialInfo) + 1(at add pool)
            // 2. 3 hand picked pool is going to be TOP_YEILD_POOL


            //Deploy from the start.
            vxSIGToken = await makeVxSIGToken();

            sigmaVoterImpl = await makeSigmaVoterV1();
            sigmaVoterProxy = await makeUUPSProxy(sigmaVoterImpl.address, "0x")
            sigmaVoter = await SigmaVoterV1.at(sigmaVoterProxy.address);

            await sigmaVoter.initialize()

            for (let i = 0; i < 15; i++) {
                lpPools[i] = (await makeErc20Token()).address;
            }


            // [Caution] Set vxSIGToken operator to root. 
            //  It is only operated by xSIGFarm in production.
            await vxSIGToken.setOperator([root])


        });

        it('Test : 0.SetInitialInfo', async () => {

            let topYieldPools = new Array(lpPools[12], lpPools[13], lpPools[14])
            // 1. Check onlyOwner Function 
            await expectRevert(sigmaVoter.setInitialInfo(lpPools, topYieldPools, vxSIGToken.address, new BN(10), { from: userA }), 'Ownable: caller is not the owner')

            // 2. Check Reverts
            await expectRevert(sigmaVoter.setInitialInfo(lpPools, new Array(lpPools[12]), vxSIGToken.address, new BN(10), { from: root }), 'Top yield pool length doesn\'t match with TOP_YIELD_POOL_COUNT')
            await expectRevert(sigmaVoter.setInitialInfo(lpPools, new Array(lpPools[11], lpPools[12], lpPools[13], lpPools[14]), vxSIGToken.address, new BN(10), { from: root }), 'Top yield pool length doesn\'t match with TOP_YIELD_POOL_COUNT')


            // 2. Check if Initial Info has been set. 
            await sigmaVoter.setInitialInfo(lpPools, topYieldPools, vxSIGToken.address, new BN(10), { from: root })

            expectEqual(await sigmaVoter.getPoolCount(), new BN(15));
            expectEqual(await sigmaVoter.isPool(lpPools[0]), true)
            expectEqual(await sigmaVoter.isPool(((await makeErc20Token()).address)), false)

            // CONSTANT CHECK 
            expectEqual(await sigmaVoter.MAX_VOTES_WITH_BUFFER(), new BN(13))
            expectEqual(await sigmaVoter.USER_MAX_VOTE_POOL(), new BN(10))
            expectEqual(await sigmaVoter.totalUsedVxSIG(), new BN(0))
        });

        it('Test : 1.Add Pool', async () => {
            // 1. Check Reverts
            await expectRevert(sigmaVoter.addPool(((await makeErc20Token()).address), { from: userA }), 'Ownable: caller is not the owner');
            await expectRevert(sigmaVoter.addPool(lpPools[1], { from: root }), 'This pool already has been added.');


            // 2. Add pool 
            let newPool = (await makeErc20Token()).address;
            let receipt = await sigmaVoter.addPool(newPool, { from: root })

            lpPools[15] = newPool

            expectEvent(receipt, 'PoolAdded', {
                poolAddress: newPool,
                totalPoolLength: new BN(16)
            })

            expectEqual((await sigmaVoter.poolInfos(newPool))[2], new BN(16)) // newly added pool's list pointer going to be 16. It's not 15 cause poolAddresses[0] is 0x0. 
            expectEqual(await sigmaVoter.poolAddresses(16), newPool);

        })

        it('Test : 2. addAllPoolVote', async () => {

            // [Vote scenario]

            // +-------+----------------------------------+----------------------------------+---------------------------------+
            // | Round |              UserA               |              UserB               |              UserC              |
            // +-------+----------------------------------+----------------------------------+---------------------------------+
            // |     1 | [0],[1],[2],[3],[4],[5] each 100 | [0],[1],[2],[3],[4],[5] each 200 | [0],[1],[2],[3],[4],[5] each 50 |
            // |     2 | [6],[7],[8] each 100             | [9],[10],[11] each 100           | [12],[13],[14] each 500         |
            // |     3 | [15],[0] each 400                | [9],[10] each 1000               | [0] each 2000                   |
            // +-------+----------------------------------+----------------------------------+---------------------------------+

            const intialVxSIGFundAmount = bnMantissa(5000)

            // 1. Fund vxSIG 
            await vxSIGToken.mint(userA, intialVxSIGFundAmount, { from: root })
            await vxSIGToken.mint(userB, intialVxSIGFundAmount, { from: root })
            await vxSIGToken.mint(userC, intialVxSIGFundAmount, { from: root })

            // 2. Check Revert
            // pool length 
            await expectRevert(sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1]), new Array(new BN(10), new BN(2), new BN(10)), { from: userA }), "Pool length doesn't match with vxSIGAmounts length.") // pool length : 2, vote length : 3
            // must vote at least one pool
            await expectRevert(sigmaVoter.addAllPoolVote(new Array(), new Array(), { from: userA }), "Must vote for at least one pool") // pool length : 2, vote length : 3

            // vote vxsig > 0
            await expectRevert(sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1]), new Array(new BN(0), new BN(1)), { from: userA }), "Vote vxSIG should be bigger than 0") // pool length : 2, vote length : 3

            // insufficient vx sig
            await expectRevert(sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1]), new Array(new BN(1), new BN(1)), { from: userD }), "insufficient vxSIG to vote") // pool length : 2, vote length : 3

            // not registered pool 
            await expectRevert(sigmaVoter.addAllPoolVote(new Array((await makeErc20Token()).address), new Array(new BN(1)), { from: userA }), "This pool is not registred by the admin") // pool length : 2, vote length : 3

            // 3. [Round 1] Vote for pools
            console.log("\n*********** ROUND 1 *************\n")

            await sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1], lpPools[2], lpPools[3], lpPools[4], lpPools[5]), new Array(new BN(100), new BN(100), new BN(100), new BN(100), new BN(100), new BN(100)), { from: userA })
            await sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1], lpPools[2], lpPools[3], lpPools[4], lpPools[5]), new Array(new BN(200), new BN(200), new BN(200), new BN(200), new BN(200), new BN(200)), { from: userB })
            await sigmaVoter.addAllPoolVote(new Array(lpPools[0], lpPools[1], lpPools[2], lpPools[3], lpPools[4], lpPools[5]), new Array(new BN(50), new BN(50), new BN(50), new BN(50), new BN(50), new BN(50)), { from: userC })

            // 4. [Round 1] Check results 
            // top votes length
            expectEqual(await sigmaVoter.topVotesLength(), new BN(6))
            // min top vote
            expectEqual(await sigmaVoter.minTopVote(), new BN(350))
            // minTopVoteIndex
            expectEqual(await sigmaVoter.minTopVoteIndex(), new BN(1)) // 만약 첫 번째가 min 이었으면 같은 표가 나와도 첫 번째가 min.
            // get current topVotes
            let result = await sigmaVoter.getCurrentTopVotes()
            const { 0: addresses, 1: weights } = result;
            for (let i = 0; i < addresses.length; i++) {
                console.log('index : ', i, ' address : ', addresses[i], ' ====> vote : ', weights[i].toString())
            }
            // get current Votes
            result = await sigmaVoter.getCurrentVotes()

            const { 0: vxSIGTotalSupply, 1: addresses2, 2: weights2 } = result;

            console.log('vxSIGTotalSupply : ', vxSIGTotalSupply.toString())
            for (let i = 0; i < addresses2.length; i++) {
                console.log('index : ', i, ' address : ', addresses2[i], ' ====> vote : ', weights2[i].toString())
            }

            // 5. Check user current status

            //get user vote count. it should be 6
            expectEqual(await sigmaVoter.getUserVotesCount(userA), new BN(6))
            expectEqual(await sigmaVoter.getUserVotesCount(userB), new BN(6))
            expectEqual(await sigmaVoter.getUserVotesCount(userC), new BN(6))

            //availableVote
            expectEqual(await sigmaVoter.availableVotes(userA), intialVxSIGFundAmount.div(bnMantissa(1)).sub(new BN(600)))
            expectEqual(await sigmaVoter.availableVotes(userB), intialVxSIGFundAmount.div(bnMantissa(1)).sub(new BN(1200)))
            expectEqual(await sigmaVoter.availableVotes(userC), intialVxSIGFundAmount.div(bnMantissa(1)).sub(new BN(300)))

            //User Total Voted vxSIG 
            expectEqual(await sigmaVoter.userTotalUsedVxSIG(userA), new BN(600))
            expectEqual(await sigmaVoter.userTotalUsedVxSIG(userB), new BN(1200))
            expectEqual(await sigmaVoter.userTotalUsedVxSIG(userC), new BN(300))


            // 6. Vote more for pools  
            console.log("\n*********** ROUND 2 *************\n")

            // [Round 2] Vote for pools
            await sigmaVoter.addAllPoolVote(new Array(lpPools[6], lpPools[7], lpPools[8]), new Array(new BN(100), new BN(100), new BN(100)), { from: userA })
            console.log('here 1 : ', (await sigmaVoter.minTopVoteIndex()).toString())
            await sigmaVoter.addAllPoolVote(new Array(lpPools[9], lpPools[10], lpPools[11]), new Array(new BN(100), new BN(100), new BN(100)), { from: userB })
            console.log('here 2 : ', (await sigmaVoter.minTopVoteIndex()).toString())

            await sigmaVoter.addAllPoolVote(new Array(lpPools[12], lpPools[13], lpPools[14]), new Array(new BN(500), new BN(500), new BN(500)), { from: userC })

            // [Round 2] Check results 
            // top votes length
            expectEqual(await sigmaVoter.topVotesLength(), new BN(12))
            // min top vote
            expectEqual(await sigmaVoter.minTopVote(), new BN(100))
            // minTopVoteIndex
            expectEqual(await sigmaVoter.minTopVoteIndex(), new BN(10)) // C가 투표하고 나면 바뀜.
            // get current topVotes
            result = await sigmaVoter.getCurrentTopVotes()
            const { 0: addresses3, 1: weights3 } = result;
            for (let i = 0; i < addresses3.length; i++) {
                console.log('index : ', i, ' address : ', addresses3[i], ' ====> vote : ', weights3[i].toString())
            }
            // get current Votes
            result = await sigmaVoter.getCurrentVotes()

            const { 0: vxSIGTotalSupply2, 1: addresses4, 2: weights4 } = result;

            console.log('vxSIGTotalSupply : ', vxSIGTotalSupply2.toString())
            for (let i = 0; i < addresses4.length; i++) {
                console.log('index : ', i, ' address : ', addresses4[i], ' ====> vote : ', weights4[i].toString())
            }


            // [Round 3] Vote for pools
            console.log("\n*********** ROUND 3 *************\n")
            await sigmaVoter.addAllPoolVote(new Array(lpPools[15], lpPools[0]), new Array(new BN(400), new BN(400)), { from: userA })
            await sigmaVoter.addAllPoolVote(new Array(lpPools[9], lpPools[10]), new Array(new BN(1000), new BN(1000)), { from: userB })
            await sigmaVoter.addAllPoolVote(new Array(lpPools[0]), new Array(new BN(2000)), { from: userC })

            // // [Round 3] Check results 
            // // top votes length
            expectEqual(await sigmaVoter.topVotesLength(), new BN(12))

            // get current topVotes
            result = await sigmaVoter.getCurrentTopVotes()
            const { 0: addresses5, 1: weights5 } = result;
            for (let i = 0; i < addresses5.length; i++) {
                console.log('index : ', i, ' address : ', addresses5[i], ' ====> vote : ', weights5[i].toString())
            }
            // get current Votes
            result = await sigmaVoter.getCurrentVotes()

            const { 0: vxSIGTotalSupply3, 1: addresses6, 2: weights6 } = result;

            console.log('vxSIGTotalSupply : ', vxSIGTotalSupply3.toString())
            for (let i = 0; i < addresses6.length; i++) {
                console.log('index : ', i, ' address : ', addresses6[i], ' ====> vote : ', weights6[i].toString())
            }

        })

        it('Test : 3. deletePoolVote (User)', async () => {

            // [DeletePoolVote scenario]

            // 1. Current Vote for each pool
            // +=======+======+=====+=====+=====+======+=====+======+=====+=====+======+======+======+======+======+======+======+
            // | pools | [0]  | [1] | [2] | [3] | [4]  | [5] | [6]  | [7] | [8] | [9]  | [10] | [11] | [12] | [13] | [14] | [15] |
            // +=======+======+=====+=====+=====+======+=====+======+=====+=====+======+======+======+======+======+======+======+
            // |     - | 2750 | 350 | 350 | 350 |  350 | 350 |  100 | 100 | 100 | 1100 | 1100 |  100 |  500 |  500 |  500 |  400 |
            // +-------+------+-----+-----+-----+------+-----+------+-----+-----+------+------+------+------+------+------+------+
            //
            // 2. currentMinTopVote :  350  currentTopVoteLength :  12  currentMinTopVoteIndex :  2

            // 3. Delete Pool Vote
            // 3-1) lpPools[15] userA 10 withdraw (remain 390. still top vote) 
            // 3-2) lpPools[10] userB 1100 withdraw (withdraw all)
            // 3-3) lpPools[12] userC 400 withdraw (remain 100. still top vote)
            // 3-4) lpPools[13] userC 500 withdraw (remain 0, not top vote anymore)



            // 1. Check reverts. 
            //invalid pool
            await expectRevert(sigmaVoter.deletePoolVote((await makeErc20Token()).address, new BN(10), { from: userA }), 'This pool is not registred by the admin.')

            // never voted
            await expectRevert(sigmaVoter.deletePoolVote(lpPools[10], new BN(10), { from: userA }), 'User never voted to this pool.')
            await expectRevert(sigmaVoter.deletePoolVote(lpPools[0], new BN(501), { from: userA }), "User didn't vote _vxSIGAmount in this pool") // user only voted 500


            // 2. Delete pool vote
            // 2-1) lpPools[15] userA 10 withdraw (remain 390. still top vote) 

            let beforePoolInfo = await sigmaVoter.poolInfos(lpPools[15])
            let beforeUserPoolInfo = await sigmaVoter.userPoolVotes(userA, (await sigmaVoter.userPoolInfos(userA, lpPools[15]))[0])
            let beforeUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userA)
            let receipt = await sigmaVoter.deletePoolVote(lpPools[15], new BN(10), { from: userA })
            expectEvent(receipt, "VoteWithdrawn", {
                user: userA,
                poolAddress: lpPools[15],
                withdrawnAmount: new BN(10),
                newPoolVxSIGAmount: beforePoolInfo[0].sub(new BN(10))
            })

            let afterPoolInfo = await sigmaVoter.poolInfos(lpPools[15])
            let afterUserPoolInfo = await sigmaVoter.userPoolVotes(userA, (await sigmaVoter.userPoolInfos(userA, lpPools[15]))[0])
            let afterUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userA)


            expectEqual(beforePoolInfo[3], afterPoolInfo[3])
            expectEqual(beforeUserPoolInfo[1].sub(new BN(10)), afterUserPoolInfo[1])
            console.log(
                'beforeUserPoolInfo[1].sub(new BN(10)) ', (beforeUserPoolInfo[1].sub(new BN(10))).toString(), '\n afterUserPoolInfo[1]', afterUserPoolInfo[1].toString()
            )
            expectEqual(beforeUserUsedVxSig.sub(new BN(10)), afterUserUsedVxSig)
            console.log('userA before', beforeUserPoolInfo[1].toString(), 'after ', afterUserPoolInfo[1].toString())


            // 2-2) lpPools[10] userB 1100 withdraw (withdraw all)
            beforePoolInfo = await sigmaVoter.poolInfos(lpPools[10])
            beforeUserPoolInfo = await sigmaVoter.userPoolVotes(userB, (await sigmaVoter.userPoolInfos(userB, lpPools[10]))[0])
            beforeUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userB)
            receipt = await sigmaVoter.deletePoolVote(lpPools[10], new BN(1100), { from: userB })
            expectEvent(receipt, "VoteWithdrawn", {
                user: userB,
                poolAddress: lpPools[10],
                withdrawnAmount: new BN(1100),
                newPoolVxSIGAmount: beforePoolInfo[0].sub(new BN(1100))
            })

            afterPoolInfo = await sigmaVoter.poolInfos(lpPools[10])
            afterUserPoolInfo = await sigmaVoter.userPoolVotes(userB, (await sigmaVoter.userPoolInfos(userB, lpPools[10]))[0])
            afterUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userB)


            expectEqual(afterPoolInfo[3], new BN(0))
            expectEqual(beforeUserPoolInfo[1].sub(new BN(1100)), afterUserPoolInfo[1])
            expectEqual(beforeUserUsedVxSig.sub(new BN(1100)), afterUserUsedVxSig)

            console.log('userB before', beforeUserPoolInfo[1].toString(), 'after ', afterUserPoolInfo[1].toString())

            // 2-3) lpPools[12] userC 400 withdraw (remain 100. still top vote)
            beforePoolInfo = await sigmaVoter.poolInfos(lpPools[12])
            beforeUserPoolInfo = await sigmaVoter.userPoolVotes(userC, (await sigmaVoter.userPoolInfos(userC, lpPools[12]))[0])
            beforeUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userC)
            receipt = await sigmaVoter.deletePoolVote(lpPools[12], new BN(400), { from: userC })
            expectEvent(receipt, "VoteWithdrawn", {
                user: userC,
                poolAddress: lpPools[12],
                withdrawnAmount: new BN(400),
                newPoolVxSIGAmount: beforePoolInfo[0].sub(new BN(400))
            })

            afterPoolInfo = await sigmaVoter.poolInfos(lpPools[12])
            afterUserPoolInfo = await sigmaVoter.userPoolVotes(userC, (await sigmaVoter.userPoolInfos(userC, lpPools[12]))[0])
            afterUserUsedVxSig = await sigmaVoter.userTotalUsedVxSIG(userC)


            expectEqual(afterPoolInfo[3], beforePoolInfo[3])
            expectEqual(beforeUserPoolInfo[1].sub(new BN(400)), afterUserPoolInfo[1])
            expectEqual(beforeUserUsedVxSig.sub(new BN(400)), afterUserUsedVxSig)

            console.log('userC before', beforeUserPoolInfo[1].toString(), 'after ', afterUserPoolInfo[1].toString())

            //minTopVote has been changed.
            expectEqual(afterPoolInfo[0], await sigmaVoter.minTopVote())

        })

        it('Test : 4. deleteAllPoolVote (User)', async () => {

            // 1. Check Reverts

            await expectRevert(sigmaVoter.deleteAllPoolVote({ from: userD }), "User didn't vote yet")

            // 2. UserA delte All Vote
            let beforeSigmaVoterTotalUsedVxSIG = await sigmaVoter.totalUsedVxSIG();
            let beforeUserATotalUsedVxSIG = await sigmaVoter.userTotalUsedVxSIG(userA);

            let receipt = await sigmaVoter.deleteAllPoolVote({ from: userA })
            expectEvent(receipt, "AllVoteWithdrawn", {
                user: userA
            })

            let afterSigmaVoterTotalUsedVxSIG = await sigmaVoter.totalUsedVxSIG();
            let afterUserATotalUsedVxSIG = await sigmaVoter.userTotalUsedVxSIG(userA);

            console.log('before :::: sigmaVotalTotalUsedVxSIG ', beforeSigmaVoterTotalUsedVxSIG.toString())
            console.log('after :::: afterSigmaVoterTotalUsedVxSIG ', afterSigmaVoterTotalUsedVxSIG.toString())
            console.log('before :::: beforeUserATotalUsedVxSIG ', beforeUserATotalUsedVxSIG.toString())
            console.log('after :::: afterUserATotalUsedVxSIG ', afterUserATotalUsedVxSIG.toString())

            expectEqual(afterSigmaVoterTotalUsedVxSIG, beforeSigmaVoterTotalUsedVxSIG.sub(beforeUserATotalUsedVxSIG));


            let userPoolVotesCount = await sigmaVoter.getUserVotesCount(userA)
            expectEqual(userPoolVotesCount, new BN(0))


            let userAPoolInfo = (await sigmaVoter.userPoolInfos(userA, lpPools[15]))
            expectEqual(userAPoolInfo[0], new BN(0))
            expectEqual(userAPoolInfo[1], false)


            await sigmaVoter.deleteAllPoolVote({ from: userB })
            await sigmaVoter.deleteAllPoolVote({ from: userC })


            expectEqual(await sigmaVoter.totalUsedVxSIG(), new BN(0))

            let result = await sigmaVoter.getCurrentTopVotes()
            const { 0: addresses, 1: weights } = result;
            for (let i = 0; i < addresses.length; i++) {
                console.log('index : ', i, ' address : ', addresses[i], ' ====> vote : ', weights[i].toString())
            }
            // get current Votes
            result = await sigmaVoter.getCurrentVotes()

            const { 0: vxSIGTotalSupply, 1: addresses2, 2: weights2 } = result;

            console.log('vxSIGTotalSupply : ', vxSIGTotalSupply.toString())
            for (let i = 0; i < addresses2.length; i++) {
                console.log('index : ', i, ' address : ', addresses2[i], ' ====> vote : ', weights2[i].toString())
            }

        })

        it('Test : 5. Upgrade to new contract.', async () => {
            let SigmaVoterImpl2 = await makeSigmaVoterV2_Test()
            await sigmaVoter.upgradeTo(SigmaVoterImpl2.address);
            sigmaVoter = await SigmaVoterV2_Test.at(sigmaVoterProxy.address)

            await expectRevert(sigmaVoter.addAllPoolVote(new Array(lpPools[6], lpPools[7], lpPools[8], lpPools[10]), new Array(new BN(10), new BN(10), new BN(10), new BN(10)), { from: userA }), "Pool length should be smaller than 4.")

            await sigmaVoter.addAllPoolVote(new Array(lpPools[7], lpPools[8], lpPools[10]), new Array(new BN(10), new BN(10), new BN(10)), { from: userA })

        })
    })
});

// async function getAllPoolVote() {
//     for (let i = 1; i < 17; i++) {
//         let poolInfo = await sigmaVoter.poolInfos(await sigmaVoter.poolAddresses(i))
//         console.log('pool info : listpointer', poolInfo[2].toString(), ' vxSIGAmount : ', poolInfo[0].toString())
//     }
// }



