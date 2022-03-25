const {
    makeErc20Token,
    MockERC20,
    MockVotingKSP,
    makeMockVotingKSP
} = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual
} = require('../Utils/JS');

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

contract('MockVotingKSP', function (accounts) {
    let user = accounts[0];

    describe('Mock KSP VotingKSP.sol', () => {
        let kspToken;
        let mockVotingKSP;

        before(async () => {
            console.log('Prepare for tests... ', accounts.length);

            //Deploy now
            kspToken = await makeErc20Token();
            mockVotingKSP = await makeMockVotingKSP(kspToken.address);

            console.log('mockVotingKSP Contract : ', mockVotingKSP.address);
            console.log('kspToken Token : ', kspToken.address);
        });

        it(`Mints KSP token to user`, async () => {
            let receipt = await kspToken.mint(bnMantissa(200), { from: user });

            expectEvent(receipt, 'Transfer', {
                value: bnMantissa(200),
                to: user
            });

            expectEqual(await kspToken.balanceOf(user), bnMantissa(200));
        });

        it(`Deposit KSP to vault`, async () => {
            await kspToken.approve(mockVotingKSP.address, MAX_UINT_256, {
                from: user
            });

            let receipt = await mockVotingKSP.lockKSP(1, 31104000, {
                from: user
            });

            expectEvent(receipt, 'LockedToken', {
                user: user,
                amount: bnMantissa(1),
                lockPeriodRequested: new BN(31104000)
            });

            expectEqual(await kspToken.balanceOf(user), bnMantissa(199));
            expectEqual(await mockVotingKSP.balanceOf(user), bnMantissa(8));
        });
    });
});
