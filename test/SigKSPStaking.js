const {
    makeErc20Token,
    makeSigKSPStaking,
    MockERC20,
    SigKSPStaking
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

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

contract('SigKSPStaking', function (accounts) {
    describe('SigKSP Staking Test.', () => {
        //--network baobab 이나 local 만 테스트 가능.
        let userA = accounts[0];
        let userB = accounts[1];

        let sigKSPToken;
        let SIGToken;
        let KSPToken;

        let sigKSPStaking;

        before(async () => {
            console.log(
                'Prepare for tests... available account count : ',
                accounts.length
            );
            console.log('Deploy Token and Logic smart contract');

            //Deploy from the start.
            // sigKSPToken = await makeErc20Token(); //Staking token
            // SIGToken = await makeErc20Token(); //Reward 1
            // KSPToken = await makeErc20Token(); //Reward 2

            //Use deployed one. (baobab)
            sigKSPToken = await MockERC20.at(
                '0x68C8fD98ba4C958FaD3011fc632DE2bc912C46db'
            ); //Staking token
            SIGToken = await MockERC20.at(
                '0x14e8C9052ae53b6e26aC3953E7C31Ec5cC2eEE13'
            ); //Reward 1
            KSPToken = await MockERC20.at(
                '0xe41CE2a5dfb9f9B17500De284Ac98A51e03676eA'
            ); //Reward 2

            console.log('sigKSPToken : ', sigKSPToken.address);
            console.log('SIGToken : ', SIGToken.address);
            console.log('KSPToken : ', KSPToken.address);
            console.log('\n\n------------- [start test case] ----------\n\n');
        });

        it('Owner set sigKSPStaking Contract', async () => {
            //1. userA deploy contract.
            sigKSPStaking = await makeSigKSPStaking({ from: userA });

            //2. userA set staking token and reward token.
            await sigKSPStaking.setAddresses(sigKSPToken.address, [
                SIGToken.address,
                KSPToken.address
            ]);

            //3. check if there is no ownership after setAdddress.
            expectEqual(await sigKSPStaking.owner(), userA);

            //4. check if there are two reward token.
            expectEqual(await sigKSPStaking.rewardTokens(0), SIGToken.address);
            expectEqual(await sigKSPStaking.rewardTokens(1), KSPToken.address);

            //5. check if sigKSPToken is reward token.
            expectEqual(
                await sigKSPStaking.stakingToken(),
                sigKSPToken.address
            );
        });

        it('sigKSP Staking contract collect SIGToken and KSPToken', async () => {
            //1. Mint tokens to userA
            await SIGToken.mint(bnMantissa(100), { from: userA });
            await KSPToken.mint(bnMantissa(2000), { from: userA });

            //2. Transfer token to sigKSPStaking contract
            await SIGToken.transfer(sigKSPStaking.address, bnMantissa(100), {
                from: userA
            });
            await KSPToken.transfer(sigKSPStaking.address, bnMantissa(2000), {
                from: userA
            });

            //3. Check the balance.
            expectEqual(
                await SIGToken.balanceOf(sigKSPStaking.address),
                bnMantissa(100)
            );
            expectEqual(
                await KSPToken.balanceOf(sigKSPStaking.address),
                bnMantissa(2000)
            );
        });

        it('Update Reward Amount', async () => {
            //Revert Reason is detectable only on --network development,
            //if you are testing on klaytn testnet, user expectRevert.unspecified()

            // await expectRevert(
            //     sigKSPStaking.updateRewardAmount(),
            //     'Caller is not RewardsDistribution contract'
            // );

            // If setRewardsDistribution has not been set yet, it reverts.
            await expectRevert.unspecified(sigKSPStaking.updateRewardAmount());

            await sigKSPStaking.setRewardsDistribution(userA);

            let receipt = await sigKSPStaking.updateRewardAmount();

            expectEvent(receipt, 'RewardAdded', {
                rewardsToken: SIGToken.address,
                reward: bnMantissa(100)
            });

            expectEvent(receipt, 'RewardAdded', {
                rewardsToken: KSPToken.address,
                reward: bnMantissa(2000)
            });

            const SIGTokenRewardStruct = await sigKSPStaking.rewardData(
                SIGToken.address
            );

            const KSPTokenRewardStruct = await sigKSPStaking.rewardData(
                KSPToken.address
            );

            printReward(SIGTokenRewardStruct);
            printReward(KSPTokenRewardStruct);
        });

        it('UserA and userB mint sigKSP and stake it', async () => {
            //1. Mint 100 sigKSP to UserA and stake.
            await sigKSPToken.mint(bnMantissa(100), { from: userA });

            //approve first
            await sigKSPToken.approve(sigKSPStaking.address, MAX_UINT_256, {
                from: userA
            });

            let receipt = await sigKSPStaking.stake(bnMantissa(100), {
                from: userA
            });

            expectEvent(receipt, 'Staked', {
                user: userA,
                amount: bnMantissa(100)
            });

            let SIGTokenRewardStruct = await sigKSPStaking.rewardData(
                SIGToken.address
            );

            let KSPTokenRewardStruct = await sigKSPStaking.rewardData(
                KSPToken.address
            );

            // Just check SIG
            const rewardPerTokenStoredAfterUserAStake = SIGTokenRewardStruct[3];

            printReward(SIGTokenRewardStruct);
            printReward(KSPTokenRewardStruct);

            //2. Mint 200 sigKSP to UserB
            await sigKSPToken.mint(bnMantissa(200), { from: userB });

            //approve first
            await sigKSPToken.approve(sigKSPStaking.address, MAX_UINT_256, {
                from: userB
            });

            receipt = await sigKSPStaking.stake(bnMantissa(200), {
                from: userB
            });

            expectEvent(receipt, 'Staked', {
                user: userB,
                amount: bnMantissa(200)
            });

            SIGTokenRewardStruct = await sigKSPStaking.rewardData(
                SIGToken.address
            );

            KSPTokenRewardStruct = await sigKSPStaking.rewardData(
                KSPToken.address
            );

            printReward(SIGTokenRewardStruct);
            printReward(KSPTokenRewardStruct);

            //3. Check userA and userB userRewardPerTokenPaid
            // 3-1) userA's userRewardPerTokenPaid should be 0
            expectEqual(
                await sigKSPStaking.userRewardPerTokenPaid(
                    userA,
                    SIGToken.address
                ),
                0
            );
            // 3-1) userB's userRewardPerTokenPaid should be "rewardPerTokenStoredAfterUserAStake + pending"
            expect(
                (await sigKSPStaking.userRewardPerTokenPaid(
                    userB,
                    SIGToken.address
                )) > rewardPerTokenStoredAfterUserAStake
            ).to.be.ok;
        });

        it('userA claim reward', async () => {
            //Test with SIG Token.
            //1. Check user's SIG Balance.
            console.log(
                '[Before Claim] UserA SIG Token Balance : ',
                (await SIGToken.balanceOf(userA)).toString()
            );
            //2. Check user's Earned
            expectEqual(
                await sigKSPStaking.rewards(userA, SIGToken.address),
                0
            );
            let receipt = await sigKSPStaking.getReward({ from: userA });

            console.log(
                '[After Claim] UserA SIG Token Balance : ',
                (await SIGToken.balanceOf(userA)).toString()
            );
        });

        it('userB exit(withdraw)', async () => {
            //Test with KSP Token
            //1. Check user's KSP Balance.
            console.log(
                '[Before Claim] UserB KSP Token Balance : ',
                (await KSPToken.balanceOf(userB)).toString()
            );

            let receipt = await sigKSPStaking.exit({ from: userB });

            expectEvent(receipt, 'UpdateReward', {
                rewardToken: KSPToken.address,
                userRewardPerTokenPaid: (
                    await sigKSPStaking.rewardData(KSPToken.address)
                )[3]
            });

            expectEvent(receipt, 'Withdrawn', {
                user: userB
            });

            console.log(
                '[After Claim] UserB KSP Token Balance : ',
                (await KSPToken.balanceOf(userB)).toString()
            );
        });
    });
});

function printReward(rewardData) {
    console.log(
        `\t\t\tReward Data \t\t\t\t{\n period Finish : ${new BN(
            rewardData[0]
        ).toString()} \n\t\t\t\t rewardRate : ${new BN(
            rewardData[1]
        ).toString()}\n\t\t\t\t lastUpdateTime : ${new BN(
            rewardData[2]
        ).toString()}\n\t\t\t\t rewardPerTokenStored : ${new BN(
            rewardData[3]
        ).toString()}\n\t\t\t\t balance : ${new BN(rewardData[4]).toString()}`
    );
}
