const { makeErc20Token, MockERC20, makeLockdrop } = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual,
    time
} = require('../Utils/JS');
const { use } = require('chai');
// const { it } = require('mocha');

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Deposit (User)
 *    +) Set Lock Month (User)
 * 2. Withdraw at Phase 1 (User)
 * 3. Withdraw at Phase 2 (User)
 * 4. Withdraw KSP to receiver (Admin) 
 * 5. Release SIG Token (Admin)
 * 6. Release LP Token (Admin)
 * 7. Claim SIG Tokens (User)
 * 8. Withdraw LP Tokens after Lock period (User)
 *
 * <View Function>
 * 1. View public Variables
 * 2. View crucial current Status
 *    1) Total KSP
 *    2) Total Weight (Weight  = lockMonth * amount)
 *    3) Your Contribution
 *    4) Redeemable SIG Amount
 *    5) Withdrawable LP Token Amount
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.

contract('Lockdrop', function (accounts) {
    let root = accounts[0];
    let receiver = accounts[1]; // Admin address who gets KSP at the end of phase2.
    let userA = accounts[2];
    let userB = accounts[3];
    let userC = accounts[4];
    let userD = accounts[5];
    let randomUser = accounts[6];

    let KSPToken;
    let SIGToken;
    let Lockdrop;
    let lpToken;


    const WEEK = 604800;
    const DAY = 60 * 60 * 24;
    const HOUR = 3600;
    const MINUTE = 60;

    const LOCK_1_MONTHS = 2628000; // 0.9x
    const LOCK_3_MONTHS = 7884000; // 3x
    const LOCK_6_MONTHS = 15768000; // 7x
    const LOCK_10_MONTHS = 26280000; // 18x

    const vestingPeriod = new BN((3 * DAY).toString());

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo , 1.Deposit requirements', () => {

        before(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            KSPToken = await makeErc20Token();
            lpToken = await makeErc20Token();
            Lockdrop = await makeLockdrop();

            //Fund 10000 KSP worth
            await KSPToken.mint(bnMantissa(10000), { from: userA });
            await KSPToken.mint(bnMantissa(10000), { from: userB });
            await KSPToken.mint(bnMantissa(10000), { from: userC });
            await KSPToken.mint(bnMantissa(10000), { from: userD });
        });

        it('Test : 0.SetInitialInfo', async () => {
            //1. Check only Owner function.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;

            expectEqual(await Lockdrop.owner(), root);
            await expectRevert(
                Lockdrop.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    receiver,
                    vestingPeriod,// vesting period 
                    { from: userA } // This function always need to be called by the owner (root)
                ),
                'Ownable: caller is not the owner'
            );

            //2. Check Reverts.
            await expectRevert(
                Lockdrop.setInitialInfo(
                    currentTime,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    receiver,
                    vestingPeriod,
                    { from: root }
                ),
                'Phase1 should start in the future.'
            );

            await expectRevert(Lockdrop.setInitialInfo(
                phase1StartTs,
                phase1StartTs - MINUTE,
                phase2EndTs,
                SIGToken.address,
                KSPToken.address,
                lpToken.address,
                receiver,
                vestingPeriod,
                { from: root }
            ),
                'Phase2 should start after phase1'
            );

            let newPhase2EndTs = phase2StartTs - MINUTE;
            await expectRevert(
                Lockdrop.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    newPhase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    receiver,
                    vestingPeriod,
                    { from: root }
                ),
                'phase2StartTs should smaller than phase2EndTs'
            );

            newPhase2EndTs = phase2StartTs + 59 * MINUTE;

            await expectRevert(
                Lockdrop.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    newPhase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    receiver,
                    vestingPeriod,
                    { from: root }
                ),
                'Phase2 should be longer than 1 hour.'
            );

            await expectRevert(
                Lockdrop.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    '0x0000000000000000000000000000000000000000',
                    vestingPeriod,
                    { from: root }
                ),
                'Invalid receiver address.'
            );

            await expectRevert(
                Lockdrop.setInitialInfo(
                    phase1StartTs,
                    phase2StartTs,
                    phase2EndTs,
                    SIGToken.address,
                    KSPToken.address,
                    lpToken.address,
                    receiver,
                    new BN(0),
                    { from: root }
                ),
                'Vesting period should be bigger than 0'
            );

            //3. Check event emits.
            let receipt = await Lockdrop.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KSPToken.address,
                lpToken.address,
                receiver,
                vestingPeriod,
                { from: root }
            )

            expectEvent(receipt, 'InitialInfoSet', {
                phase1StartTs: new BN(phase1StartTs),
                phase2StartTs: new BN(phase2StartTs),
                phase2EndTs: new BN(phase2EndTs),
                receiver: receiver,
                vestingPeriod: vestingPeriod
            });
        });

        it('Test : 1.Deposit requirements', async () => {

            // 1. Check first 2 reverts.
            await expectRevert(
                Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA }),
                'Phase 1 did not start yet.'
            );
            // phase 1 starts.
            await time.increase(time.duration.hours(1));

            await expectRevert(
                Lockdrop.deposit(0, LOCK_1_MONTHS, { from: userA }),
                'Amount should be bigger than 0'
            );

            await expectRevert(
                Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS + 1, { from: userA }), 'Lock Month must be one of 1,3,6 or 10 months.'
            )


            // 2. Deposit 

            // This reverts becuase user didn't approve token to Lockdrop Contract.
            await expectRevert.unspecified(Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA }));

            // apporve first 
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userA });

            // userA deposits.
            let receipt = await Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA });

            // Check Event 
            expectEvent(receipt, 'Deposit', {
                user: userA,
                amount: bnMantissa(100),
                lockMonth: new BN(LOCK_1_MONTHS)
            })


            //Check userA's DepositInfo. [0] amount [1] withdrewAtPhase2 [2] tokenClaimed
            let depositInfo = await Lockdrop.depositOf(userA);
            const multiplier = await Lockdrop.multiplierOf(LOCK_1_MONTHS);
            const exepectedWeight = bnMantissa(100).mul(multiplier).div(new BN(1e5));

            expectEqual(depositInfo[0], bnMantissa(100)) //amount
            expectEqual(depositInfo[1], exepectedWeight) // weight : 90
            expectEqual(depositInfo[2], LOCK_1_MONTHS); // Lock month
            expectEqual(depositInfo[3], new BN(0)) // claimedSIG
            expectEqual(depositInfo[4], false) // withdrewAtPhase2
            expectEqual(depositInfo[5], false) // isLPTokensClaimed

            //Check Total Deposit amount
            expectEqual(await Lockdrop.totalDeposit(), bnMantissa(100));
            expectEqual(await Lockdrop.totalWeight(), exepectedWeight);

            //userB, userC, userD deposit each 100,200,300 
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userB });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userC });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userD });

            await Lockdrop.deposit(bnMantissa(100), LOCK_3_MONTHS, { from: userB });
            await Lockdrop.deposit(bnMantissa(200), LOCK_6_MONTHS, { from: userC });
            await Lockdrop.deposit(bnMantissa(300), LOCK_10_MONTHS, { from: userD });

            // Check Total Deposit (100+100+200+300 = 700)
            expectEqual(await Lockdrop.totalDeposit(), bnMantissa(700));

            // Check Total Weight (100*0.9+100*3+200*7+300*18 = 7190)
            expectEqual(await Lockdrop.totalWeight(), bnMantissa(7190));

            // 3. Set Lock Month 
            await expectRevert(Lockdrop.setLockMonth(LOCK_1_MONTHS + 1, { from: userA }), 'Lock Month must be one of 1,3,6 or 10 months.')
            await expectRevert(Lockdrop.setLockMonth(0, { from: userA }), 'Lock Month must be one of 1,3,6 or 10 months.')
            await expectRevert(Lockdrop.setLockMonth(LOCK_3_MONTHS, { from: randomUser }), 'No funds available to change lock month')

            let currentTotalWeight = await Lockdrop.totalWeight()
            let threeMonthsMultiplier = await Lockdrop.multiplierOf(LOCK_3_MONTHS);
            depositInfo = await Lockdrop.depositOf(userA);
            let oldWeight = depositInfo[1];
            let newExepectedWeight = depositInfo[0].mul(threeMonthsMultiplier).div(new BN(1e5));
            let newExepectedTotalWeight = currentTotalWeight.sub(oldWeight).add(newExepectedWeight);

            // set lock month
            await Lockdrop.setLockMonth(LOCK_3_MONTHS, { from: userA })

            // check numbers
            expectEqual(newExepectedTotalWeight, await Lockdrop.totalWeight())

            depositInfo = await Lockdrop.depositOf(userA);
            let newWeight = depositInfo[1];
            expectEqual(newExepectedWeight, newWeight);
            expectEqual(depositInfo[2], LOCK_3_MONTHS);

            // 4. Deposit more with new Lock Month 

            await Lockdrop.deposit(bnMantissa(100), LOCK_3_MONTHS, { from: userA });

            depositInfo = await Lockdrop.depositOf(userA)
            expectEqual(depositInfo[0], bnMantissa(200)); // amount 
            expectEqual(depositInfo[1], bnMantissa(600)); // weight
            expectEqual(depositInfo[2], new BN(LOCK_3_MONTHS)); // lock month 

            // 5. Check last Reverts
            // phase 1 ends.
            await time.increase(time.duration.days(4));

            await expectRevert(
                Lockdrop.deposit(bnMantissa(100), MAX_UINT_256, { from: userA }),
                'Deposit period is already ended'
            );

            // phase 2 ends
            await time.increase(time.duration.days(100));
            await expectRevert(Lockdrop.setLockMonth(LOCK_3_MONTHS, { from: userA }), 'Phase2 is already done. You can\'t change lock month anymore')

        });

    });
    describe('Test : 2. Withdraw at Phase 1 ~ 6. Release LP Token (Admin)', () => {
        beforeEach(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            KSPToken = await makeErc20Token();
            lpToken = await makeErc20Token();
            Lockdrop = await makeLockdrop();

            //Fund 10000 KSP worth
            await KSPToken.mint(bnMantissa(10000), { from: userA });
            await KSPToken.mint(bnMantissa(10000), { from: userB });
            await KSPToken.mint(bnMantissa(10000), { from: userC });
            await KSPToken.mint(bnMantissa(10000), { from: userD });


            // 0. Preparation.

            //1. Check only Owner function.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;
            //3. Check event emits.
            let receipt = await Lockdrop.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KSPToken.address,
                lpToken.address,
                receiver,
                vestingPeriod,
                { from: root }
            )

            //useA, userB, userC deposit each 100,200,300,400 for 1,3,6,10 months
            await time.increase(time.duration.minutes(3));

            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userA });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userB });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userC });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userD });

            await Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA });
            await Lockdrop.deposit(bnMantissa(200), LOCK_3_MONTHS, { from: userB });
            await Lockdrop.deposit(bnMantissa(300), LOCK_6_MONTHS, { from: userC });
            await Lockdrop.deposit(bnMantissa(400), LOCK_10_MONTHS, { from: userD });

        });

        it('Test : 2. Withdraw at Phase 1', async () => {
            // 0. Check if it's phase 1
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await Lockdrop.phase1StartTs()) && currentTime < parseInt(await Lockdrop.phase2StartTs())).to.be.ok;

            // 1. Check 2 reverts. 
            await expectRevert(
                Lockdrop.withdraw(0, { from: userA }),
                'Required amount of withdrawal should be bigger than 0'
            );
            await expectRevert(
                Lockdrop.withdraw(bnMantissa(100), { from: randomUser }),
                'No funds available to withdraw'
            );

            // 2.  UserA withdraws all withdrawableAmount 
            const userAWithdrawableAmount = await Lockdrop.getWithdrawableKSPAmount({ from: userA });
            console.log('userAWithdrawableAmount : ', userAWithdrawableAmount.toString())

            let totalKSPDeposit = await Lockdrop.totalDeposit();
            let userInfo = await Lockdrop.depositOf(userA)
            const userAKSPDeposit = userInfo[0];
            const oldUserAWeight = userInfo[1];
            let oldTotalWeight = await Lockdrop.totalWeight();
            // expect user can withdraw all of its money
            expectEqual(userAWithdrawableAmount, userAKSPDeposit);
            const userAKSPBalance = await KSPToken.balanceOf(userA)
            let receipt = await Lockdrop.withdraw(userAWithdrawableAmount, { from: userA });


            expectEvent(receipt, 'Withdrawal', {
                user: userA,
                amount: userAKSPDeposit
            })

            expectEqual(await KSPToken.balanceOf(userA), userAKSPBalance.add(userAWithdrawableAmount));
            expectEqual(await Lockdrop.totalDeposit(), totalKSPDeposit.sub(userAKSPDeposit));

            // 3. Check UserA's weight and total weight updated.
            userInfo = await Lockdrop.depositOf(userA)
            expectEqual(userInfo[0], new BN(0)); // amount
            expectEqual(userInfo[1], new BN(0)); // weight 
            expectEqual(userInfo[2], new BN(0)); // lock month 
            // total weight has been udpated. 
            expectEqual(await Lockdrop.totalWeight(), oldTotalWeight.sub(oldUserAWeight));

            // Deposit again. Phase 1 allow free deposit and withdrawal
            await Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA });
            await Lockdrop.deposit(bnMantissa(100), LOCK_3_MONTHS, { from: userA });


            // 4. UserB withdraw half of withdrawableAmount
            const userBWithdrawableAmount = await Lockdrop.getWithdrawableKSPAmount({ from: userB })
            userInfo = await Lockdrop.depositOf(userB)
            const userBKSPDeposit = userInfo[0]
            const userBKSPBalance = await KSPToken.balanceOf(userB)
            const oldUserBWeight = userInfo[1]
            const oldUserBLockMonth = userInfo[2]
            oldTotalWeight = await Lockdrop.totalWeight();

            totalKSPDeposit = await Lockdrop.totalDeposit();

            const requiredAmount = userBWithdrawableAmount.div(new BN(2));
            receipt = await Lockdrop.withdraw(requiredAmount, { from: userB })
            expectEvent(receipt, 'Withdrawal', {
                user: userB,
                amount: requiredAmount
            })
            expectEqual((await Lockdrop.depositOf(userB))[0], userBKSPDeposit.sub(requiredAmount))
            expectEqual(await Lockdrop.totalDeposit(), totalKSPDeposit.sub(requiredAmount))

            // 5. Check UserB's weight and total weight updated. 
            userInfo = await Lockdrop.depositOf(userB)
            const expectedWeight = (await Lockdrop.multiplierOf(oldUserBLockMonth)).mul(userBKSPDeposit.sub(requiredAmount)).div(new BN(1e5))
            console.log('user b expected weight :', expectedWeight.toString())
            expectEqual(userInfo[1], (await Lockdrop.multiplierOf(oldUserBLockMonth)).mul(userBKSPDeposit.sub(requiredAmount)).div(new BN(1e5)))
            expectEqual(await Lockdrop.totalWeight(), oldTotalWeight.sub(oldUserBWeight).add(expectedWeight))
        });

        it('Test : 3. Withdraw at Phase 2', async () => {
            // 0. Check if it's phase 2
            await time.increase(time.duration.days(4));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await Lockdrop.phase2StartTs()) && currentTime < parseInt(await Lockdrop.phase2EndTs())).to.be.ok;

            // [If you want, run this for loop]
            // for (let i = 0; i < 23; i++) {
            //     await time.increase(time.duration.hours(1));
            //     let amount = (await Lockdrop.getWithdrawableKSPAmount({ from: userA })) / 1e18;
            //     console.log(`${i + 2} 시 까지`, amount.toString())
            // }

            // [ Result (in case user deposit 100 KSP) ]
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
            const userAKSPDeposit = (await Lockdrop.depositOf(userA))[0]
            let userAWithdrawableAmount = await Lockdrop.getWithdrawableKSPAmount({ from: userA });
            let receipt = await Lockdrop.withdraw(userAKSPDeposit, { from: userA })

            expectEvent(receipt, 'Withdrawal', {
                user: userA,
                amount: userAWithdrawableAmount
            })

            let userInfo = await Lockdrop.depositOf(userA)
            expectEqual(userInfo[0], new BN(0)); // amount
            expectEqual(userInfo[1], new BN(0)); // weight 
            expectEqual(userInfo[2], new BN(0)); // lock month 
            expectEqual(userInfo[4], true) // depositInfo[1] is withdrewAtPhase2;


            // 2. 4 days + 3 hours + 3 mins : 87.5% of deposit can be withdrawn.
            await time.increase(time.duration.hours(3));

            // Check reverts
            await expectRevert(
                Lockdrop.withdraw(0, { from: userB }),
                'Required amount of withdrawal should be bigger than 0'
            );

            // Get User B amount of deposit.
            const userBKSPDeposit = (await Lockdrop.depositOf(userB))[0];
            await expectRevert(Lockdrop.withdraw(userBKSPDeposit, { from: userB }), 'You can\'t withdraw more than current withdrawable amount')

            const userBWithdrawableAmount = await Lockdrop.getWithdrawableKSPAmount({ from: userB });
            console.log('UserB Withdrawable amount : ', userBWithdrawableAmount.toString())

            userInfo = await Lockdrop.depositOf(userB)
            let oldWeight = userInfo[1];
            let oldTotalWeight = await Lockdrop.totalWeight()

            receipt = await Lockdrop.withdraw(userBWithdrawableAmount, { from: userB })
            expectEvent(receipt, 'Withdrawal', {
                user: userB,
                amount: userBWithdrawableAmount
            })

            // Check weight 
            userInfo = await Lockdrop.depositOf(userB)
            let newWeight = userInfo[1];
            let newTotalWeight = await Lockdrop.totalWeight()

            expectEqual(oldTotalWeight.sub(newTotalWeight), oldWeight.sub(newWeight))
            expectEqual(((await Lockdrop.depositOf(userB))[4]), true) // depositInfo[1] is withdrewAtPhase2;
            await expectRevert(Lockdrop.withdraw(1, { from: userB }), 'Already withdrew fund. Withdrawal is only permitted once.')

            // 3. 4 days + 24 hours + 3 mins : can't withdraw anymore.
            await time.increase(time.duration.hours(21));
            await expectRevert(Lockdrop.withdraw(1, { from: userC }), 'Withdraw period is already done.')

        });

        it('Test : 4 Withdraw KSP Token to Receiver', async () => {
            // 0. Check if it's end of Phase 2
            await expectRevert(Lockdrop.adminWithdraw({ from: userA }), 'Ownable: caller is not the owner')
            await expectRevert(Lockdrop.adminWithdraw({ from: root }), 'Phase 2 should end to withdraw KSP Tokens.')

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await Lockdrop.phase2EndTs())).to.be.ok;

            // 2. Check KSP Balance of this contract
            const KSPBalance = await KSPToken.balanceOf(Lockdrop.address);
            console.log("KSP Deposited Balance : ", KSPBalance.toString());
            expectEqual(await Lockdrop.totalDeposit(), KSPBalance);

            // 3. Withdraw KSP to receiver's account.
            let receipt = await Lockdrop.adminWithdraw({ from: root })
            expectEvent(receipt, 'AdminWithdraw', {
                withdrawAmount: KSPBalance
            })

            const recieverKSPBalance = await KSPToken.balanceOf(receiver);
            expectEqual(recieverKSPBalance, KSPBalance);
            expectEqual(await KSPToken.balanceOf(Lockdrop.address), new BN(0))
        })

        it('Test : 5. Release SIG Token (Admin)', async () => {

            // 0. Check reverts.
            await expectRevert(
                Lockdrop.releaseSIGToken({ from: root }),
                'Phase 2 should end to release SIG Tokens.'
            );

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await Lockdrop.phase2EndTs())).to.be.ok;

            // 2. Check reverts
            await expectRevert(
                Lockdrop.releaseSIGToken({ from: userA }), //Not owner
                'Ownable: caller is not the owner'
            );


            // 2. Mint SIG to root account which is the owner of the contract.
            await SIGToken.mint(bnMantissa(9000000), { from: root })
            await SIGToken.approve(Lockdrop.address, MAX_UINT_256, { from: root })

            // 3. Release Token.
            let receipt = await Lockdrop.releaseSIGToken({ from: root });
            expectEvent(receipt, 'SIGTokenReleased', {
                releasedTokenAmount: bnMantissa(9000000)
            })
            expectEqual(await SIGToken.balanceOf(Lockdrop.address), bnMantissa(9000000))
            expectEqual(await Lockdrop.isSIGTokensReleased(), true);

            // 4. Check revert
            await expectRevert(
                Lockdrop.releaseSIGToken({ from: root }),
                'Tokens are already released.'
            );
        });

        it('Test : 6. Release LP Token (Admin)', async () => {
            // 0. Check reverts.
            await expectRevert(
                Lockdrop.releaseLPToken(bnMantissa(10000), { from: root }),
                'Phase 2 should end to release LP Tokens.'
            );

            // 1. Check if it's end of Phase 2
            await time.increase(time.duration.days(5));
            const currentTime = parseInt(await time.latest())
            expect(currentTime >= parseInt(await Lockdrop.phase2EndTs())).to.be.ok;

            // 2. Check reverts
            await expectRevert(
                Lockdrop.releaseLPToken(bnMantissa(10000), { from: userA }), //Not owner
                'Ownable: caller is not the owner'
            );

            // 3. Mint LP token to root account
            await lpToken.mint(bnMantissa(10000), { from: root })
            await lpToken.approve(Lockdrop.address, MAX_UINT_256, { from: root })

            let receipt = await Lockdrop.releaseLPToken(bnMantissa(10000), { from: root })
            expectEvent(receipt, 'LPTokenReleased', {
                releasedTokenAmount: bnMantissa(10000)
            })

            expectEqual(await Lockdrop.totalLPTokenSupply(), bnMantissa(10000))
            expectEqual(await Lockdrop.isLPTokensReleased(), true);

        })
    });

    describe('Test : 7. Claim SIG Tokens (User) ~ 8. Withdraw LP Tokens after Lock period', () => {
        beforeEach(async () => {
            //Deploy from the start.
            SIGToken = await makeErc20Token();
            KSPToken = await makeErc20Token();
            lpToken = await makeErc20Token();
            Lockdrop = await makeLockdrop();

            //Fund 10000 KSP worth
            await KSPToken.mint(bnMantissa(10000), { from: userA });
            await KSPToken.mint(bnMantissa(10000), { from: userB });
            await KSPToken.mint(bnMantissa(10000), { from: userC });
            await KSPToken.mint(bnMantissa(10000), { from: userD });


            // 0. Preparation.

            //1. Check only Owner function.
            let currentTime = parseInt(await time.latest());
            let phase1StartTs = currentTime + MINUTE;
            let phase2StartTs = phase1StartTs + 4 * DAY;
            let phase2EndTs = phase2StartTs + DAY;
            //3. Check event emits.
            let receipt = await Lockdrop.setInitialInfo(
                phase1StartTs,
                phase2StartTs,
                phase2EndTs,
                SIGToken.address,
                KSPToken.address,
                lpToken.address,
                receiver,
                vestingPeriod,
                { from: root }
            )

            //useA, userB, userC deposit each 100,200,300,400 for 1,3,6,10 months
            await time.increase(time.duration.minutes(3));

            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userA });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userB });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userC });
            await KSPToken.approve(Lockdrop.address, MAX_UINT_256, { from: userD });

            await Lockdrop.deposit(bnMantissa(100), LOCK_1_MONTHS, { from: userA });
            await Lockdrop.deposit(bnMantissa(200), LOCK_3_MONTHS, { from: userB });
            await Lockdrop.deposit(bnMantissa(300), LOCK_6_MONTHS, { from: userC });
            await Lockdrop.deposit(bnMantissa(400), LOCK_10_MONTHS, { from: userD });


            // withdraw ksp 
            await time.increase(time.duration.days(5));
            await Lockdrop.adminWithdraw({ from: root })
        });


        it('7. Claim SIG Tokens (User)', async () => {
            // 1. Check reverts. 
            // not released yet
            await expectRevert(Lockdrop.claimSIGTokens({ from: userA }), 'Sig Token is not released yet')

            const TOTAL_SIG_SUPPLY = bnMantissa(9000000)
            // release sig token
            await SIGToken.mint(TOTAL_SIG_SUPPLY, { from: root })
            await SIGToken.approve(Lockdrop.address, MAX_UINT_256, { from: root })
            await Lockdrop.releaseSIGToken({ from: root });

            // didn't deposit
            await expectRevert(Lockdrop.claimSIGTokens({ from: randomUser }), 'No funds available to withdraw token')

            // 2. UserA claim sig token after an hour

            let userTotalAllocatedSIGToken = await Lockdrop.userTotalAllocatedSIGToken(userA)
            console.log('userTotalAllocatedSIGToken', userTotalAllocatedSIGToken.toString())
            console.log('userClaimableSIGToken ', (await Lockdrop.userClaimableSIGAmount(userA)).toString())

            expectAlmostEqualMantissa(userTotalAllocatedSIGToken, TOTAL_SIG_SUPPLY.mul((await Lockdrop.depositOf(userA))[1]).div(await Lockdrop.totalWeight()))

            // reward vesting period is 3 day. 
            // after 1 day approximately 1/3 sig token should be claimable. 

            await time.increase(time.duration.days(1))
            let userClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userA)
            console.log('userClaimableSIGAmount after 1 day ', userClaimableSIGAmount.toString())

            // Claim Sig Token
            let receipt = await Lockdrop.claimSIGTokens({ from: userA })
            expectEvent(receipt, 'SIGTokenClaimed', {
                user: userA,
                amount: await SIGToken.balanceOf(userA)
            })

            let userInfo = await Lockdrop.depositOf(userA)
            let claimedSIG = userInfo[3];
            console.log('claimed SIG : ', claimedSIG.toString())
            expectEqual(claimedSIG, await SIGToken.balanceOf(userA))

            await time.increase(time.duration.days(1))
            userClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userA)
            console.log('userClaimableSIGAmount after 2 day ', userClaimableSIGAmount.toString())
            await time.increase(time.duration.days(1))
            userClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userA)
            console.log('userClaimableSIGAmount after 3 day ', userClaimableSIGAmount.toString())
            await time.increase(time.duration.days(1))

            // doesn't change anymore.
            userClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userA)
            console.log('userClaimableSIGAmount after 4+ day ', userClaimableSIGAmount.toString())

            receipt = await Lockdrop.claimSIGTokens({ from: userA })
            expectEvent(receipt, 'SIGTokenClaimed', {
                user: userA,
                amount: (await SIGToken.balanceOf(userA)).sub(claimedSIG)
            })

            userInfo = await Lockdrop.depositOf(userA)
            claimedSIG = userInfo[3];
            expectEqual(claimedSIG, userTotalAllocatedSIGToken);

            let userBClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userB)
            console.log('userB ClaimableSIGAmount after 4+ day ', userBClaimableSIGAmount.toString())

            let userCClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userC)
            console.log('userC ClaimableSIGAmount after 4+ day ', userCClaimableSIGAmount.toString())

            let userDClaimableSIGAmount = await Lockdrop.userClaimableSIGAmount(userD)
            console.log('userD ClaimableSIGAmount after 4+ day ', userDClaimableSIGAmount.toString())

            expectAlmostEqualMantissa(TOTAL_SIG_SUPPLY, claimedSIG.add(userBClaimableSIGAmount).add(userCClaimableSIGAmount).add(userDClaimableSIGAmount))
        })


        it('8. Withdraw LP Tokens after Lock period', async () => {
            // 1. CheckReverts
            await expectRevert(Lockdrop.withdrawLPTokens({ from: userA }), 'LP Token should be released first.')

            // release lp token
            await lpToken.mint(bnMantissa(10000), { from: root })
            await lpToken.approve(Lockdrop.address, MAX_UINT_256, { from: root })
            await Lockdrop.releaseLPToken(bnMantissa(10000), { from: root })

            await expectRevert(Lockdrop.withdrawLPTokens({ from: userA }), 'Lock period did not ended yet.')
            await expectRevert(Lockdrop.withdrawLPTokens({ from: randomUser }), 'No withdrawable Token.')

            // 2. UserA Withdraw LP Token 
            // right now  : startTime + 5 days  + 3 min
            // user A Locked 1 month, so locking should end at : startTime + 5 days + LOCK_1_MONTHS
            await time.increase(time.duration.seconds(LOCK_1_MONTHS - 240)) // startTime + 5days + LOCK_1_MONTHS + 3 min - 4 min
            await expectRevert(Lockdrop.withdrawLPTokens({ from: userA }), 'Lock period did not ended yet.')

            await time.increase(time.duration.seconds(120))

            let userInfo = await Lockdrop.depositOf(userA)
            let userAmount = userInfo[0];
            const totalLPTokenAmount = await Lockdrop.totalLPTokenSupply();
            const totalDeposit = await Lockdrop.totalDeposit();
            console.log('totalLPTokenSupply : ', totalLPTokenAmount.toString())
            let expectedLpAmount = totalLPTokenAmount.mul(userAmount).div(totalDeposit)
            console.log('user A expectedLpAmount : ', expectedLpAmount.toString());

            expectEqual(userInfo[5], false) // isLPTokensClaimed

            let receipt = await Lockdrop.withdrawLPTokens({ from: userA })
            expectEvent(receipt, 'LPTokenClaimed', {
                user: userA,
                amount: (await lpToken.balanceOf(userA))
            })
            expectAlmostEqualMantissa(expectedLpAmount, await lpToken.balanceOf(userA))

            // User B lock period is 3 months.
            await expectRevert(Lockdrop.withdrawLPTokens({ from: userB }), 'Lock period did not ended yet.')

            userInfo = await Lockdrop.depositOf(userA)
            expectEqual(userInfo[5], true) // isLPTokensClaimed

            // 3. UserB Withdraw LP Token After 2 months 

            await time.increase(time.duration.seconds(LOCK_1_MONTHS * 2)) // after two months 
            userInfo = await Lockdrop.depositOf(userB)
            userAmount = userInfo[0];
            expectedLpAmount = totalLPTokenAmount.mul(userAmount).div(totalDeposit)
            console.log('user B expectedLpAmount : ', expectedLpAmount.toString());


            receipt = await Lockdrop.withdrawLPTokens({ from: userB })
            expectEvent(receipt, 'LPTokenClaimed', {
                user: userB,
                amount: (await lpToken.balanceOf(userB))
            })
            expectAlmostEqualMantissa(expectedLpAmount, await lpToken.balanceOf(userB))
            userInfo = await Lockdrop.depositOf(userB)
            expectEqual(userInfo[5], true) // isLPTokensClaimed
        })
    })
});