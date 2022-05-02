const {
    makeErc20Token,
    makeVxSIGToken,
    makeXSIGFarm,
    makeLpFarm,
    xSIGFarm,
    vxSIGToken,
    MockERC20,
    LpFarm,
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

/**
 * [Check Point]
 * 0. Set Initial Info (Admin)
 * 1. Add pool / Set pool (Admin)
 * 2. Fund (Anyone)
 * 3. Deposit (User)
 * 4. Claim(User)
 * 5. Withdraw (User)
 * 6. setRewardPerBlock (Admin)
 *
 * <View Function>
 * 1. pool length
 * 2. pending reward 
 * 3. deposited
 * 
 * <Boost Reward>
 * 1. update boost weight
 */

// [CAUTION]
// --network :  You should run this code below in local environment since expectEvent doesn't work on Klaytn testnet for now.


contract('LpFarm', function (accounts) {
    let root = accounts[0];
    let userA = accounts[1];
    let userB = accounts[2];
    let userC = accounts[3];

    let vxSIGToken;
    let sigToken;
    let lpFarm;
    let lpTokenA;
    let lpTokenB;

    let initalTokenAirdropAmount = bnMantissa(100)
    let startBlockNum;
    let rewardPerBlock;

    console.log(
        'Prepare for tests... available account count : ',
        accounts.length
    );

    describe('Test : 0.SetInitialInfo', () => {

        before(async () => {

            // [Test Scenario]
            // 1. Reward per block : 100 SIG 
            // 2. Pool Count : 2
            //                        BASE      |    BOOST      ||     TOTAL 
            // 2-1) Pool A  :      20              60               80  
            // 2-2) Pool B  :      10              10               20


            //Deploy from the start.
            vxSIGToken = await makeVxSIGToken();
            lpFarm = await makeLpFarm();
            lpTokenA = await makeErc20Token();
            lpTokenB = await makeErc20Token();
            sigToken = await makeErc20Token();


            // [Caution] Set vxSIGToken operator to root. 
            //  It is only operated by xSIGFarm in production.
            await vxSIGToken.setOperator([root])

            //Fund lp Token A / lp Token B
            await lpTokenA.mint(initalTokenAirdropAmount, { from: userA });
            await lpTokenA.mint(initalTokenAirdropAmount, { from: userB });
            await lpTokenA.mint(initalTokenAirdropAmount, { from: userC });
            await lpTokenB.mint(initalTokenAirdropAmount, { from: userA });
            await lpTokenB.mint(initalTokenAirdropAmount, { from: userB });
            await lpTokenB.mint(initalTokenAirdropAmount, { from: userC });
        });

        it('Test : 0.SetInitialInfo', async () => {
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            startBlockNum = new BN(currentBlockNum).add(new BN(30));
            console.log("startBlockNum block number : ", startBlockNum.toString());
            rewardPerBlock = bnMantissa(100);

            // 1. Check onlyOwner Function 
            await expectRevert(lpFarm.setInitialInfo(sigToken.address, vxSIGToken.address, rewardPerBlock, startBlockNum, { from: userA }), 'Ownable: caller is not the owner')

            // 2. Check if Initial Info has been set. 
            await lpFarm.setInitialInfo(sigToken.address, vxSIGToken.address, rewardPerBlock, startBlockNum, { from: root })            // expectEqual(await xSIGFarm.generationRate(), new BN(3888888888888));
            expectEqual(await lpFarm.rewardPerBlock(), rewardPerBlock);
            expectEqual(await lpFarm.sig(), sigToken.address);
            expectEqual(await lpFarm.vxSIG(), vxSIGToken.address);
            expectEqual(await lpFarm.startBlock(), startBlockNum);
            expectEqual(await lpFarm.endBlock(), startBlockNum);
        });

        it('Test : 1.Add Pool / Set pool', async () => {
            // 1. Check Reverts
            await expectRevert(lpFarm.addPool(new BN(10), new BN(70), lpTokenA.address, { from: userA }), 'Ownable: caller is not the owner');

            // 2. Add Two Pool 
            const tx1 = await lpFarm.addPool(new BN(10), new BN(70), lpTokenA.address, { from: root })
            const tx2 = await lpFarm.addPool(new BN(10), new BN(10), lpTokenB.address, { from: root })

            expectEvent(tx1, "PoolAdded", {
                lpToken: lpTokenA.address,
                pid: new BN(0)
            })

            expectEvent(tx2, "PoolAdded", {
                lpToken: lpTokenB.address,
                pid: new BN(1)
            })
            // 3. Check Pool info
            expectEqual(await lpFarm.baseTotalAllocPoint(), new BN(20));
            expectEqual(await lpFarm.boostTotalAllocPoint(), new BN(80));
            expectEqual(await lpFarm.totalAllocPoint(), new BN(100));

            let poolInfoA = await lpFarm.poolInfo(new BN(0));
            let poolInfoB = await lpFarm.poolInfo(new BN(1));

            // Token Address
            expectEqual(poolInfoA[0], lpTokenA.address);
            expectEqual(poolInfoB[0], lpTokenB.address);

            // Allo Point
            expectEqual(poolInfoA[1], new BN(10));
            expectEqual(poolInfoB[1], new BN(10));

            // Last Reward Blcok
            console.log("Pool A Last Reward Block : ", poolInfoA[2].toString());
            console.log("Pool B Last Reward Block : ", poolInfoB[2].toString());

            //accERC20PerShare
            expectEqual(poolInfoA[3], new BN(0));
            expectEqual(poolInfoB[3], new BN(0));

            //boostAllocPoint 
            expectEqual(poolInfoA[4], new BN(70));
            expectEqual(poolInfoB[4], new BN(10));

            // Last Reward Blcok
            console.log("Pool A Boost Last Reward Block : ", poolInfoA[5].toString());
            console.log("Pool B Boost Last Reward Block : ", poolInfoB[5].toString());

            //boostAccERC20PerShare
            expectEqual(poolInfoA[6], new BN(0));
            expectEqual(poolInfoB[6], new BN(0));

            //totalBoostWeight
            expectEqual(poolInfoA[7], new BN(0));
            expectEqual(poolInfoB[7], new BN(0));

            // LpFarm total Alloc Point 
            expectEqual(await lpFarm.totalAllocPoint(), new BN(100))

            //Lp Farm Total Base, Boost Alloc Point
            expectEqual(await lpFarm.baseTotalAllocPoint(), new BN(20));
            expectEqual(await lpFarm.boostTotalAllocPoint(), new BN(80));


            // 4. Set Pool Info
            // Check Reverts
            await expectRevert(lpFarm.setPool(new BN(0), new BN(20), new BN(60), { from: userA }), 'Ownable: caller is not the owner');

            // re-set pool info
            await lpFarm.setPool(new BN(0), new BN(20), new BN(60), { from: root });

            // 5. Re-check pool info

            // LpFarm total Alloc Point 
            expectEqual(await lpFarm.totalAllocPoint(), new BN(100))

            //Lp Farm Total Base, Boost Alloc Point
            expectEqual(await lpFarm.baseTotalAllocPoint(), new BN(30));
            expectEqual(await lpFarm.boostTotalAllocPoint(), new BN(70));

            poolInfoA = await lpFarm.poolInfo(new BN(0));
            expectEqual(poolInfoA[1], new BN(20));
            expectEqual(poolInfoA[4], new BN(60));

        })

        it('Test : 2. Fund', async () => {
            //1. Check Revert
            await expectRevert(lpFarm.fund(new BN(0), { from: userA }), 'Funding amount should be bigger than 0');


            //2. Fund SIG to userA
            let fundingAmount = bnMantissa(100 * 1000); // This will 1000 block for reward.
            await sigToken.mint(fundingAmount, { from: root });
            sigToken.approve(lpFarm.address, MAX_INT256, { from: root });

            let tx = await lpFarm.fund(fundingAmount, { from: root })
            let expectedEndBlock = startBlockNum.add(fundingAmount.div(rewardPerBlock));

            expectEvent(tx, "Funded", {
                from: root,
                amount: fundingAmount,
                newEndBlock: expectedEndBlock
            })

            console.log("Expected End Block : ", expectedEndBlock);

            //3. Check Contract Balance
            let balance = await sigToken.balanceOf(lpFarm.address);
            expectEqual(balance, fundingAmount);

        })

        it('Test : 3. Deposit', async () => {
            // [Deposit Scenario]
            // 1. Pool A 
            // 1-1). User A deposits 40 LP Token    
            // 1-2). User B deposits 20 LP Token
            // 1-3). User A deposits 60 LP Token 
            // 2. Pool B 
            // 2-1). User C deposits 50 LP Token
            // 2-2). User A deposits 10 LP Token 

            // 0. Mine First, Set the timeline after the startBlock.
            for (let i = 0; i < 30; i++) {
                evmMine();
            }

            // 1. Pool A
            let oldPoolInfo = await lpFarm.poolInfo(new BN(0));
            let oldAccERC20PerShare = oldPoolInfo[3];
            let oldLastRewardBlock = oldPoolInfo[2];
            let allocPoint = oldPoolInfo[1];

            // User A Deposit Token & Apporve lpTokenA to lpFarm contract
            await lpTokenA.approve(lpFarm.address, MAX_INT256, { from: userA });
            let currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            let receipt = await lpFarm.deposit(new BN(0), bnMantissa(40), { from: userA });

            expectEvent(receipt, "Deposit", {
                user: userA,
                pid: new BN(0),
                amount: bnMantissa(40)
            })

            let newPoolInfo = await lpFarm.poolInfo(new BN(0));
            let newAccERC20PerShare = newPoolInfo[3];
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())

            expectEqual(newAccERC20PerShare, new BN(0));

            // User B Deposit Token & Apporve lpTokenA to lpFarm contract
            await lpTokenA.approve(lpFarm.address, MAX_INT256, { from: userB });
            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            receipt = await lpFarm.deposit(new BN(0), bnMantissa(20), { from: userB });

            expectEvent(receipt, "Deposit", {
                user: userB,
                pid: new BN(0),
                amount: bnMantissa(20)
            })

            newPoolInfo = await lpFarm.poolInfo(new BN(0));
            newAccERC20PerShare = newPoolInfo[3];
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())
            console.log("userA base pending  : ", (await lpFarm.basePending(new BN(0), userA)).toString())

            // expectEqual(newAccERC20PerShare, new BN(0));

            // 1-3) User A Deposit More Token 
            // Chek User Info 
            let oldUserInfo = await lpFarm.userInfo(new BN(0), userA)
            let oldUserASigBalance = await sigToken.balanceOf(userA)
            let oldAmount = oldUserInfo[0]
            let oldRewardDebt = oldUserInfo[1]

            console.log(oldUserASigBalance.toString(), "   ", oldAmount.toString(), "   ", oldRewardDebt.toString())

            currentBlockNum = (await web3.eth.getBlockNumber()).toString()
            console.log("current block number : ", currentBlockNum.toString());
            receipt = await lpFarm.deposit(new BN(0), bnMantissa(60), { from: userA });

            expectEvent(receipt, "Deposit", {
                user: userA,
                pid: new BN(0),
                amount: bnMantissa(60)
            })

            expectEqual(bnMantissa(120), await lpTokenA.balanceOf(lpFarm.address))


            let newUserInfo = await lpFarm.userInfo(new BN(0), userA)
            let newUserASigBalance = await sigToken.balanceOf(userA)
            let newAmount = newUserInfo[0]
            let newRewardDebt = newUserInfo[1]

            console.log(newUserASigBalance.toString(), "   ", newAmount.toString(), "   ", newRewardDebt.toString())

            newPoolInfo = await lpFarm.poolInfo(new BN(0));
            newAccERC20PerShare = newPoolInfo[3];
            console.log("newAccERC20PerShare : ", newAccERC20PerShare.toString())
            console.log("userA base pending  : ", (await lpFarm.basePending(new BN(0), userA)).toString())

            // 2. Pool B 
            // User C Deposit Token & Apporve lpTokenB to lpFarm contract
            await lpTokenB.approve(lpFarm.address, MAX_INT256, { from: userC });
            receipt = await lpFarm.deposit(new BN(1), bnMantissa(50), { from: userC });

            expectEvent(receipt, "Deposit", {
                user: userC,
                pid: new BN(1),
                amount: bnMantissa(50)
            })

            // User A Deposit Token & Apporve lpTokenB to lpFarm contract
            await lpTokenB.approve(lpFarm.address, MAX_INT256, { from: userA });
            receipt = await lpFarm.deposit(new BN(1), bnMantissa(10), { from: userA });

            expectEvent(receipt, "Deposit", {
                user: userA,
                pid: new BN(1),
                amount: bnMantissa(10)
            })

            expectEqual(bnMantissa(60), await lpTokenB.balanceOf(lpFarm.address))
            newPoolInfo = await lpFarm.poolInfo(new BN(1));
            newAccERC20PerShare = newPoolInfo[3];
            console.log("pool B newAccERC20PerShare : ", newAccERC20PerShare.toString())
        })

        it('Test : 4. Use Boost', async () => {
            // 0. Fund vxSIGToken worth 100
            await vxSIGToken.mint(userA, bnMantissa(100), { from: root }); // 100 vxSIG
            await vxSIGToken.mint(userB, bnMantissa(50), { from: root }); // 50 vxSIG 

            // 1. User A Update boost weight 

            // Check before
            let oldPoolAInfo = await lpFarm.poolInfo(new BN(0));
            let oldPoolBInfo = await lpFarm.poolInfo(new BN(1));
            console.log('oldPoolAInfo : totalBoostWeight  -> ', oldPoolAInfo[7].toString())
            console.log('oldPoolBInfo : totalBoostWeight  -> ', oldPoolBInfo[7].toString())

            //Update Boost Weight 
            await lpFarm.updateBoostWeight({ from: userA });

            let newPoolAInfo = await lpFarm.poolInfo(new BN(0));
            let newPoolBInfo = await lpFarm.poolInfo(new BN(1));
            console.log('newPoolAInfo : totalBoostWeight  -> ', newPoolAInfo[7].toString())
            console.log('newPoolBInfo : totalBoostWeight  -> ', newPoolBInfo[7].toString())
            expectEqual(newPoolAInfo[7], (await lpFarm.userInfo(new BN(0), userA))[3])
            expectEqual(newPoolBInfo[7], (await lpFarm.userInfo(new BN(1), userA))[3])


            // 2. User B Update Boost weight 
            //Update Boost Weight 
            await lpFarm.updateBoostWeight({ from: userB });

            let userB_newPoolAInfo = await lpFarm.poolInfo(new BN(0));
            let userB_newPoolBInfo = await lpFarm.poolInfo(new BN(1));
            console.log('newPoolAInfo : totalBoostWeight  -> ', userB_newPoolAInfo[7].toString())
            console.log('newPoolBInfo : totalBoostWeight  -> ', userB_newPoolBInfo[7].toString())
            // Pool A should be added with the amount of weight of userB

            expectEqual(userB_newPoolAInfo[7], (new BN(newPoolAInfo[7].toString())).add((await lpFarm.userInfo(new BN(0), userB))[3]))
            // Since user b never deposited in pool B, pool b total Boost weight should be the same.
            expectEqual(userB_newPoolBInfo[7], newPoolBInfo[7])


            // 3. User B lose all vxSIG and update boost weight.
            await vxSIGToken.burn(userB, bnMantissa(50), { from: root }); // 100 vxSIG
            expectEqual(await vxSIGToken.balanceOf(userB), new BN(0));

            //Update Boost Weight 
            await lpFarm.updateBoostWeight({ from: userB });

            userB_newPoolAInfo = await lpFarm.poolInfo(new BN(0));
            userB_newPoolBInfo = await lpFarm.poolInfo(new BN(1));
            console.log('newPoolAInfo : totalBoostWeight  -> ', userB_newPoolAInfo[7].toString())
            console.log('newPoolBInfo : totalBoostWeight  -> ', userB_newPoolBInfo[7].toString())

            expectEqual(newPoolAInfo[7], userB_newPoolAInfo[7]);
            expectEqual(newPoolBInfo[7], userB_newPoolBInfo[7]);

            // 4. User A add more vxSIG and update boost weight. 
            //Fund vxSIGToken worth 100
            await vxSIGToken.mint(userA, bnMantissa(100), { from: root }); // 100 vxSIG
            await lpFarm.updateBoostWeight({ from: userA });

            // 5. User B add more vxSIG and udpate boost weight
            await vxSIGToken.mint(userB, bnMantissa(40), { from: root }); // 100 vxSIG
            await lpFarm.updateBoostWeight({ from: userB });


        })

        it('Test : 5. Claim', async () => {
            // [Current Deposit & Boost Scenario]
            // 1. Pool A 
            // 1-1). User A deposits 100 LP Token     (Total 200 vxSIG Boost)
            // 1-2). User B deposits 20 LP Token     (Total 40 vxSIG Boost)
            // 2. Pool B 
            // 2-1). User C deposits 50 LP Token    (Total 0 vxSIG Boost)
            // 2-2). User A deposits 10 LP Token    (Total 200 vxSIG Boost)

            // 1. Pool A 
            // 1-1) Check Total Boost Weights 
            let poolAUserAInfo = await lpFarm.userInfo(new BN(0), userA)
            let poolAUserBInfo = await lpFarm.userInfo(new BN(0), userB)
            let poolBUserAInfo = await lpFarm.userInfo(new BN(1), userA)
            let poolBUserBInfo = await lpFarm.userInfo(new BN(1), userB)
            let poolAInfo = await lpFarm.poolInfo(new BN(0))
            let poolBInfo = await lpFarm.poolInfo(new BN(1))

            expectEqual(poolAInfo[7], poolAUserAInfo[3].add(poolAUserBInfo[3]))
            expectEqual(poolBInfo[7], poolBUserAInfo[3])

            // 1-2) User A Claim for the SIG 
            evmMine();
            let basePending = await lpFarm.basePending(new BN(0), userA)
            let boostPending = await lpFarm.boostPending(new BN(0), userA)

            console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())

            let beforeBalance = await sigToken.balanceOf(userA)
            let tx = await lpFarm.claim(new BN(0), { from: userA });
            let afterBalance = await sigToken.balanceOf(userA)

            expectEvent(tx, "Claim", {
                user: userA,
                pid: new BN(0),
                amount: afterBalance.sub(beforeBalance)
            })

            basePending = await lpFarm.basePending(new BN(0), userA)
            boostPending = await lpFarm.boostPending(new BN(0), userA)

            console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())

            // Check reverts. User C didn't deposit on pool A 
            await expectRevert(lpFarm.claim(new BN(0), { from: userC }), 'User didn\'t deposit in this pool.')


            // This for loops are to check if it has right amount of reward. 
            for (let ia = 0; ia < 10; ia++) {
                evmMine();
                let basePending = await lpFarm.basePending(new BN(0), userA)
                let boostPending = await lpFarm.boostPending(new BN(0), userA)

                console.log('user A base pending : ', basePending.toString(), '  boost pending : ', boostPending.toString())
            }

            for (let ia = 0; ia < 10; ia++) {
                evmMine();
                let userBbasePending = await lpFarm.basePending(new BN(0), userB)
                let userBBoostPending = await lpFarm.boostPending(new BN(0), userB)
                console.log('user Bbase pending : ', userBbasePending.toString(), '  boost pending : ', userBBoostPending.toString())
            }

        })

        it('Test : 6. Withdraw', async () => {

            // 1. User A withdraw all of the lpToken A from Pool A
            // If the all lp Token is withdrawn, user's boostWeight should be zero and should be deducted from totalBoostWeight of the pool.

            let userAPoolADepositedAmount = (await lpFarm.userInfo(new BN(0), userA))[0]
            let userASigBalance = await sigToken.balanceOf(userA);
            let userAPoolABoostWeight = (await lpFarm.userInfo(new BN(0), userA))[3]
            let poolTotalBoostWeight = (await lpFarm.poolInfo(new BN(0)))[7]
            console.log('userAPoolADepositedAmount : ', userAPoolADepositedAmount.toString())
            console.log('userASigBalance : ', userASigBalance.toString())
            console.log('userAPoolABoostWeight : ', userAPoolABoostWeight.toString())
            console.log('poolTotalBoostWeight : ', poolTotalBoostWeight.toString())

            let tx = await lpFarm.withdraw(new BN(0), userAPoolADepositedAmount, { from: userA })
            expectEvent(tx, "Withdraw", {
                user: userA,
                pid: new BN(0),
                amount: userAPoolADepositedAmount
            })

            let afterUserAPoolADepositedAmount = (await lpFarm.userInfo(new BN(0), userA))[0]
            let afterUserASigBalance = await sigToken.balanceOf(userA);
            let afterUserAPoolABoostWeight = (await lpFarm.userInfo(new BN(0), userA))[3]
            let afterPoolTotalBoostWeight = (await lpFarm.poolInfo(new BN(0)))[7]
            console.log('after userAPoolADepositedAmount : ', afterUserAPoolADepositedAmount.toString())
            console.log(' after userASigBalance : ', afterUserASigBalance.toString())
            console.log('after userAPoolABoostWeight : ', afterUserAPoolABoostWeight.toString())
            console.log('after poolTotalBoostWeight : ', afterPoolTotalBoostWeight.toString())

            expectEqual(afterUserAPoolABoostWeight, new BN(0));
            expectEqual(afterUserAPoolADepositedAmount, new BN(0));
            expectEqual(afterPoolTotalBoostWeight, poolTotalBoostWeight.sub(userAPoolABoostWeight));


            // 2. UserB withdraw lpToken A partially from Pool A 
            // If lp token is still remained, user's boostWeight and totalBoostWeight of the pool should be updated. 
            let userBPoolADepositedAmount = (await lpFarm.userInfo(new BN(0), userB))[0]
            let userBSigBalance = await sigToken.balanceOf(userB);
            let userBPoolABoostWeight = (await lpFarm.userInfo(new BN(0), userB))[3]
            let poolTotalBoostWeight_2 = (await lpFarm.poolInfo(new BN(0)))[7]
            console.log('userBPoolADepositedAmount : ', userBPoolADepositedAmount.toString())
            console.log('userBSigBalance : ', userBSigBalance.toString())
            console.log('userBPoolABoostWeight : ', userBPoolABoostWeight.toString())
            console.log('poolTotalBoostWeight : ', poolTotalBoostWeight_2.toString())

            tx = await lpFarm.withdraw(new BN(0), bnMantissa(10), { from: userB })
            expectEvent(tx, "Withdraw", {
                user: userB,
                pid: new BN(0),
                amount: bnMantissa(10)
            })

            let afteruserBPoolADepositedAmount = (await lpFarm.userInfo(new BN(0), userB))[0]
            let afteruserBSigBalance = await sigToken.balanceOf(userB);
            let afteruserBPoolABoostWeight = (await lpFarm.userInfo(new BN(0), userB))[3]
            let afterpoolTotalBoostWeight_2 = (await lpFarm.poolInfo(new BN(0)))[7]
            console.log('after userBPoolADepositedAmount : ', afteruserBPoolADepositedAmount.toString())
            console.log(' after userBSigBalance : ', afteruserBSigBalance.toString())
            console.log('after userBPoolABoostWeight : ', afteruserBPoolABoostWeight.toString())
            console.log('after poolTotalBoostWeight_2 : ', afterpoolTotalBoostWeight_2.toString())

            expectEqual(afteruserBPoolADepositedAmount, userBPoolADepositedAmount.sub(bnMantissa(10)));
            expectEqual(afterpoolTotalBoostWeight_2, afteruserBPoolABoostWeight);
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



