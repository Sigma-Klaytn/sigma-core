const {
    makeErc20Token,
    makexSIG,
    xSIG,
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

contract('xSIG', function (accounts) {
    let root = accounts[0];
    let feeDistributor = accounts[1]; // Admin address who gets KUSDT at the end of phase2.
    let userA = accounts[2];
    let userB = accounts[3];
    let userC = accounts[4];

    let SIGToken;
    let xSIG;

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
            xSIG = await makexSIG();

            //Fund KSUDT worth 10000$
            await SIGToken.mint(bnMantissa(10000), { from: feeDistributor });
            await SIGToken.mint(bnMantissa(10000), { from: userA });
            await SIGToken.mint(bnMantissa(10000), { from: userB });
            await SIGToken.mint(bnMantissa(10000), { from: userC });
        });

        it('Test : 0.SetInitialInfo', async () => {
            //1. Check onlyOwner Function 
            await expectRevert(xSIG.setInitialInfo(SIGToken.address, HOUR, { from: userA }), 'Ownable: caller is not the owner')

            //2. Check if Initial Info has been set. 
            await xSIG.setInitialInfo(SIGToken.address, HOUR)
            expectEqual(await xSIG.lockingPeriod(), HOUR);
            expectEqual(await xSIG.SIG(), SIGToken.address);
        });

        it('Test : 1-1. Stake', async () => {
            //1. Check Reverts. 
            // 1-1. If the user hasn't approved yet.
            await expectRevert.unspecified(xSIG.stake(bnMantissa(1), { from: userA }));
            // 1-2.If the amount is 0
            await expectRevert(xSIG.stake(0, { from: userA }), 'Stake SIG amount should be bigger than 0');

            //2. Stake 
            // 2-1. a,b,c stake 1:2:4 and now the xSIGExchangeRate should be 1
            let exchangeRate = (await xSIG.getxSIGExchangeRate()).div(new BN(1e7))
            expectEqual(exchangeRate, new BN(1)); // it's 1 since there is no SIG in the contract. 
            await SIGToken.approve(xSIG.address, MAX_INT256, { from: userA });
            await SIGToken.approve(xSIG.address, MAX_INT256, { from: userB });
            await SIGToken.approve(xSIG.address, MAX_INT256, { from: userC });

            let receipt = await xSIG.stake(bnMantissa(10), { from: userA });
            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(10),
                mintedxSIG: bnMantissa(10).div(exchangeRate)
            })

            await xSIG.stake(bnMantissa(20), { from: userB });
            await xSIG.stake(bnMantissa(40), { from: userC });

            exchangeRate = (await xSIG.getxSIGExchangeRate()).div(new BN(1e7))
            expectEqual(exchangeRate, new BN(1)); // // it's still 1 since there is no fee in the contract.

            //3. Check all the variables of the contract. 
            expectEqual(await xSIG.totalSupply(), bnMantissa(10 + 20 + 40))
            expectEqual(await xSIG.balanceOf(userA), bnMantissa(10))
            expectEqual(await xSIG.balanceOf(userB), bnMantissa(20))
            expectEqual(await xSIG.balanceOf(userC), bnMantissa(40))
        });

        it('Test : 1-2. Fees are stacked.', async () => {
            //1. Fees are stacked from Fee distributor. 
            await SIGToken.approve(xSIG.address, MAX_INT256, { from: feeDistributor })
            let receipt = await xSIG.depositFee(bnMantissa(7), { from: feeDistributor })
            expectEvent(receipt, 'FeesReceived', {
                caller: feeDistributor,
                amount: bnMantissa(7)
            })

            //2. Check the xSIGExchangeRate changed to 1.1 
            let totalSIGAmount = await SIGToken.balanceOf(xSIG.address);
            let totalxSIGSupply = await xSIG.totalSupply();
            let estimatedxSIGExchangeRate = parseFloat(totalSIGAmount) / parseFloat(totalxSIGSupply);
            console.log('total SIG Amount : ', totalSIGAmount.toString(), '\ntotal xSIG Supply : ', totalxSIGSupply.toString(), '\nestimatedSIGExchangeRate : ', estimatedxSIGExchangeRate.toString())
            expectEqual(parseFloat(await xSIG.getxSIGExchangeRate() / 1e7), estimatedxSIGExchangeRate);

            //3. Stake Again and check 
            receipt = await xSIG.stake(bnMantissa(11), { from: userA });
            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(11),
                mintedxSIG: bnMantissa(10)
            })

            //4. Accumulate Fee again.
            receipt = await xSIG.depositFee(bnMantissa(30), { from: feeDistributor })
            totalSIGAmount = await SIGToken.balanceOf(xSIG.address);
            totalxSIGSupply = await xSIG.totalSupply();
            estimatedxSIGExchangeRate = parseFloat(totalSIGAmount) / parseFloat(totalxSIGSupply);
            console.log('total SIG Amount : ', totalSIGAmount.toString(), '\ntotal xSIG Supply : ', totalxSIGSupply.toString(), '\nestimatedSIGExchangeRate : ', estimatedxSIGExchangeRate.toString())
            expectEqual(parseFloat(await xSIG.getxSIGExchangeRate() / 1e7), estimatedxSIGExchangeRate);


            //5. Stake Again and check 
            receipt = await xSIG.stake(bnMantissa(11), { from: userB });
            console.log('minted xSIG : ', bnMantissa(11).mul(totalxSIGSupply).div(totalSIGAmount).toString())

            expectEvent(receipt, 'Stake', {
                stakedSIG: bnMantissa(11),
                mintedxSIG: bnMantissa(11).mul(totalxSIGSupply).div(totalSIGAmount) //7457627118644067796
            })
        });

        describe('Test : 2. unstake', () => {

            before(async () => {
                //Deploy from the start.
                SIGToken = await makeErc20Token();
                xSIG = await makexSIG();

                await xSIG.setInitialInfo(SIGToken.address, HOUR)

                await SIGToken.mint(bnMantissa(10000), { from: feeDistributor });
                await SIGToken.mint(bnMantissa(10000), { from: userA });
                await SIGToken.mint(bnMantissa(10000), { from: userB });
                await SIGToken.mint(bnMantissa(10000), { from: userC });

                await SIGToken.approve(xSIG.address, MAX_INT256, { from: userA });
                await SIGToken.approve(xSIG.address, MAX_INT256, { from: userB });
                await SIGToken.approve(xSIG.address, MAX_INT256, { from: userC });

                await xSIG.stake(bnMantissa(10), { from: userA });
                await xSIG.stake(bnMantissa(20), { from: userB });
                await xSIG.stake(bnMantissa(40), { from: userC });

                await SIGToken.approve(xSIG.address, MAX_INT256, { from: feeDistributor })
                await xSIG.depositFee(bnMantissa(7), { from: feeDistributor })

                await xSIG.stake(bnMantissa(11), { from: userA });
                await xSIG.stake(bnMantissa(22), { from: userB });

                // [Situation]
                // Total Staked SIG : 103
                // Total deposited Fee in SIG : 7

                // TOTAL SIG : 110
                // TOTAL xSIG Supply : 100
                // xSIG Exchange Rate : 1.1 (TOTAL SIG / TOTAL xSIG Supply)
                console.log('TOTAL SIG : ', (await SIGToken.balanceOf(xSIG.address)).toString());
                console.log('TOTAL xSIG Supply : ', (await xSIG.totalSupply()).toString())
                console.log('xSIG Exchange Rate : ', parseFloat(await xSIG.getxSIGExchangeRate()) / 1e7);
            });
            it('Test : 2. Unstake', async () => {

                //1. Check reverts. 
                //1-1. unstake amount should be bigger than 0.
                await expectRevert(xSIG.unstake(0, { from: userA }), "Redeem xSIG should be bigger than 0");

                //1-2. user have more xSIG than unstaking amount.
                await expectRevert(xSIG.unstake(bnMantissa(1000000), { from: userA }), "Not enough xSIG amount to unstake.");

                //1-3. try to unstake without approve xSIG
                await expectRevert.unspecified(xSIG.unstake(bnMantissa(1), { from: userA }))

                //3. Unstake
                let userAxSIGAmount = await xSIG.balanceOf(userA);
                let userASIGAmount = await SIGToken.balanceOf(userA);

                console.log(userAxSIGAmount.toString())

                await xSIG.approve(xSIG.address, MAX_INT256, { from: userA });
                console.log((await xSIG.allowance(userA, xSIG.address)).toString())
                let receipt = await xSIG.unstake(bnMantissa(10), { from: userA });


                expectEvent(receipt, 'Unstake', {
                    redeemedxSIG: bnMantissa(10),
                    sigQueued: bnMantissa(10).mul(new BN(11)).div(new BN(10))
                })

                //Change
                console.log((await xSIG.withdrawInfoOf(userA, 0)).toString())
                //User Withdraw Info 가져오고 확인
                //Pending Amount 확인


            });

            it('Test : 3. ClaimUnlockedSIG', async () => {

            });

        })

        describe('Test : 0.SetInitialInfo', () => {

            it('Test : 4. SetLockingPeriod', async () => {

            });

            it('Test : 5. View Functions', async () => {

            });

        })
    });
});