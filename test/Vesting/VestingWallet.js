const { makeErc20Token, MockERC20, VestingWallet, makeVestingWallet } = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN,
    expectEqual,
    time
} = require('../Utils/JS');

const oneMantissa = new BN(10).pow(new BN(18));
const MAX_UINT_256 = new BN(2).pow(new BN(256)).sub(new BN(1));

/**
 * [Check Point]
 * 0. Create Contract & transfer ownership
 * 1. Check Owner 
 * 2. fund sig (without function)
 * 3. release(token)
 * 4. setBeneficiaryAddress (onlyOwner function)
 *
 * <View Function>
 * 1. View public Variables
 * 2. View crucial current Status
 *    1) vestedAmount(address token, uint64 timestamp)
 *    2) beneficiary()
 *    3) start()
 *    4) duration()
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.

contract('VestingWallet', function (accounts) {
    let root = accounts[0];
    let receiver = accounts[1]; // Admin address who gets KSP at the end of phase2.
    let newReceiver = accounts[2];

    let SIGToken;
    let VestingWallet;
    let currentTime;


    const WEEK = 604800;
    const DAY = 60 * 60 * 24;
    const HOUR = 3600;
    const MINUTE = 60;

    const vestingAmount = bnMantissa(30 * 86400) // 1초에 1SIG 씩이라고 생각하면 됨. 
    const vestingPeriod = new BN((30 * DAY).toString());

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test Start', () => {

        before(async () => {
            currentTime = parseInt(await time.latest());

            //Deploy from the start.
            SIGToken = await makeErc20Token();
            VestingWallet = await makeVestingWallet(receiver, currentTime + DAY, vestingPeriod);


            await SIGToken.mint(vestingAmount, { from: root });
        });

        it('Test 1 : Create Contract & transfer ownership', async () => {

            expectEqual(await VestingWallet.owner(), receiver);

            expectEqual(await VestingWallet.beneficiary(), receiver);
            expectEqual(await VestingWallet.start(), new BN(currentTime + DAY));
            expectEqual(await VestingWallet.duration(), vestingPeriod);

            console.log('start time : ', (await VestingWallet.start()).toString())

            // 1. check revert
            // no releaseable amount to claim 
            await expectRevert(VestingWallet.release(SIGToken.address), "No releasable amount of token.")

        });

        it('Test 2 : Fund Vesting wallet', async () => {
            // approve sig to vesting wallet contrat

            await SIGToken.approve(VestingWallet.address, vestingAmount, { from: root })

            // send sig to contract
            await SIGToken.transfer(VestingWallet.address, vestingAmount);

            // check if vestedAmount is 0 before start() time. 
            let now = parseInt(await time.latest())

            console.log('Current time after fund : ', now.toString())

            expectEqual(await VestingWallet.vestedAmount(SIGToken.address, new BN(now)), new BN(0))


        })

        it('Test 3 : release token', async () => {
            // 2. check released  = 0
            expectEqual(await VestingWallet.released(), new BN(0))

            // 3. increase time 
            // increase time to after start. 
            await time.increase(time.duration.days(1))
            now = parseInt(await time.latest())

            console.log('Current time after time passed by 1 day : ', now.toString())

            // check vested amount 
            console.log('vested amount : ', (await VestingWallet.vestedAmount(SIGToken.address, new BN(now))).toString())

            // 4. release token 
            let receipt = await VestingWallet.release(SIGToken.address)
            let beneficiaryBalance = await SIGToken.balanceOf(receiver)
            expectEvent(receipt, "ERC20Released", {
                token: SIGToken.address,
                amount: beneficiaryBalance
            })

        })

        it('Test 4 : Set New Beneficiary', async () => {
            // 1. check revert 
            await expectRevert(VestingWallet.setBeneficiaryAddress(newReceiver, { from: root }), "Ownable: caller is not the owner");
            await expectRevert(VestingWallet.setBeneficiaryAddress("0x0000000000000000000000000000000000000000", { from: receiver }), "VestingWallet: beneficiary is zero address")

            // 2. Set new beneficiary 
            await VestingWallet.setBeneficiaryAddress(newReceiver, { from: receiver })

            expectEqual(await VestingWallet.owner(), newReceiver);
            expectEqual(await VestingWallet.beneficiary(), newReceiver);

            let beforePrevReceiverBalance = await SIGToken.balanceOf(receiver)
            let beforeNewReceiverBalance = await SIGToken.balanceOf(newReceiver)

            await time.increase(time.duration.days(1))
            console.log('vested amount : ', (await VestingWallet.vestedAmount(SIGToken.address, new BN(now))).toString())

            let receipt = await VestingWallet.release(SIGToken.address)
            let afterPrevReceiverBalance = await SIGToken.balanceOf(receiver)
            let afterNewReceiverBalance = await SIGToken.balanceOf(newReceiver)

            expectEvent(receipt, "ERC20Released", {
                token: SIGToken.address,
                amount: afterNewReceiverBalance
            })

            expectEqual(beforePrevReceiverBalance, afterPrevReceiverBalance);
        })
    })
});