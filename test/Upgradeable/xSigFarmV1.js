const {
    makeSIGFarm,
    makeXSIGToken,
    makeVxSIGToken,
    makexSigFarmV1,
    makexSigFarmV2_Test,
    makeUUPSProxy,
    xSIGToken,
    SIGFarm,
    xSigFarmV1,
    xSigFarmV2_Test,
    vxSIGToken,
    makeSigmaVoter,
    makeSigKSPFarm,
    makeLpFarm
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
const e = require('express');
const { expect } = require('chai');

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Stake (User)
 * 2. Unstake(User)
 * 3. Claim (User)
 * 4. setGenerationRate (Admin)
 * 5. setMaxBoosterPerSIG (Admin)
 * 6. setWhitelist (Admin)
 *
 * <View Function>
 * 1. isUser
 * 2. claimable
 * 3. getStakedXSIG
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.


contract('xSIGFarm', function (accounts) {
    let root = accounts[0];
    let userA = accounts[1];
    let userB = accounts[2];
    let userC = accounts[3];

    let vxSIGToken;
    let xSIGToken;

    let xSIGFarmImpl;
    let xSIGFarmProxy;
    let xSIGFarm;

    let SigmaVoter;
    let SigKSPFarm;
    let LpFarm;

    let initalTokenAirdropAmount = bnMantissa(10000)


    // const initialGenerationRate = new BN(3888888888888);
    // const initialMaxVxSIGPerXSIG = new BN(100000000000000000000);

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {
            //Deploy from the start.
            xSIGToken = await makeXSIGToken();
            vxSIGToken = await makeVxSIGToken();

            xSIGFarmImpl = await makexSigFarmV1();
            xSIGFarmProxy = await makeUUPSProxy(xSIGFarmImpl.address, "0x")
            xSIGFarm = await xSigFarmV1.at(xSIGFarmProxy.address);
            await xSIGFarm.initialize()

            SigmaVoter = await makeSigmaVoter()
            SigKSPFarm = await makeSigKSPFarm()
            LpFarm = await makeLpFarm()

            // [Caution] Set xSIGToken operator to root. 
            //  It is only operated by SIGFarm in production.
            await xSIGToken.setOperator([root])
            await vxSIGToken.setOperator([xSIGFarm.address])

            //Fund xSIGToken worth 10000$
            await xSIGToken.mint(userA, initalTokenAirdropAmount, { from: root });
            await xSIGToken.mint(userB, initalTokenAirdropAmount, { from: root });
            await xSIGToken.mint(userC, initalTokenAirdropAmount, { from: root });
        });

        it('Test : 0.SetInitialInfo', async () => {
            // 1. Check onlyOwner Function 
            await expectRevert(xSIGFarm.setInitialInfo(xSIGToken.address, vxSIGToken.address, SigmaVoter.address, SigKSPFarm.address, LpFarm.address, { from: userA }), 'Ownable: caller is not the owner')

            // //2. Check if Initial Info has been set. 
            await xSIGFarm.setInitialInfo(xSIGToken.address, vxSIGToken.address, SigmaVoter.address, SigKSPFarm.address, LpFarm.address, { from: root })
            expectEqual(await xSIGFarm.generationRate(), new BN(3888888888888));
            expectEqual(await xSIGFarm.maxVxSIGPerXSIG(), new BN('100000000000000000000'));
            expectEqual(await xSIGFarm.xSIG(), xSIGToken.address);
            expectEqual(await xSIGFarm.vxSIG(), vxSIGToken.address);
        });


        it('Test : 1.Stake', async () => {
            // 1. Check Reverts 
            // 1-1. User didn't approve xSIG Token to this contract before staking.
            await expectRevert(xSIGFarm.stake(bnMantissa(100), { from: userA }), "Insufficient allowance.")
            // 1-2. Amount is 0
            await xSIGToken.approve(xSIGFarm.address, MAX_INT256, { from: userA })
            await expectRevert(xSIGFarm.stake(0, { from: userA }), "stake xSIG amount should be bigger than 0")

            // 2. users stakes xSIG. A : 100 xSIG , B : 500 xSIG
            const userADepositAmount = bnMantissa(100)
            const userBDepositAmount = bnMantissa(500)

            //userA already approved above
            await xSIGToken.approve(xSIGFarm.address, MAX_INT256, { from: userB })

            let receipt = await xSIGFarm.stake(userADepositAmount, { from: userA })
            expectEvent(receipt, "Staked", {
                user: userA,
                amount: userADepositAmount,
                totalStakedAmount: userADepositAmount
            })
            expectEqual(await xSIGToken.balanceOf(userA), initalTokenAirdropAmount.sub(userADepositAmount))
            receipt = await xSIGFarm.stake(userBDepositAmount, { from: userB })
            expectEvent(receipt, "Staked", {
                user: userB,
                amount: userBDepositAmount,
                totalStakedAmount: userBDepositAmount
            })

            // 3. stake again and check for the _claim has been executed.

            // after an hour
            await time.increase(time.duration.hours(1));

            // 3-1. re-stake 
            const userAAddedDepositAmount = bnMantissa(100) //total 200 xSIG
            const beforeUserAInfoOf = await xSIGFarm.userInfoOf(userA)

            receipt = await xSIGFarm.stake(userAAddedDepositAmount, { from: userA })

            expectEvent(receipt, "Staked", {
                user: userA,
                amount: userAAddedDepositAmount,
                totalStakedAmount: userADepositAmount.add(userAAddedDepositAmount)
            })

            expectEvent(receipt, "Claimed", {
                user: userA
            })
            console.log('Here!! Claimed!! ', (await vxSIGToken.balanceOf(userA)).toString())


            const afterUserAInfoOf = await xSIGFarm.userInfoOf(userA)

            // 3-2. user vxSIG Amount

            const beforeLastRelease = beforeUserAInfoOf[1];
            console.log(beforeLastRelease.toString())
            const afterLastRelease = afterUserAInfoOf[1];
            console.log(afterLastRelease.toString())

            const generationRate = await xSIGFarm.generationRate();
            const userCurrentVxSIGBalance = await vxSIGToken.balanceOf(userA);
            const userTotalStakedXSIGAmount = await xSIGFarm.getStakedXSIG(userA);

            const secondsElapsed = afterLastRelease.sub(beforeLastRelease)
            //DSMath.wmul  
            const pendingVxSIG = userADepositAmount.mul(secondsElapsed).mul(generationRate).div(new BN('1000000000000000000'));
            console.log('pending VxSIG : ', pendingVxSIG.toString())

            console.log("pendingVxSIG : ", pendingVxSIG.toString())
            console.log("userCurrentVxSIGBalance : ", userCurrentVxSIGBalance.toString())
            expectAlmostEqualMantissa(pendingVxSIG, userCurrentVxSIGBalance)

        })

        it('Test : 2.Unstake', async () => {
            // 1. Check reverts. 
            // 1-1. amount > 0
            await expectRevert(xSIGFarm.unstake(0, { from: userA }), "Unstake amount should be bigger than 0")
            // 1-2. stakedXSIG > amount
            await expectRevert(xSIGFarm.unstake(bnMantissa(1000), { from: userA }), "Insuffcient xSIG to unstake")

            // 1-3. No xSIG to withdraw
            await expectRevert(xSIGFarm.unstake(bnMantissa(1000), { from: userC }), "Insuffcient xSIG to unstake")

            // 2. Check vxSIG, xSIG balance of users, total supply of vxSIG
            // 2-1. UserA unstake xSIG partially.
            let beforeUserAVxSIGBalance = await vxSIGToken.balanceOf(userA)
            let userAStakedXSIG = await xSIGFarm.getStakedXSIG(userA)
            let beforeUserAXSIGAmount = await xSIGToken.balanceOf(userA)
            let unstakeAmount = bnMantissa(1);
            let beforeVxSIGTotalSupply = await vxSIGToken.totalSupply()

            let receipt = await xSIGFarm.unstake(unstakeAmount, { from: userA })
            expectEvent(receipt, "Unstaked", {
                user: userA,
                amount: unstakeAmount,
                totalStakedAmount: userAStakedXSIG.sub(unstakeAmount)
            })

            let afterUserAVxSIGBalance = await vxSIGToken.balanceOf(userA)
            let afteruserAStakedXSIG = await xSIGFarm.getStakedXSIG(userA)
            let afterUserAXSIGAmount = await xSIGToken.balanceOf(userA)
            let afterVxSIGTotalSupply = await vxSIGToken.totalSupply()

            // check userVxSIG Balance
            expectEqual(new BN(0), afterUserAVxSIGBalance)
            // check VxSIG Total Supply
            expectEqual(afterVxSIGTotalSupply, beforeVxSIGTotalSupply.sub(beforeUserAVxSIGBalance))
            // check user xSIG Balance
            expectEqual(afterUserAXSIGAmount, beforeUserAXSIGAmount.add(unstakeAmount))
            // check staked xSIG Balance  
            expectEqual(afteruserAStakedXSIG, userAStakedXSIG.sub(unstakeAmount))
            // check userA UserInfo
            let userInfo = await xSIGFarm.userInfoOf(userA)
            expectEqual(userInfo[0], afteruserAStakedXSIG)
            expect(userInfo[1] != bnMantissa(0) && userInfo[2] != bnMantissa(0)).to.be.ok;
            expectEqual(userInfo[1], userInfo[2]) //if unstaked partially, start Time = lastRelease with current time. 

            console.log("last Release : ", userInfo[1].toString())
            console.log("start Time : ", userInfo[2].toString())


            // 2-2. UserB unstake all of its xSIG.
            let beforeUserBVxSIGBalance = await vxSIGToken.balanceOf(userB)
            let userBStakedXSIG = await xSIGFarm.getStakedXSIG(userB)
            let beforeUserBXSIGAmount = await xSIGToken.balanceOf(userB)
            let unstakeUserBAmount = userBStakedXSIG;
            beforeVxSIGTotalSupply = await vxSIGToken.totalSupply()

            receipt = await xSIGFarm.unstake(unstakeUserBAmount, { from: userB })
            expectEvent(receipt, "Unstaked", {
                user: userB,
                amount: unstakeUserBAmount,
                totalStakedAmount: userBStakedXSIG.sub(unstakeUserBAmount) // which is 0
            })

            let afterUserBVxSIGBalance = await vxSIGToken.balanceOf(userB)
            let afteruserBStakedXSIG = await xSIGFarm.getStakedXSIG(userB)
            let afterUserBXSIGAmount = await xSIGToken.balanceOf(userB)
            afterVxSIGTotalSupply = await vxSIGToken.totalSupply()

            // check userVxSIG Balance
            expectEqual(new BN(0), afterUserBVxSIGBalance)
            // check VxSIG Total Supply
            expectEqual(afterVxSIGTotalSupply, beforeVxSIGTotalSupply.sub(beforeUserBVxSIGBalance))
            // check user xSIG Balance
            expectEqual(afterUserBXSIGAmount, beforeUserBXSIGAmount.add(unstakeUserBAmount))
            // check staked xSIG Balance  
            expectEqual(afteruserBStakedXSIG, new BN(0))
            // check userA UserInfo
            userInfo = await xSIGFarm.userInfoOf(userB)
            expectEqual(userInfo[0], afteruserBStakedXSIG)
            expect(userInfo[1] == 0 && userInfo[2] == 0).to.be.ok;
            expectEqual(userInfo[1], userInfo[2]) //if unstaked partially, start Time = lastRelease with 0. 
            console.log("last Release : ", userInfo[1].toString())
            console.log("start Time : ", userInfo[2].toString())
        })

        it('Test : 3.Claim', async () => {
            // 1. Check reverts
            // 1-1. no xSIG to withdraw
            await expectRevert(xSIGFarm.claim({ from: userB }), "User didn't stake any xSIG.")

            // 2. Check Claimable
            await time.increase(time.duration.seconds(1));
            let claimable = await xSIGFarm.claimable(userA)
            console.log((await xSIGFarm.getStakedXSIG(userA)).toString())
            console.log((await xSIGFarm.generationRate()).toString())

            console.log("user a claimable amount of vxSIG : ", claimable.toString())

            // 3. UserA Claim vxSIG 
            expectEqual(await vxSIGToken.balanceOf(userA), new BN(0)) //0 : cause partially unstaked at Test : 2.Unstake.
            let receipt = await xSIGFarm.claim({ from: userA })
            console.log((await vxSIGToken.balanceOf(userA)).toString())
            expectEvent(receipt, "Claimed", {
                user: userA,
                // amount: claimable
            })

            // 4. Max the amount of vxSIG user can get
            await time.increase(time.duration.years(1));
            claimable = await xSIGFarm.claimable(userA);
            let stakedXSIG = await xSIGFarm.getStakedXSIG(userA);
            let maxVxSIGPerXSIG = await xSIGFarm.maxVxSIGPerXSIG()
            let userVxSIGAmount = await vxSIGToken.balanceOf(userA)
            expectEqual(claimable, stakedXSIG.mul(maxVxSIGPerXSIG).div(bnMantissa(1)).sub(userVxSIGAmount));

            await xSIGFarm.claim({ from: userA })
            userVxSIGAmount = await vxSIGToken.balanceOf(userA)
            expectEqual(userVxSIGAmount, stakedXSIG.mul(maxVxSIGPerXSIG).div(bnMantissa(1)))

        })

        it('Test : 4. Set Generation Rate', async () => {

            const newGenerationRate = new BN('123456789')
            // 1. Check Reverts
            // 1-1. only owner
            await expectRevert(xSIGFarm.setGenerationRate(newGenerationRate, { from: userA }), 'Ownable: caller is not the owner')
            // 2-2. should'nt zero
            await expectRevert(xSIGFarm.setGenerationRate(new BN(0), { from: root }), 'generation rate cannot be zero')

            // 2-3. should be different with old one.
            await expectRevert(xSIGFarm.setGenerationRate(new BN(3888888888888), { from: root }), 'new generation is same with old one')

            // 2. setGeneration Rate
            await xSIGFarm.setGenerationRate(newGenerationRate, { from: root })
            expectEqual(await xSIGFarm.generationRate(), newGenerationRate)

        })

        it('Test : 5. Set setMaxBoosterPerSIG', async () => {
            const newMaxBoosterPerSIG = new BN('200000000000000000000')
            // 1. Check Reverts
            // 1-1. only owner
            await expectRevert(xSIGFarm.setMaxVxSIGPerXSIG(newMaxBoosterPerSIG, { from: userA }), 'Ownable: caller is not the owner')
            // 2-2. should'nt zero
            await expectRevert(xSIGFarm.setMaxVxSIGPerXSIG(new BN(0), { from: root }), '_maxVxSIGPerXSIG cannot be zero')

            // 2-3. should be different with old one.
            await expectRevert(xSIGFarm.setMaxVxSIGPerXSIG(new BN('100000000000000000000'), { from: root }), 'new maxVxSIGPerXSIG is same with old on')

            // 2. setGeneration Rate
            await xSIGFarm.setMaxVxSIGPerXSIG(newMaxBoosterPerSIG, { from: root })
            expectEqual(await xSIGFarm.maxVxSIGPerXSIG(), newMaxBoosterPerSIG)
        })

        it('Test : 6. Upgrade Test', async () => {

            let xSigFarmV2_TestImpl = await makexSigFarmV2_Test();
            await xSIGFarm.upgradeTo(xSigFarmV2_TestImpl.address)
            xSIGFarm = await xSigFarmV2_Test.at(xSIGFarmProxy.address);

            await expectRevert(xSIGFarm.stake(new BN(10000), { from: userA }), "stake xSIG amount should be bigger than 1 ether")

            await xSIGFarm.stake(bnMantissa(1), { from: userA })

        })

    })
});


