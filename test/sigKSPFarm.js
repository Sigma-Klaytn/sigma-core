const {
    makeErc20Token,
    makeVxSIGToken,
    makeSigKSPFarm,
    xSIGFarm,
    vxSIGToken,
    MockERC20,
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
const { BigNumber } = require('ethers');

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Fund (Anyone)
 * 2. Deposit (User)
 * 3. Claim(User)
 * 4. Withdraw (User)
 * 5. setRewardPerBlock (Admin)
 * 6. setBaseAndBoostAllocPoint (Admin)
 *
 * <View Function>
 * 1. pending reward 
 * 2. deposited
 * 
 * <Boost Reward>
 * 1. update boost weight
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.


contract('sigKSPFarm', function (accounts) {
    let root = accounts[0];
    let userA = accounts[1];
    let userB = accounts[2];
    let userC = accounts[3];

    let vxSIGToken;
    let sigToken;
    let sigKSPFarm;
    let sigKSP;

    let initalTokenAirdropAmount = bnMantissa(100)
    let startBlockNum;
    let rewardPerBlock;
    let boostAllocPoint;
    let baseAllocPoint;

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {
            // [Test Scenario]
            // 1. Reward per block : 100 SIG 
            // 2. Base / Boost Alloc  :    7 : 3 

            //Deploy from the start.
            vxSIGToken = await makeVxSIGToken();
            sigToken = await makeErc20Token();
            sigKSPToken = await makeErc20Token();
            sigKSPFarm = await makeSigKSPFarm();

            // set base / boost alloc
            baseAllocPoint = new BN(7);
            boostAllocPoint = new BN(3);

            // [Caution] Set vxSIGToken operator to root. 
            //  It is only operated by xSIGFarm in production.
            await vxSIGToken.setOperator([root])

            //Fund sigKSPToken
            await sigKSPToken.mint(initalTokenAirdropAmount, { from: userA });
            await sigKSPToken.mint(initalTokenAirdropAmount, { from: userB });
            await sigKSPToken.mint(initalTokenAirdropAmount, { from: userC });

        });

        it('Test : 0.SetInitialInfo', async () => {
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            startBlockNum = new BN(currentBlockNum).add(new BN(30));
            console.log("startBlockNum block number : ", startBlockNum.toString());
            rewardPerBlock = bnMantissa(100);

            // 1. Check onlyOwner Function 
            await expectRevert(sigKSPFarm.setInitialInfo(sigToken.address, sigKSPToken.address, vxSIGToken.address, rewardPerBlock, startBlockNum, baseAllocPoint, boostAllocPoint, { from: userA }), 'Ownable: caller is not the owner')

            // 2. Check if Initial Info has been set. 
            await sigKSPFarm.setInitialInfo(sigToken.address, sigKSPToken.address, vxSIGToken.address, rewardPerBlock, startBlockNum, baseAllocPoint, boostAllocPoint, { from: root })
            expectEqual(await sigKSPFarm.rewardPerBlock(), rewardPerBlock);
            expectEqual(await sigKSPFarm.sig(), sigToken.address);
            expectEqual(await sigKSPFarm.vxSIG(), vxSIGToken.address);
            expectEqual(await sigKSPFarm.startBlock(), startBlockNum);
            expectEqual(await sigKSPFarm.endBlock(), startBlockNum);
            expectEqual(await sigKSPFarm.totalBoostWeight(), new BN(0))
            expectEqual(await sigKSPFarm.totalAllocPoint(), baseAllocPoint.add(boostAllocPoint))
            expectEqual(await sigKSPFarm.sigKSP(), sigKSPToken.address)
        });


        it('Test : 1. Fund', async () => {
            //1. Check Revert
            await expectRevert(sigKSPFarm.fund(new BN(0), { from: userA }), 'Funding amount should be bigger than 0');


            //2. Fund SIG to userA
            let fundingAmount = bnMantissa(100 * 1000); // This will 1000 block for reward.
            await sigToken.mint(fundingAmount, { from: root });
            sigToken.approve(sigKSPFarm.address, MAX_INT256, { from: root });

            let tx = await sigKSPFarm.fund(fundingAmount, { from: root })
            let expectedEndBlock = startBlockNum.add(fundingAmount.div(rewardPerBlock));

            expectEvent(tx, "Funded", {
                from: root,
                amount: fundingAmount,
                newEndBlock: expectedEndBlock
            })

            console.log("Expected End Block : ", expectedEndBlock.toString());
            //3. Check Contract Balance
            let balance = await sigToken.balanceOf(sigKSPFarm.address);
            expectEqual(balance, fundingAmount);

        })

        it('Test : 3. Deposit', async () => {
            // [Deposit Scenario]
            // 1-1). User A deposits 40 sigKSP Token    
            // 1-2). User B deposits 20 sigKSP Token
            // 1-3). User A deposits 60 sigKSP Token 

            // 0. Mine First, Set the timeline after the startBlock.
            for (let i = 0; i < 30; i++) {
                evmMine();
            }

            // 1. save info first 
            let oldAccERC20PerShare = await sigKSPFarm.accERC20PerShare();
            let oldLastRewardBlock = await sigKSPFarm.lastRewardBlock();
            let allocPoint = await sigKSPFarm.baseAllocPoint();

            // User A Deposit Token & Apporve lpTokenA to sigKSPFarm contract
            await sigKSPToken.approve(sigKSPFarm.address, MAX_INT256, { from: userA });
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            let receipt = await sigKSPFarm.deposit(bnMantissa(40), { from: userA });

            expectEvent(receipt, "Deposit", {
                user: userA,
                amount: bnMantissa(40)
            })

            let newAccERC20PerShare = await sigKSPFarm.accERC20PerShare();
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())

            expectEqual(newAccERC20PerShare, new BN(0));

            // User B Deposit Token & Apporve sigKSP Token to sigKSPFarm contract
            await sigKSPToken.approve(sigKSPFarm.address, MAX_INT256, { from: userB });
            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            receipt = await sigKSPFarm.deposit(bnMantissa(20), { from: userB });

            expectEvent(receipt, "Deposit", {
                user: userB,
                amount: bnMantissa(20)
            })

            newAccERC20PerShare = await sigKSPFarm.accERC20PerShare();
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())
            console.log("userA base pending  : ", (await sigKSPFarm.basePending(userA)).toString())

            // expectEqual(newAccERC20PerShare, new BN(0));

            // 1-3) User A Deposit More Token 
            // Check User Info 
            let oldUserInfo = await sigKSPFarm.userInfo(userA)
            let oldUserASigBalance = await sigToken.balanceOf(userA)
            let oldAmount = oldUserInfo[0]
            let oldRewardDebt = oldUserInfo[1]

            console.log(oldUserASigBalance.toString(), "   ", oldAmount.toString(), "   ", oldRewardDebt.toString())

            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            receipt = await sigKSPFarm.deposit(bnMantissa(60), { from: userA });

            expectEvent(receipt, "Deposit", {
                user: userA,
                amount: bnMantissa(60)
            })

            expectEqual(bnMantissa(120), await sigKSPToken.balanceOf(sigKSPFarm.address))

            let newUserInfo = await sigKSPFarm.userInfo(userA)
            let newUserASigBalance = await sigToken.balanceOf(userA)
            let newAmount = newUserInfo[0]
            let newRewardDebt = newUserInfo[1]

            console.log(newUserASigBalance.toString(), "   ", newAmount.toString(), "   ", newRewardDebt.toString())

            newAccERC20PerShare = await sigKSPFarm.accERC20PerShare();
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())
            console.log("userA base pending  : ", (await sigKSPFarm.basePending(userA)).toString())

        })

        it('Test : 4. Use Boost', async () => {
            // 0. Fund vxSIGToken worth 100
            await vxSIGToken.mint(userA, bnMantissa(100), { from: root }); // 100 vxSIG
            await vxSIGToken.mint(userB, bnMantissa(50), { from: root }); // 50 vxSIG 

            // 1. User A Update boost weight 

            // Check before
            let oldTotalBoostWeight = await sigKSPFarm.totalBoostWeight();
            console.log('oldTotalBoostWeight : totalBoostWeight  -> ', oldTotalBoostWeight.toString())

            //Update Boost Weight 
            await sigKSPFarm.updateBoostWeight({ from: userA });

            let newTotalBoostWeight = await sigKSPFarm.totalBoostWeight();
            console.log('newTotalBoostWeight : totalBoostWeight  -> ', newTotalBoostWeight.toString())
            expectEqual(newTotalBoostWeight, (await sigKSPFarm.userInfo(userA))[3])

            // 2. User B Update Boost weight 
            //Update Boost Weight 
            await sigKSPFarm.updateBoostWeight({ from: userB });

            let newTotalBoostWeight2 = await sigKSPFarm.totalBoostWeight();
            console.log('newTotalBoostWeight2 : totalBoostWeight  -> ', newTotalBoostWeight2.toString())

            // Pool A should be added with the amount of weight of userB
            expectEqual(newTotalBoostWeight2, newTotalBoostWeight.add((await sigKSPFarm.userInfo(userB))[3]))

            // // 3. User B lose all vxSIG and update boost weight.
            await vxSIGToken.burn(userB, bnMantissa(50), { from: root }); // 100 vxSIG
            expectEqual(await vxSIGToken.balanceOf(userB), new BN(0));

            // //Update Boost Weight 
            await sigKSPFarm.updateBoostWeight({ from: userB });

            let newTotalBoostWeight3 = await sigKSPFarm.totalBoostWeight();
            console.log('after B Boost gone zero : totalBoostWeight  -> ', newTotalBoostWeight3.toString())

            expectEqual(newTotalBoostWeight3, newTotalBoostWeight)

            // // 4. User A add more vxSIG and update boost weight. 
            //Fund vxSIGToken worth 100
            await vxSIGToken.mint(userA, bnMantissa(100), { from: root }); // 100 vxSIG
            await sigKSPFarm.updateBoostWeight({ from: userA });

            // 5. User B add more vxSIG and udpate boost weight
            await vxSIGToken.mint(userB, bnMantissa(40), { from: root }); // 100 vxSIG
            await sigKSPFarm.updateBoostWeight({ from: userB });

            console.log('userA boost weight :  ', ((await sigKSPFarm.userInfo(userA))[3]).toString())
            console.log('userB boost weight :  ', ((await sigKSPFarm.userInfo(userB))[3]).toString())
            console.log('total boost weight : ', (await sigKSPFarm.totalBoostWeight()).toString())
        })

        it('Test : 5. Claim', async () => {
            // [Current Deposit & Boost Scenario]
            // 1-1). User A deposits 100 sigKSP Token   (Total 200 vxSIG Boost , 141.4 weight)
            // 1-2). User B deposits 20 sigKSP Token     (Total 40 vxSIG Boost , 28.28 weight)


            // 1. Pool A 
            // 1-1) Check Total Boost Weights 
            let userAInfo = await sigKSPFarm.userInfo(userA)
            let userBInfo = await sigKSPFarm.userInfo(userB)

            expectEqual(await sigKSPFarm.totalBoostWeight(), userAInfo[3].add(userBInfo[3]))

            // 1-2) User A Claim for the SIG 
            evmMine();
            let basePending = await sigKSPFarm.basePending(userA)
            let boostPending = await sigKSPFarm.boostPending(userA)

            console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())

            let beforeBalance = await sigToken.balanceOf(userA)
            let tx = await sigKSPFarm.claim({ from: userA });
            let afterBalance = await sigToken.balanceOf(userA)

            expectEvent(tx, "Claim", {
                user: userA,
                amount: afterBalance.sub(beforeBalance)
            })

            basePending = await sigKSPFarm.basePending(userA)
            boostPending = await sigKSPFarm.boostPending(userA)

            console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())

            // Check reverts. User C didn't deposit on pool A 
            await expectRevert(sigKSPFarm.claim({ from: userC }), 'User didn\'t deposit in this pool.')


            // This for loops are to check if it has right amount of reward. 
            for (let ia = 0; ia < 10; ia++) {
                evmMine();
                let basePending = await sigKSPFarm.basePending(userA)
                let boostPending = await sigKSPFarm.boostPending(userA)

                console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())
            }

            for (let ia = 0; ia < 10; ia++) {
                evmMine();
                let userBbasePending = await sigKSPFarm.basePending(userB)
                let userBBoostPending = await sigKSPFarm.boostPending(userB)
                console.log('user Bbase pending : ', userBbasePending.toString(), '  boost pending : ', userBBoostPending.toString())
            }

        })

        it('Test : 6. Withdraw', async () => {

            // 1. User A withdraw all of the sigKSP from Pool A
            // If the all lp Token is withdrawn, user's boostWeight should be zero and should be deducted from totalBoostWeight of the pool.
            let userADepositedAmount = (await sigKSPFarm.userInfo(userA))[0]
            let userASigBalance = await sigToken.balanceOf(userA);
            let userABoostWeight = (await sigKSPFarm.userInfo(userA))[3]
            let totalBoostWeight = await sigKSPFarm.totalBoostWeight()
            console.log('userADepositedAmount : ', userADepositedAmount.toString())
            console.log('userASigBalance : ', userASigBalance.toString())
            console.log('userABoostWeight : ', userABoostWeight.toString())
            console.log('totalBoostWeight : ', totalBoostWeight.toString())

            // check reverts
            await expectRevert(sigKSPFarm.withdraw(userADepositedAmount.add(new BN(1)), { from: userA }), "withdraw: can\'t withdraw more than deposit")

            let tx = await sigKSPFarm.withdraw(userADepositedAmount, { from: userA })
            expectEvent(tx, "Withdraw", {
                user: userA,
                amount: userADepositedAmount
            })

            let afterUserADepositedAmount = (await sigKSPFarm.userInfo(userA))[0]
            let afterUserASigBalance = await sigToken.balanceOf(userA);
            let afterUserABoostWeight = (await sigKSPFarm.userInfo(userA))[3]
            let afterTotalBoostWeight = await sigKSPFarm.totalBoostWeight()
            console.log(' afterUserADepositedAmount : ', afterUserADepositedAmount.toString())
            console.log(' afterUserASigBalance : ', afterUserASigBalance.toString())
            console.log(' afterUserABoostWeight : ', afterUserABoostWeight.toString())
            console.log(' afterTotalBoostWeight : ', afterTotalBoostWeight.toString())

            expectEqual(afterUserABoostWeight, new BN(0));
            expectEqual(afterUserADepositedAmount, new BN(0));
            expectEqual(afterTotalBoostWeight, totalBoostWeight.sub(userABoostWeight));


            // // 2. UserB withdraw sigKSP Token partially from the contract
            // // If sigKSP Token is still remained, user's boostWeight and totalBoostWeight of the pool should be updated. 
            let userBDepositedAmount = (await sigKSPFarm.userInfo(userB))[0]
            let userBSigBalance = await sigToken.balanceOf(userB);
            let userBBoostWeight = (await sigKSPFarm.userInfo(userB))[3]
            let totalBoostWeight_2 = await sigKSPFarm.totalBoostWeight()
            console.log('userDepositedAmount : ', userBDepositedAmount.toString())
            console.log('userBSigBalance : ', userBSigBalance.toString())
            console.log('userBBoostWeight : ', userBBoostWeight.toString())
            console.log('totalBoostWeight_2 : ', totalBoostWeight_2.toString())

            tx = await sigKSPFarm.withdraw(bnMantissa(10), { from: userB })
            expectEvent(tx, "Withdraw", {
                user: userB,
                amount: userBDepositedAmount.sub(bnMantissa(10))
            })

            let afteruserBDepositedAmount = (await sigKSPFarm.userInfo(userB))[0]
            let afteruserBSigBalance = await sigToken.balanceOf(userB);
            let afteruserBBoostWeight = (await sigKSPFarm.userInfo(userB))[3]
            let afterTotalBoostWeight_2 = await sigKSPFarm.totalBoostWeight()
            console.log(' afteruserBDepositedAmount : ', afteruserBDepositedAmount.toString())
            console.log('  userBSigBalance : ', afteruserBSigBalance.toString())
            console.log(' afteruserBABoostWeight : ', afteruserBBoostWeight.toString())
            console.log(' afterTotalBoostWeight_2 : ', afterTotalBoostWeight_2.toString())

            expectEqual(afteruserBDepositedAmount, userBDepositedAmount.sub(bnMantissa(10)));
            expectEqual(afterTotalBoostWeight_2, afteruserBBoostWeight);
        })
    })
});


function evmMine() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_mine",
            id: new Date().getTime()
        }, (error, result) => {
            if (error) {
                return reject(error);
            }
            return resolve(result);
        });
    });
};



