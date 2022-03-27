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
        //--network baobab 이나 local 만 됨.
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

            sigKSPToken = await makeErc20Token(); //Staking token
            SIGToken = await makeErc20Token(); //Reward 1
            KSPToken = await makeErc20Token(); //Reward 2

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
            expectEqual(await sigKSPStaking.owner(), address(0));

            //4. check if there are two reward token.
            expectEqual(await sigKSPStaking.rewardTokens(0), SIGToken.address);
            expectEqual(await sigKSPStaking.rewardTokens(1), KSPToken.address);

            //5. check if sigKSPToken is reward token.
            expectEqual(
                await sigKSPStaking.stakingToken(),
                sigKSPToken.address
            );
        });

        it('sigKSP Staking contract retreive SIGToken and KSPToken', async () => {
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

        it('UserA and userB get sigKSP tokens.', async () => {
            //1. Mint 100 sigKSP to UserA
            //2. Mint 200 sigKSP to UserB
        });
    });
});
