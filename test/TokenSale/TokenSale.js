const { makeErc20Token, MockERC20, makeTokenSale } = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual,
    time
} = require('../Utils/JS');
const { expect } = require('chai');

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Deposit requirements (User)
 * 2. Withdraw at Phase 1 (User)
 * 3. Withdraw at Phase 2 (User)
 * 4. Release Token (Admin)
 * 5. Withdraw Tokens (User)
 * 6. Withdraw KSUDT to receiver (Admin)
 *
 * <View Function>
 * 1. View public Variables
 * 2. View crucial current Status
 *    1) Total KUSDT
 *    2) Current Token Price
 *    3) Your Contribution
 *    4) Redeemable Amount
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.

contract('TokenSale', function (accounts) {
    let root = accounts[0];
    let receiver = accounts[1]; // Admin address who gets KUSDT at the end of phase2.
    let userA = accounts[2];
    let userB = accounts[3];
    let userC = accounts[4];
    let userD = accounts[5];

    let KUSDTToken;
    let SIGToken;
    let TokenSale;

    const WEEK = 604800;
    const DAY = 60 * 60 * 24;
    const HOUR = 3600;
    const MINUTE = 60;

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo , 1.Deposit requirements', () => {

        beforeEach(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            KUSDTToken = await makeErc20Token();
            TokenSale = await makeTokenSale();

            //Fund KSUDT worth 10000$
            await KUSDTToken.mint(bnMantissa(10000), { from: userA });
            await KUSDTToken.mint(bnMantissa(10000), { from: userB });
            await KUSDTToken.mint(bnMantissa(10000), { from: userC });
            await KUSDTToken.mint(bnMantissa(10000), { from: userD });
        });

        it('Test : 0.SetInitialInfo', async () => {
            //1. Check only Owner function.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;

            expectEqual(await TokenSale.owner(), root);
            await expectRevert(
                TokenSale.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    receiver,
                    { from: userA } // This function always need to be called by the owner (root)
                ),
                'Ownable: caller is not the owner'
            );

            //2. Check Reverts.

            await expectRevert(
                TokenSale.setInitialInfo(
                    currentTime, // current time should be smaller than phase1StartTs
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    receiver,
                    { from: root } // This function always need to be called by the owner (root)
                ),
                'Phase1 should start in the future.'
            );

            await expectRevert(
                TokenSale.setInitialInfo(
                    phase1StartTs,
                    phase1StartTs - MINUTE,
                    phase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    receiver,
                    { from: root } // This function always need to be called by the owner (root)
                ),
                'Phase2 should start after phase1'
            );

            let newPhase2EndTs = phase2StartTs - MINUTE;
            await expectRevert(
                TokenSale.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    newPhase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    receiver,
                    { from: root } // This function always need to be called by the owner (root)
                ),
                'phase2StartTs should smaller than phase2EndTs'
            );

            newPhase2EndTs = phase2StartTs + 59 * MINUTE;

            await expectRevert(
                TokenSale.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    newPhase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    receiver,
                    { from: root } // This function always need to be called by the owner (root)
                ),
                'Phase2 should be longer than 1 hour.'
            );

            await expectRevert(
                TokenSale.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KUSDTToken.address,
                    '0x0000000000000000000000000000000000000000',
                    { from: root } // This function always need to be called by the owner (root)
                ),
                'Invalid receiver address.'
            );

            //3. Check event emits.
            let receipt = await TokenSale.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KUSDTToken.address,
                receiver,
                { from: root }
            );

            expectEvent(receipt, 'InitialInfoSet', {
                phase1StartTs: new BN(phase1StartTs),
                phase2StartTs: new BN(phase2StartTs),
                phase2EndTs: new BN(phase2EndTs),
                receiver: receiver
            });
        });

        it('Test : 1.Deposit requirements', async () => {
            // 0. Preparation.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;

            let receipt = await TokenSale.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KUSDTToken.address,
                receiver,
                { from: root }
            );

            // 1. Check first 2 reverts.

            await expectRevert(
                TokenSale.deposit(bnMantissa(100)),
                'Phase 1 did not start yet.'
            );
            // phase 1 starts.
            await time.increase(time.duration.hours(1));

            await expectRevert(
                TokenSale.deposit(0),
                'Amount should be bigger than 0'
            );


            // 2. Deposit 

            // This reverts becuase user didn't approve token to TokenSale Contract.
            await expectRevert.unspecified(TokenSale.deposit(bnMantissa(100), { from: userA }));

            // apporve first 
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userA });

            // userA deposits.
            receipt = await TokenSale.deposit(bnMantissa(100), { from: userA });

            // Check Event 
            expectEvent(receipt, 'Deposit', {
                user: userA,
                amount: bnMantissa(100)
            })

            //Check userA's DepositInfo. [0] amount [1] withdrewAtPhase2 [2] tokenClaimed
            const depositInfo = await TokenSale.depositOf(userA);
            expectEqual(depositInfo[0], bnMantissa(100)) //amount
            expectEqual(depositInfo[1], false); //withdrewAtPhase2
            expectEqual(depositInfo[1], false) //tokenClaimed

            //Check Total Deposit amount
            expectEqual(await TokenSale.totalDeposit(), bnMantissa(100));

            //userB, userC, userD deposit each 100,200,300 
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userB });
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userC });
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userD });

            await TokenSale.deposit(bnMantissa(100), { from: userB });
            await TokenSale.deposit(bnMantissa(200), { from: userC });
            await TokenSale.deposit(bnMantissa(300), { from: userD });

            // Check Total Deposit (100+100+200+300 = 700)
            expectEqual(await TokenSale.totalDeposit(), bnMantissa(700));

            // 3. Check last Reverts

            // phase 1 ends.
            await time.increase(time.duration.days(4));

            await expectRevert(
                TokenSale.deposit(bnMantissa(100), { from: userA }),
                'Deposit period is already ended'
            );
        });

    });
    describe('Test : 2. Withdraw at Phase 1 ~ 6. Withdraw KSUDT to receiver (Admin)', () => {
        beforeEach(async () => {

            //Deploy from the start.
            SIGToken = await makeErc20Token({ symbol: 'SIG', name: 'SIGMA Token' });
            KUSDTToken = await makeErc20Token({ symbol: 'KUSDT', name: 'KUSDT Token' });
            TokenSale = await makeTokenSale();

            //Fund KSUDT worth 10000$
            await KUSDTToken.mint(bnMantissa(10000), { from: userA });
            await KUSDTToken.mint(bnMantissa(10000), { from: userB });
            await KUSDTToken.mint(bnMantissa(10000), { from: userC });
            await KUSDTToken.mint(bnMantissa(10000), { from: userD });

            // 0. Preparation.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;

            let receipt = await TokenSale.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KUSDTToken.address,
                receiver,
                { from: root }
            );

            //useA, userB, userC deposit each 100,200,300 & userD didn't deposit.
            await time.increase(time.duration.minutes(3));

            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userA });
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userB });
            await KUSDTToken.approve(TokenSale.address, MAX_UINT_256, { from: userC });

            await TokenSale.deposit(bnMantissa(100), { from: userA });
            await TokenSale.deposit(bnMantissa(200), { from: userB });
            await TokenSale.deposit(bnMantissa(300), { from: userC });

        });

        it('Test : 2. Withdraw at Phase 1', async () => {
            // 0. Check if it's phase 1
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await TokenSale.phase1StartTs()) && currentTime < parseInt(await TokenSale.phase2StartTs())).to.be.ok;

            // 1. Check 2 reverts. 
            await expectRevert(
                TokenSale.withdraw(0, { from: userA }),
                'Required amount of withdrawal should be bigger than 0'
            );
            await expectRevert(
                TokenSale.withdraw(bnMantissa(100), { from: userD }),
                'No funds available to withdraw'
            );

            // 2.  UserA withdraws all withdrawableAmount 
            const userAWithdrawableAmount = await TokenSale.getWithdrawableAmount({ from: userA });
            console.log('userAWithdrawableAmount : ', userAWithdrawableAmount.toString())

            let totalKUSDTDeposit = await TokenSale.totalDeposit();
            const userAKUSDTDeposit = (await TokenSale.depositOf(userA))[0];
            const userAKUSDTBalance = await KUSDTToken.balanceOf(userA)
            let receipt = await TokenSale.withdraw(userAWithdrawableAmount, { from: userA });


            expectEvent(receipt, 'Withdrawal', {
                user: userA,
                amount: userAKUSDTDeposit
            })

            expectEqual(await KUSDTToken.balanceOf(userA), userAKUSDTBalance.add(userAWithdrawableAmount));
            expectEqual(await TokenSale.totalDeposit(), totalKUSDTDeposit.sub(userAKUSDTDeposit));

            //Deposit again. Phase 1 allow free deposit and withdrawal
            await TokenSale.deposit(bnMantissa(100), { from: userA });

            // 3. UserB withdraw half of withdrawableAmount
            const userBWithdrawableAmount = await TokenSale.getWithdrawableAmount({ from: userB })
            const userBKUSDTDeposit = (await TokenSale.depositOf(userB))[0]
            const userBKUSDTBalance = await KUSDTToken.balanceOf(userB)
            totalKUSDTDeposit = await TokenSale.totalDeposit();

            const requiredAmount = userBWithdrawableAmount.div(new BN(2));
            receipt = await TokenSale.withdraw(requiredAmount, { from: userB })
            expectEvent(receipt, 'Withdrawal', {
                user: userB,
                amount: requiredAmount
            })

            expectEqual((await TokenSale.depositOf(userB))[0], userBKUSDTDeposit.sub(requiredAmount))
            expectEqual(((await TokenSale.depositOf(userB))[1]), false) // depositInfo[1] is withdrewAtPhase2;
            expectEqual(await TokenSale.totalDeposit(), totalKUSDTDeposit.sub(requiredAmount))
        });

        it('Test : 3. Withdraw at Phase 2', async () => {
            // 0. Check if it's phase 2
            await time.increase(time.duration.days(4));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await TokenSale.phase2StartTs()) && currentTime < parseInt(await TokenSale.phase2EndTs())).to.be.ok;

            // [If you want, run this for loop]
            // for (let i = 0; i < 23; i++) {
            //     await time.increase(time.duration.hours(1));
            //     let amount = (await TokenSale.getWithdrawableAmount({ from: userA })) / 1e18;
            //     console.log(`${i + 2} 시 까지`, amount.toString())
            // }

            // [ Result (in case user deposit 100 KUSDT) ]
            // 1 시 까지 100
            // 2 시 까지 95.83333333333333 (95833333333333333300 wei)
            // 3 시 까지 91.66666666666667 (91666666666666666600 wei)
            // 4 시 까지 87.5   (87500000000000000000 wei)
            // 5 시 까지 83.33333333333333
            // 6 시 까지 79.16666666666667
            // 7 시 까지 75
            // 8 시 까지 70.83333333333334
            // 9 시 까지 66.66666666666666
            // 10 시 까지 62.5
            // 11 시 까지 58.333333333333336
            // 12 시 까지 54.166666666666664
            // 13 시 까지 50
            // 14 시 까지 45.833333333333336
            // 15 시 까지 41.666666666666664
            // 16 시 까지 37.5
            // 17 시 까지 33.33333333333333
            // 18 시 까지 29.166666666666668
            // 19 시 까지 25
            // 20 시 까지 20.833333333333332
            // 21 시 까지 16.666666666666664
            // 22 시 까지 12.5
            // 23 시 까지 8.333333333333332 (8333333333333333300 wei)
            // 24 시 까지 4.166666666666666 (4166666666666666600 wei)

            // 1. 4 days + 3 mins : 100% withdrawl available
            const userAKUSDTDeposit = (await TokenSale.depositOf(userA))[0]
            let userAWithdrawableAmount = await TokenSale.getWithdrawableAmount({ from: userA });
            let receipt = await TokenSale.withdraw(userAKUSDTDeposit, { from: userA })
            expectEvent(receipt, 'Withdrawal', {
                user: userA,
                amount: userAWithdrawableAmount
            })
            expectEqual(((await TokenSale.depositOf(userA))[1]), true) // depositInfo[1] is withdrewAtPhase2;



            // 2. 4 days + 3 hours + 3 mins : 87.5% of deposit can be withdrawn.
            await time.increase(time.duration.hours(3));

            // Check reverts
            await expectRevert(
                TokenSale.withdraw(0, { from: userB }),
                'Required amount of withdrawal should be bigger than 0'
            );

            // Get User B amount of deposit.
            const userBKUSDTDeposit = (await TokenSale.depositOf(userB))[0];
            await expectRevert(TokenSale.withdraw(userBKUSDTDeposit, { from: userB }), 'You can\'t withdraw more than current withdrawable amount')

            const userBWithdrawableAmount = await TokenSale.getWithdrawableAmount({ from: userB });
            console.log('UserB Withdrawable amount : ', userBWithdrawableAmount.toString())

            receipt = await TokenSale.withdraw(userBWithdrawableAmount, { from: userB })

            expectEvent(receipt, 'Withdrawal', {
                user: userB,
                amount: userBWithdrawableAmount
            })

            expectEqual(((await TokenSale.depositOf(userB))[1]), true) // depositInfo[1] is withdrewAtPhase2;
            await expectRevert(TokenSale.withdraw(1, { from: userB }), 'Already withdrew fund. Withdrawal is only permitted once.')


            // 3. 4 days + 24 hours + 3 mins : can't withdraw anymore.
            await time.increase(time.duration.hours(21));
            await expectRevert(TokenSale.withdraw(1, { from: userC }), 'Withdraw period is already done.')

        });

        it('Test : 4. Release Token (Admin)', async () => {

            // 0. Check reverts.
            await expectRevert(
                TokenSale.releaseToken({ from: root }),
                'Phase 2 should end to release SIG Tokens.'
            );

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await TokenSale.phase2EndTs())).to.be.ok;

            // 2. Check reverts
            await expectRevert(
                TokenSale.releaseToken({ from: userA }), //Not owner
                'Ownable: caller is not the owner'
            );


            // 2. Mint SIG to root account which is the owner of the contract.
            await SIGToken.mint(bnMantissa(70000000), { from: root })
            await SIGToken.approve(TokenSale.address, MAX_UINT_256, { from: root })

            // 3. Release Token.
            let receipt = await TokenSale.releaseToken({ from: root });
            expectEvent(receipt, 'SIGTokenReleased', {
                releasedTokenAmount: bnMantissa(70000000)
            })
            expectEqual(await SIGToken.balanceOf(TokenSale.address), bnMantissa(70000000))
            expectEqual(await TokenSale.tokensReleased(), true);

            // 4. Check revert

            await expectRevert(
                TokenSale.releaseToken({ from: root }),
                'Tokens are already released.'
            );
        });

        it('Test : 5. Withdraw Tokens (User)', async () => {
            // 0. Check Reverts
            await expectRevert(
                TokenSale.withdrawTokens({ from: userA }),
                'You can\'t withdraw tokens before phase 2 ends.'
            );

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await TokenSale.phase2EndTs())).to.be.ok;

            // 2. Check Reverts.
            await expectRevert(
                TokenSale.withdrawTokens({ from: userA }),
                'Token is not released yet'
            );

            // 3. Release Token from owner.
            await SIGToken.mint(bnMantissa(70000000), { from: root })
            await SIGToken.approve(TokenSale.address, MAX_UINT_256, { from: root })
            await TokenSale.releaseToken({ from: root });


            // 4. Check Revert
            await expectRevert(
                TokenSale.withdrawTokens({ from: userD }),
                'No funds available to withdraw token'
            );


            // 5. Withdraw Token A : 100 B : 200 : C :300
            const toatlSupply = await TokenSale.TOTAL_SIG_SUPPLY()
            const totalDeposit = await TokenSale.totalDeposit()
            const userAKUSDTDeposit = ((await TokenSale.depositOf(userA))[0]).mul(bnMantissa(1))
            const userBKUSDTDeposit = ((await TokenSale.depositOf(userB))[0]).mul(bnMantissa(1))
            const userCKUSDTDeposit = ((await TokenSale.depositOf(userC))[0]).mul(bnMantissa(1))


            const userAReedeamableExpect = (toatlSupply.mul(userAKUSDTDeposit.div(totalDeposit))).div(bnMantissa(1))
            const userBReedeamableExpect = (toatlSupply.mul(userBKUSDTDeposit.div(totalDeposit))).div(bnMantissa(1))
            const userCReedeamableExpect = (toatlSupply.mul(userCKUSDTDeposit.div(totalDeposit))).div(bnMantissa(1))

            console.log("userAReedeamableExpect : ", userAReedeamableExpect.toString())
            console.log("userBReedeamableExpect : ", userBReedeamableExpect.toString())
            console.log("userCReedeamableExpect : ", userCReedeamableExpect.toString())

            let receipt = await TokenSale.withdrawTokens({ from: userA })
            expectEvent(receipt, "TokenClaimed", {
                user: userA,
                amount: userAReedeamableExpect
            })

            receipt = await TokenSale.withdrawTokens({ from: userB })
            expectEvent(receipt, "TokenClaimed", {
                user: userB,
                amount: userBReedeamableExpect
            })

            receipt = await TokenSale.withdrawTokens({ from: userC })
            expectEvent(receipt, "TokenClaimed", {
                user: userC,
                amount: userCReedeamableExpect
            })

            const userASIGBalance = await SIGToken.balanceOf(userA);
            const userBSIGBalance = await SIGToken.balanceOf(userB);
            const userCSIGBalance = await SIGToken.balanceOf(userC);

            const allDistributedSIG = userASIGBalance.add(userBSIGBalance.add(userCSIGBalance))
            console.log("allDistributedSIG : ", allDistributedSIG.toString())
            console.log("Total supply : ", toatlSupply.toString())
            console.log("left SIG Token in contract", (await SIGToken.balanceOf(TokenSale.address)).toString())
            expectAlmostEqualMantissa(allDistributedSIG, toatlSupply)

            // 6. Check revert
            await expectRevert(TokenSale.withdrawTokens({ from: userA }), 'Tokens are already claimed')
            await expectRevert(TokenSale.withdrawTokens({ from: userB }), 'Tokens are already claimed')
            await expectRevert(TokenSale.withdrawTokens({ from: userC }), 'Tokens are already claimed')



        });

        it('Test : 6. Withdraw KSUDT to receiver (Admin)', async () => {
            // 0. Check if it's end of Phase 2
            await expectRevert(TokenSale.adminWithdraw({ from: userA }), 'Ownable: caller is not the owner')
            await expectRevert(TokenSale.adminWithdraw({ from: root }), 'Phase 2 should end to withdraw KUSDT Tokens.')

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await TokenSale.phase2EndTs())).to.be.ok;

            // 2. Check KUSDT Balance of this contract
            const KUSDTBalance = await KUSDTToken.balanceOf(TokenSale.address);
            console.log("KUSDT Deposited Balance : ", KUSDTBalance.toString());
            expectEqual(await TokenSale.totalDeposit(), KUSDTBalance);

            // 3. Withdraw KUSDT to receiver's account.

            let receipt = await TokenSale.adminWithdraw({ from: root })
            expectEvent(receipt, 'AdminWithdraw', {
                withdrawAmount: KUSDTBalance
            })

            const recieverKUSDTBalance = await KUSDTToken.balanceOf(receiver);
            expectEqual(recieverKUSDTBalance, KUSDTBalance);
        });
    });
});
