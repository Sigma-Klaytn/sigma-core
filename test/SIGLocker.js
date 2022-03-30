const {
    makeErc20Token,
    makeSIGLocker,
    SIGLocker,
    MockERC20
} = require('./Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual
} = require('./Utils/JS');

const { address } = require('./Utils/Ethereum');
const { user } = require('firebase-functions/lib/providers/auth');
const { time } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

//1. lock
//2. extendLock
//3. initiateExitStream
//4. withdrawExitStream
//5. streamableBalance
//6. claimableExitStreamBalance

contract('SIGLocker', function (accounts) {
    describe('SIGLocker Staking Test.', () => {
        //--network baobab 이나 local 만 테스트 가능.
        let userA = accounts[0];
        let userB = accounts[1];

        let SIGToken;
        let SIGLocker;

        const WEEK = 604800;
        let startWeek;

        before(async () => {
            console.log(
                'Prepare for tests... available account count : ',
                accounts.length
            );
            console.log('Deploy Token and Logic smart contract');

            //Deploy from the start.
            SIGToken = await makeErc20Token(); //Locking Token
            SIGLocker = await makeSIGLocker(16, SIGToken.address, {
                from: userA
            });

            //Use deployed one. (baobab)
            // SIGToken = await MockERC20.at(
            //     '0x14e8C9052ae53b6e26aC3953E7C31Ec5cC2eEE13'
            // ); //Locking Token

            console.log('SIGToken : ', SIGToken.address);
            console.log('\n\n------------- [start test case] ----------\n\n');
        });

        it('check start time and make it speed up to week 3', async () => {
            let startTime = new BN(await SIGLocker.startTime());
            startWeek = startTime / WEEK;
            console.log('start Time', startTime.toString());
            expectEqual(await SIGLocker.getWeek(), 0);
            await time.increase(time.duration.weeks(2));
            expectEqual(await SIGLocker.getWeek(), 2);
        });

        it('mint SIGToken to user and approve to smart contract', async () => {
            await SIGToken.mint(bnMantissa(100), { from: userA });
            await SIGToken.mint(bnMantissa(200), { from: userB });

            await SIGToken.approve(SIGLocker.address, MAX_UINT_256, {
                from: userA
            });
            await SIGToken.approve(SIGLocker.address, MAX_UINT_256, {
                from: userB
            });
        });

        it('should revert when lock() require condition fails', async () => {
            await expectRevert(
                SIGLocker.lock(userA, bnMantissa(100), 0),
                'Minimum lock week is 1'
            );

            await expectRevert(
                SIGLocker.lock(userA, bnMantissa(100), 100),
                'Exceeds MAX_LOCK_WEEKS'
            );

            await expectRevert(
                SIGLocker.lock(userA, 0, 10),
                'Amount must be bigger than 0'
            );

            // Run code below if you are running on testnet,
            // since Error message doesn't work on Klaytn testnet.

            // await expectRevert.unspecified(
            //     SIGLocker.lock(userA, bnMantissa(100), 0)
            // );
            // await expectRevert.unspecified(
            //     SIGLocker.lock(userA, bnMantissa(100), 100)
            // );
            // await expectRevert.unspecified(SIGLocker.lock(userA, 0, 10));
        });

        it('lock SIG token and update user weight', async () => {
            const lockWeeks = 5;

            const currentWeek = parseInt(await SIGLocker.getWeek());
            console.log(`currentWeek : ${currentWeek.toString()}`);

            let receipt = await SIGLocker.lock(
                userA,
                bnMantissa(100),
                new BN(lockWeeks)
            );

            // Check if userWeight and totalWeigh is right.
            for (let i = 0; i < lockWeeks; i++) {
                console.log(
                    'User Weekly Weigh Of Week',
                    currentWeek + i,
                    ' : ',
                    new BN(
                        await SIGLocker.weeklyWeightOf(userA, currentWeek + i)
                    ).toString()
                );

                expectEqual(
                    await SIGLocker.weeklyWeightOf(userA, currentWeek + i),
                    bnMantissa(100 * (lockWeeks - i))
                );

                expectEqual(
                    await SIGLocker.weeklyTotalWeight(currentWeek + i),
                    bnMantissa(100 * (lockWeeks - i))
                );
            }

            //check weeklyUnlocksOf[_user][end] is equal to bnMantissa(100)
            expectEvent(receipt, 'NewLock', {
                user: userA,
                amount: bnMantissa(100),
                lockWeeks: new BN(lockWeeks)
            });
        });

        it('should revert when extendLock() require condition fails', async () => {
            await expectRevert(
                SIGLocker.extendLock(bnMantissa(100), 0, 3),
                'Minimum lock week is 1'
            );

            await expectRevert(
                SIGLocker.extendLock(bnMantissa(100), 2, 17),
                'Exceeds MAX_LOCK_WEEKS'
            );

            await expectRevert(
                SIGLocker.extendLock(bnMantissa(100), 3, 1),
                'newWeeks must be greater than weeks'
            );
            await expectRevert(
                SIGLocker.extendLock(0, 3, 10),
                'Amount must be bigger than 0'
            );
        });
        it('extend Lock', async () => {
            //extend Lock to 5 weeks to 8 weeks

            //1. check if weeklyUnlockOf[msg.sender][getWeek()+oldWeeks] equal bnMantissa(100)
            const oldWeeks = 5;
            const newWeeks = 8;

            expectEqual(
                await SIGLocker.weeklyUnlocksOf(
                    userA,
                    +(await SIGLocker.getWeek()) + +oldWeeks
                ),
                bnMantissa(100)
            );

            // //2. Extend Lock
            let receipt = await SIGLocker.extendLock(
                bnMantissa(100),
                oldWeeks,
                newWeeks
            );

            //3.WeeklyUnlocksOf User on OldWeek should be 0, NewWeek Should be bnMantica
            expectEqual(
                await SIGLocker.weeklyUnlocksOf(
                    userA,
                    +(await SIGLocker.getWeek()) + +oldWeeks
                ),
                bnMantissa(0)
            );

            expectEqual(
                await SIGLocker.weeklyUnlocksOf(
                    userA,
                    +(await SIGLocker.getWeek()) + +newWeeks
                ),
                bnMantissa(100)
            );

            expectEvent(receipt, 'ExtendLock', {
                user: userA,
                amount: bnMantissa(100),
                oldWeeks: new BN(oldWeeks),
                newWeeks: new BN(newWeeks)
            });
        });

        it('initiateExitStream', async () => {
            /**
             * [Let's say..]
             * 1. Currently 100 token is locked for 8 weeks.
             * 2. Lock 200 token for 3 weeks.
             * 3. Lock 400 token for 4 weeks.
             * 4. Time elapses 5 weeks later.
             */

            await SIGToken.mint(bnMantissa(600), { from: userA });
            await SIGLocker.lock(userA, bnMantissa(200), 3, { from: userA });
            await SIGLocker.lock(userA, bnMantissa(400), 4, { from: userA });

            /**
             * [Check Point]
             * 1. Time elpases to 2 weeks later. initiateExitStream() should revert since there is no streamableBalance.
             * 2. Time elapses to 3 weeks later. (total jump to 5 weeks adding to prev step) initiateExitStream() should work with the total amount of 600 token.
             */

            // [Check Point 1]
            await time.increase(time.duration.weeks(2)); // Increase time.
            console.log(
                '2 weeks Later... \n Current Week : ',
                (await SIGLocker.getWeek()).toString()
            );
            await expectRevert(
                SIGLocker.initiateExitStream({ from: userA }),
                'No withdrawable balance'
            );

            // [Check Point 2]
            await time.increase(time.duration.weeks(3));

            const currentWeek = await SIGLocker.getWeek();
            console.log(
                '3 weeks Later... \n Current Week : ',
                currentWeek.toString()
            );
            // check streamable balance
            const streamableAmount = await SIGLocker.streamableBalance(userA, {
                from: userA
            });
            expectEqual(streamableAmount, bnMantissa(600));

            // check withdrawn until to be 0 sinde

            let receipt = await SIGLocker.initiateExitStream({ from: userA });

            expectEvent(receipt, 'NewExitStream', {
                user: userA,
                amount: streamableAmount
            });
        });

        it('withdrawExitStream', async () => {
            /**
             * [Let's say..]
             * 1. Exit Stream already initiated.
             *  exitStream[userA] : {start : block.timestamp , amount : bnMantissa(600), claimed : 0}
             */

            /**
             * [Check Point]
             * 1. Time elpases to 1 days later. exitStream amount of SIG will be partially claimed since the withdrawnUntil week hasn't passed yet.
             * 2. Time elapses to 1 weeks later. exitStream remained amount will be fully claimed since the withdrawnUntil week already has passed.
             */

            // [ Check Point 1 ]
            await time.increase(time.duration.days(1)); // Increase time.

            let oldExitStream = await SIGLocker.exitStream(userA);
            let receipt = await SIGLocker.withdrawExitStream({ from: userA });
            let newExitStream = await SIGLocker.exitStream(userA);

            expect(oldExitStream[2] < newExitStream[2]).to.be.ok;
            expectEqual(await SIGToken.balanceOf(userA), newExitStream[2]);

            console.log(
                '[ Check Point 1 ] userA SIG Token balance : ',
                (await SIGToken.balanceOf(userA)).toString()
            );

            // [ Check Point 2 ]
            await time.increase(time.duration.weeks(1)); // Increase time.

            oldExitStream = await SIGLocker.exitStream(userA);
            receipt = await SIGLocker.withdrawExitStream({ from: userA });
            newExitStream = await SIGLocker.exitStream(userA);

            // exitStream has been deleted. so newExitStream shouldn't be exist.
            expectEqual(newExitStream[0], 0);
            expectEqual(await SIGToken.balanceOf(userA), oldExitStream[1]);

            console.log(
                '[ Check Point 2 ] userA SIG Token balance : ',
                (await SIGToken.balanceOf(userA)).toString()
            );
        });
    });
});
