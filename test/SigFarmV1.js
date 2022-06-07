const {
    makeErc20Token,
    makeSigFarmV1,
    makeSigFarmV2_Test,
    makeXSIGToken,
    makeUUPSProxy,
    xSIGToken,
    SigFarmV1,
    SigFarmV2_Test,
    MockERC20
} = require('./Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual,
    time
} = require('./Utils/JS');
const { MAX_INT256 } = require('@openzeppelin/test-helpers/src/constants');

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Stake (User)
 * 2. Unstake(User)
 * 3. claimUnlockedSIG (User)
 * 4. SetLockingPeriod (Admin)
 *
 * <View Function>
 * 1. getxSIGExchangeRate
 * 2. etRedeemableSIG
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.

contract('SIGFarm', function (accounts) {
    let root = accounts[0];
    let feeDistributor = accounts[1]; // Admin address who gets KUSDT at the end of phase2.
    let userA = accounts[2];
    let userB = accounts[3];
    let userC = accounts[4];

    let SIGToken;
    let xSIGToken;

    let SIGFarmImpl;
    let SIGFarmProxy;
    let SIGFarm;


    const HOUR = 3600;
    const MINUTE = 60;

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            xSIGToken = await makeXSIGToken();

            SIGFarmImpl = await makeSigFarmV1();
            SIGFarmProxy = await makeUUPSProxy(SIGFarmImpl.address, "0x")
            SIGFarm = await SigFarmV1.at(SIGFarmProxy.address);

            await SIGFarm.initialize();

            //Set xSIGToken operator to SIGFarm.
            await xSIGToken.setOperator([SIGFarm.address])

            //Fund SIGToken
            await SIGToken.mint(bnMantissa(10000), { from: feeDistributor });
            await SIGToken.mint(bnMantissa(10000), { from: userA });
            await SIGToken.mint(bnMantissa(10000), { from: userB });
            await SIGToken.mint(bnMantissa(10000), { from: userC });
        });

        it('Test : 0.SetInitialInfo', async () => {
            //1. Check onlyOwner Function 
            await expectRevert(SIGFarm.setInitialInfo(SIGToken.address, HOUR, xSIGToken.address, { from: userA }), 'Ownable: caller is not the owner')

            //2. Check if Initial Info has been set. 
            await SIGFarm.setInitialInfo(SIGToken.address, HOUR, xSIGToken.address, { from: root })
            expectEqual(await SIGFarm.lockingPeriod(), HOUR);
            expectEqual(await SIGFarm.SIG(), SIGToken.address);
        });

        it('Test : 1-1. Stake', async () => {
            //1. Check Reverts. 
            // 1-1. If the user hasn't approved yet.
            await expectRevert.unspecified(SIGFarm.stake(bnMantissa(1), { from: userA }));
            // 1-2.If the amount is 0
            await expectRevert(SIGFarm.stake(0, { from: userA }), 'Stake SIG amount should be bigger than 0');

            //2. Stake 
            // 2-1. a,b,c stake 1:2:4 and now the xSIGExchangeRate should be 1
            let exchangeRate = (await SIGFarm.getxSIGExchangeRate()).div(new BN(1e7))
            expectEqual(exchangeRate, new BN(1)); // it's 1 since there is no SIG in the contract. 
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userA });
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userB });
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userC });

            let receipt = await SIGFarm.stake(bnMantissa(10), { from: userA });
            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(10),
                mintedxSIG: bnMantissa(10).div(exchangeRate)
            })

            await SIGFarm.stake(bnMantissa(20), { from: userB });
            await SIGFarm.stake(bnMantissa(40), { from: userC });

            exchangeRate = (await SIGFarm.getxSIGExchangeRate()).div(new BN(1e7))
            expectEqual(exchangeRate, new BN(1)); // // it's still 1 since there is no fee in the contract.

            //3. Check all the variables of the contract. 
            expectEqual(await xSIGToken.totalSupply(), bnMantissa(10 + 20 + 40))
            expectEqual(await xSIGToken.balanceOf(userA), bnMantissa(10))
            expectEqual(await xSIGToken.balanceOf(userB), bnMantissa(20))
            expectEqual(await xSIGToken.balanceOf(userC), bnMantissa(40))
        });

        it('Test : 1-2. Fees are stacked.', async () => {
            //1. Fees are stacked from Fee distributor. 
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: feeDistributor })
            let receipt = await SIGFarm.depositFee(bnMantissa(7), { from: feeDistributor })
            expectEvent(receipt, 'FeesReceived', {
                caller: feeDistributor,
                amount: bnMantissa(7)
            })

            //2. Check the xSIGExchangeRate changed to 1.1 
            let totalSIGAmount = await SIGToken.balanceOf(SIGFarm.address);
            let totalxSIGSupply = await xSIGToken.totalSupply();
            let estimatedxSIGExchangeRate = parseFloat(totalSIGAmount) / parseFloat(totalxSIGSupply);
            console.log('total SIG Amount : ', totalSIGAmount.toString(), '\ntotal xSIG Supply : ', totalxSIGSupply.toString(), '\nestimatedSIGExchangeRate : ', estimatedxSIGExchangeRate.toString())
            expectEqual(parseFloat(await SIGFarm.getxSIGExchangeRate() / 1e7), estimatedxSIGExchangeRate);

            //3. Stake Again and check 
            receipt = await SIGFarm.stake(bnMantissa(11), { from: userA });
            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(11),
                mintedxSIG: bnMantissa(10)
            })

            //4. Accumulate Fee again.
            receipt = await SIGFarm.depositFee(bnMantissa(30), { from: feeDistributor })
            totalSIGAmount = await SIGToken.balanceOf(SIGFarm.address);
            totalxSIGSupply = await xSIGToken.totalSupply();
            estimatedxSIGExchangeRate = parseFloat(totalSIGAmount) / parseFloat(totalxSIGSupply);
            console.log('total SIG Amount : ', totalSIGAmount.toString(), '\ntotal xSIG Supply : ', totalxSIGSupply.toString(), '\nestimatedSIGExchangeRate : ', estimatedxSIGExchangeRate.toString())
            expectEqual(parseFloat(await SIGFarm.getxSIGExchangeRate() / 1e7), estimatedxSIGExchangeRate);


            //5. Stake Again and check 
            receipt = await SIGFarm.stake(bnMantissa(11), { from: userB });
            console.log('minted xSIG : ', bnMantissa(11).mul(totalxSIGSupply).div(totalSIGAmount).toString())

            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(11),
                mintedxSIG: bnMantissa(11).mul(totalxSIGSupply).div(totalSIGAmount) //7457627118644067796
            })
        });


    });

    describe('Test : 2. unstake', () => {

        before(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            xSIGToken = await makeXSIGToken();

            SIGFarmImpl = await makeSigFarmV1();
            SIGFarmProxy = await makeUUPSProxy(SIGFarmImpl.address, "0x")
            SIGFarm = await SigFarmV1.at(SIGFarmProxy.address);

            await SIGFarm.initialize();

            await xSIGToken.setOperator([SIGFarm.address])

            await SIGFarm.setInitialInfo(SIGToken.address, HOUR, xSIGToken.address)

            await SIGToken.mint(bnMantissa(10000), { from: feeDistributor });
            await SIGToken.mint(bnMantissa(10000), { from: userA });
            await SIGToken.mint(bnMantissa(10000), { from: userB });
            await SIGToken.mint(bnMantissa(10000), { from: userC });

            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userA });
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userB });
            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: userC });

            await SIGFarm.stake(bnMantissa(10), { from: userA });
            await SIGFarm.stake(bnMantissa(20), { from: userB });
            await SIGFarm.stake(bnMantissa(40), { from: userC });

            await SIGToken.approve(SIGFarm.address, MAX_INT256, { from: feeDistributor })
            await SIGFarm.depositFee(bnMantissa(7), { from: feeDistributor })

            await SIGFarm.stake(bnMantissa(11), { from: userA });
            await SIGFarm.stake(bnMantissa(22), { from: userB });

            // [Situation]
            // Total Staked SIG : 103
            // Total deposited Fee in SIG : 7

            // TOTAL SIG : 110
            // TOTAL xSIG Supply : 100
            // xSIG Exchange Rate : 1.1 (TOTAL SIG / TOTAL xSIG Supply)
            console.log('TOTAL SIG : ', (await SIGToken.balanceOf(SIGFarm.address)).toString());
            console.log('TOTAL xSIG Supply : ', (await xSIGToken.totalSupply()).toString())
            console.log('xSIG Exchange Rate : ', parseFloat(await SIGFarm.getxSIGExchangeRate()) / 1e7);
        });
        it('Test : 2. Unstake', async () => {

            //1. Check reverts. 
            //1-1. unstake amount should be bigger than 0.
            await expectRevert(SIGFarm.unstake(0, { from: userA }), "Redeem xSIG should be bigger than 0");

            //1-2. user have more xSIG than unstaking amount.
            await expectRevert(SIGFarm.unstake(bnMantissa(1000000), { from: userA }), "Not enough xSIG amount to unstake.");

            //1-3. try to unstake without approve xSIG
            await expectRevert.unspecified(SIGFarm.unstake(bnMantissa(1), { from: userA }))

            //3. Unstake
            let userAxSIGAmount = await xSIGToken.balanceOf(userA);
            let userASIGAmount = await SIGToken.balanceOf(userA);

            console.log(userAxSIGAmount.toString())

            await xSIGToken.approve(SIGFarm.address, MAX_INT256, { from: userA });
            let unstakingAmount = bnMantissa(10)
            let receipt = await SIGFarm.unstake(unstakingAmount, { from: userA });
            let expectedSIGQueued = unstakingAmount.mul(new BN(11)).div(new BN(10))

            expectEvent(receipt, 'Unstake', {
                redeemedxSIG: unstakingAmount,
                sigQueued: expectedSIGQueued
            })

            let userAWithdrawInfo = await SIGFarm.withdrawInfoOf(userA, 0)
            expectEqual(userAWithdrawInfo[1], unstakingAmount) //xSIGAmount
            expectEqual(userAWithdrawInfo[2], expectedSIGQueued) //SIGAmount
            expectEqual(userAWithdrawInfo[3], false) //isWithdrawn

            //Pending amount of xSIG and SIG
            expectEqual(await SIGFarm.pendingSIG(), expectedSIGQueued);
            expectEqual(await SIGFarm.pendingxSIG(), unstakingAmount);
        });

        it('Test : 3. ClaimUnlockedSIG', async () => {

            // 1. Check Reverts
            //getRedeemableSIG from userA before unlockingPeriod ends
            await expectRevert(SIGFarm.claimUnlockedSIG({ from: userA }), "This address has no withdrawalbe SIG");
            expectEqual(await SIGFarm.getRedeemableSIG({ from: userA }), new BN(0))

            // 1 hour later
            await time.increase(time.duration.seconds(HOUR + 1));

            let userSIGBalance = await SIGToken.balanceOf(userA)
            let userxSIGBalance = await xSIGToken.balanceOf(userA)
            let currentSIGFarmSIGBalance = await SIGToken.balanceOf(SIGFarm.address)
            let currentSIGFarmXSIGBalance = await xSIGToken.balanceOf(SIGFarm.address)
            let pendingSIG = await SIGFarm.pendingSIG();
            let pendingxSIG = await SIGFarm.pendingxSIG();

            console.log('userSIGBalance : ', userSIGBalance.toString())
            console.log('userxSIGBalance : ', userxSIGBalance.toString())
            console.log('currentSIGFarmSIGBalance : ', currentSIGFarmSIGBalance.toString())
            console.log('currentSIGFarmXSIGBalance : ', currentSIGFarmXSIGBalance.toString())
            console.log('pendingSIG : ', pendingSIG.toString())
            console.log('pendingxSIG : ', pendingxSIG.toString())

            // 11 SIG is unlocked and able to be claimed
            let userAWithdrawInfo = await SIGFarm.withdrawInfoOf(userA, 0)
            let userAReedeamableExpect = await SIGFarm.getRedeemableSIG({ from: userA })
            expectEqual(userAReedeamableExpect, userAWithdrawInfo[2])
            let receipt = await SIGFarm.claimUnlockedSIG({ from: userA })

            expectEvent(receipt, "ClaimUnlockedSIG", {
                withdrawnSIG: userAReedeamableExpect,
                burnedxSIG: userAWithdrawInfo[1]
            })

            let after_userSIGBalance = await SIGToken.balanceOf(userA)
            let after_userxSIGBalance = await xSIGToken.balanceOf(userA)
            let after_currentSIGFarmSIGBalance = await SIGToken.balanceOf(SIGFarm.address)
            let after_currentSIGFarmXSIGBalance = await xSIGToken.balanceOf(SIGFarm.address)
            let after_pendingSIG = await SIGFarm.pendingSIG();
            let after_pendingxSIG = await SIGFarm.pendingxSIG();

            console.log('after userSIGBalance : ', after_userSIGBalance.toString())
            console.log('after userxSIGBalance : ', after_userxSIGBalance.toString())
            console.log('after currentSIGFarmSIGBalance : ', after_currentSIGFarmSIGBalance.toString())
            console.log('after currentSIGFarmXSIGBalance : ', after_currentSIGFarmXSIGBalance.toString())
            console.log('after pendingSIG : ', after_pendingSIG.toString())
            console.log('after pendingxSIG : ', after_pendingxSIG.toString())

            expectEqual(after_pendingSIG, pendingSIG - userAReedeamableExpect)
            expectEqual(after_pendingxSIG, pendingxSIG - userAWithdrawInfo[1]) //xSIGAmount

            userAWithdrawInfo = await SIGFarm.withdrawInfoOf(userA, 0)

            expect(userAWithdrawInfo[3]).to.be.ok; // isWithdrawn == true
            expectEqual(await SIGFarm.getRedeemableSIG({ from: userA }), new BN(0))

            // TODO: TEST WITH MULTIPLE PEOPLE
        });


        it('Test : 4. SetLockingPeriod', async () => {
            // 1. Check reverts.
            await expectRevert(SIGFarm.setLockingPeriod(HOUR * 2, { from: userA }), "Ownable: caller is not the owner")

            // 2. Change Locking Period : 1hour -> 30 days
            const thirtyDays = HOUR * 24 * 30
            let receipt = await SIGFarm.setLockingPeriod(thirtyDays, { from: root })
            expectEqual(await SIGFarm.lockingPeriod(), new BN(HOUR * 24 * 30))
        })

        it('Test : 5. Upgrade To New Contract', async () => {

            // Test Contract for testing upgradeability.
            // [Changed feature]
            // 1. Stake SIG amount should be bigger than 1 ether

            let SigFarmV2_TestImpl = await makeSigFarmV2_Test();
            await SIGFarm.upgradeTo(SigFarmV2_TestImpl.address)
            SIGFarm = await SigFarmV2_Test.at(SIGFarmProxy.address);

            await expectRevert(SIGFarm.stake(new BN(10000), { from: userA }), "Stake SIG amount should be bigger than 1 ether")

            await SIGFarm.stake(bnMantissa(1), { from: userA })
        })
    })
});