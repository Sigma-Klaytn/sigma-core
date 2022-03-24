const {
    makeErc20Token,
    makeDepositingVault,
    makeVault,
    makeKSPVault,
    MockERC20,
    DepositingVault,
    Vault,
    KSPVault
} = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN
} = require('../Utils/JS');

const IVotingKSP = artifacts.require('IVotingKSP');
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

const oneMantissa = new BN(10).pow(new BN(18));

contract('KSPVault', function (accounts) {
    console.log(accounts.length);
    let user = accounts[0];

    describe('KSP Vault function test.', () => {
        let kspVault;
        let votingKSP;
        let erc20Token;

        let KSP;
        let vKSP;

        const vKSPAddress = '0x2f3713f388bc4b8b364a7a2d8d57c5ff4e054830';
        const KSPAddress = '0xc6a2ad8cc6e4a7e08fc37cc5954be07d499e7654';

        before(async () => {
            console.log(accounts.length);

            console.log('Prepare for tests...');
            // kspVault = await makeKSPVault(
            //     '0x2F3713F388BC4b8b364a7A2d8D57c5Ff4E054830'
            // );
            kspVault = await KSPVault.at(
                '0xd36Ea386CddFa64104e1341eF788390D90F00077'
            );

            //lockedKSP function 있는 KSPVault 0xab64562EDdD508995cbCC90e8103847729D94903
            votingKSP = await IVotingKSP.at(
                '0x2F3713F388BC4b8b364a7A2d8D57c5Ff4E054830'
            );

            KSP = await MockERC20.at(KSPAddress);
            vKSP = await MockERC20.at(vKSPAddress);

            console.log(
                'KSP total supply : ',
                (await KSP.totalSupply()).toString()
            );
            console.log(
                'vKSP total supply : ',
                new BN(await vKSP.totalSupply()).toString()
            );

            console.log('kspVault address :', kspVault.address);
        });

        // it(`Mints ERC20 token to contract`, async () => {
        //     console.log(user, ' !!! ', user2);
        //     await erc20Token.mint(bnMantissa(200), { from: user });
        //     await erc20Token.transfer(kspVault.address, bnMantissa(10), {
        //         from: user
        //     });
        // });

        it(`Check Klay balance`, async () => {
            // await token.balanceOf();
            console.log(
                'user vKSP balance',
                (await vKSP.balanceOf(user)).toString()
            );
            console.log(
                'user KSP balance',
                (await KSP.balanceOf(user)).toString()
            );
        });

        it(`tranfer KSP`, async () => {
            console.log(
                `before kspVault ksp balance`,
                (await KSP.balanceOf(kspVault.address)).toString()
            );

            // await KSP.transfer(kspVault.address, bnMantissa(1), { from: user });

            console.log(
                `after kspVault ksp balance`,
                (await KSP.balanceOf(kspVault.address)).toString()
            );

            console.log(
                'user KSP balance',
                (await KSP.balanceOf(user)).toString()
            );
        });

        it(`lock balance`, async () => {
            // await kspVault.approveToken(
            //     KSP.address,
            //     '0x2F3713F388BC4b8b364a7A2d8D57c5Ff4E054830',
            //     MAX_UINT_256
            // );
            //lock 할 때 정수만 받음

            console.log(
                `before kspVault ksp balance`,
                (await KSP.balanceOf(kspVault.address)).toString()
            );

            // await KSP.transfer(kspVault.address, bnMantissa(1), { from: user });

            console.log(
                `after kspVault ksp balance`,
                (await KSP.balanceOf(kspVault.address)).toString()
            );

            console.log(
                `after vkspVault ksp balance`,
                (await vKSP.balanceOf(kspVault.address)).toString()
            );

            console.log(
                'locked user ksp',
                (await votingKSP.lockedKSP(user)).toString()
            );

            console.log(
                'locked user kspVault',
                (await votingKSP.lockedKSP(kspVault.address)).toString()
            );

            //[case 1]] EOA
            // let receipt = await votingKSP.lockKSP(1, 1555200000, {
            //     from: user
            // });

            // console.log('22222', receipt2);

            //[case ]] CA
            // let receipt = await kspVault.lockKSP(1, 1555200000, { from: user });

            // console.log(
            //     'locked user lockckjlafsdjls;fj;laskdf',
            //     (await kspVault.lockedKSP(user)).toString()
            // );

            // console.log('11111', receipt);
        });
    });
});
