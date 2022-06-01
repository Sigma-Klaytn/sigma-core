// const {
//     makeErc20Token,
//     makeKSPConverter,
//     makeMockVotingKSP,
//     MockERC20,
//     MockVotingKSP,
//     KSPConverter
// } = require('./Utils/Sigma');

// const {
//     expectAlmostEqualMantissa,
//     expectRevert,
//     expectEvent,
//     bnMantissa,
//     BN,
//     expectEqual
// } = require('./Utils/JS');

// const oneMantissa = new BN(10).pow(new BN(18));
// const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

// contract('KSPConverter', function (accounts) {
//     describe('KSP Converter test.', () => {
//         let user = accounts[0];
//         let kspToken;
//         let mockVotingKSP;
//         let kspConverter;

//         before(async () => {
//             console.log(
//                 'Prepare for tests... available account count : ',
//                 accounts.length
//             );

//             //Deploy now
//             kspToken = await makeErc20Token();
//             mockVotingKSP = await makeMockVotingKSP(kspToken.address);
//             kspConverter = await makeKSPConverter(
//                 kspToken.address,
//                 mockVotingKSP.address
//             );

//             console.log('mockVotingKSP Contract : ', mockVotingKSP.address);
//             console.log('kspToken Token : ', kspToken.address);
//             console.log('kspConverter address : ', kspConverter.address);
//         });

//         it(`Mints ERC20 token to contract`, async () => {
//             let receipt = await kspToken.mint(bnMantissa(100), { from: user });

//             expectEvent(receipt, 'Transfer', {
//                 value: bnMantissa(100),
//                 to: user
//             });

//             expectEqual(await kspToken.balanceOf(user), bnMantissa(100));
//         });

//         it(`Deposit KSP to KSPConverter contract`, async () => {
//             //1. Approve KSP token to kspConverter
//             await kspToken.approve(kspConverter.address, MAX_UINT_256, {
//                 from: user
//             });

//             //2. Deposit KSP to kspConverter. 1 means 1 KSP.
//             let receipt = await kspConverter.depositKSP(1);

//             expectEvent(receipt, 'DepositKSP', {
//                 amount: bnMantissa(1),
//                 depositer: user
//             });

//             expectEqual(await kspToken.balanceOf(kspConverter.address), 0);
//         });

//         it(`Check User's KSP balance and sigKSP balance`, async () => {
//             //1. Check User's KSP balance
//             expectEqual(await kspToken.balanceOf(user), bnMantissa(99));

//             //2. Check User's sigKSP balance
//             expectEqual(await kspConverter.balanceOf(user), bnMantissa(8));
//         });

//         it(`Check KSPConverter's vKSP Balance`, async () => {
//             expectEqual(
//                 await mockVotingKSP.balanceOf(kspConverter.address),
//                 bnMantissa(8)
//             );
//             expectEqual(await kspToken.balanceOf(kspConverter.address), 0);
//         });
//     });
// });
