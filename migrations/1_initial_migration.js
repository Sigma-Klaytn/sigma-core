const TOKEN_CONFIG = require('../token.js');
const { BN } = require('@openzeppelin/test-helpers');


function bnMantissa(n) {
    let den = 10e13;
    let num = Math.round(n * den);
    var len = Math.max(
        num.toString().length,
        den.toString().length,
        Math.round(Math.log10(num))
    );
    const MAX_LEN = 14;
    if (len > MAX_LEN) {
        num = Math.round(num / Math.pow(10, len - MAX_LEN));
        den = Math.round(den / Math.pow(10, len - MAX_LEN));
    }
    return new BN(1e9).mul(new BN(1e9)).mul(new BN(num)).div(new BN(den));
}

const UUPSProxy = artifacts.require("UUPSProxy");
const SIGFARM = artifacts.require("SigFarmV1")

let TREASURY = artifacts.require("TreasuryV1");
let FEE_DISTRIBUTOR = artifacts.require("FeeDistributorV1");
let KLAYSWAP_ESCORW = artifacts.require("KlayswapEscrowV1");
let SIGKSP_STAKING = artifacts.require("SigKSPStakingV1");
let SIG_FARM = artifacts.require("SigFarmV1");
let XSIG_FARM = artifacts.require("xSIGFarmV1");
let LOCKDROP_LPFARM_PROXY = artifacts.require("LockdropLpFarmProxyV1");
let XSIG_TOKEN = artifacts.require('xSIGToken');
let VXSIG_TOKEN = artifacts.require('VxSIGToken');
let SIGMA_VOTER = artifacts.require('SigmaVoterV1');

let SIGKSP_FARM = artifacts.require('SigKSPFarmV1')


// // TEST PURPOSE NEET TO DELETE AFTER TEST
// const LpFarmV3 = artifacts.require("LpFarmV3");
// const MockERC20 = artifacts.require("MockERC20")
// const SigmaToken = artifacts.require("SigmaToken");
// // END OF THEST PURPOSE

// CONST 값 : Deploy 전 꼭 확인

const sigKSPStaking_REWARD_DURATION = 172800; // 실제로는 2일로 바꿔야함
const sigFarm_LOCKING_PERIOD = 604800; // 실제로는 7일 
const sigmaVoter_USER_MAX_VOTE = 10;


//Klayswap 관련
const Factory_KSP = "0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654";
const PoolVoting = "0x71b59e4bc2995b57aa03437ed645ada7dd5b1890";
const VotingKSP_vKSP = "0x2f3713f388bc4b8b364a7a2d8d57c5ff4e054830";
const Utils = "0x7A74B3be679E194E1D6A0C29A343ef8D2a5AC876";
//(실제 deploy 때에는 oUSDT - SIG)
const oUSDT = "0xcee8faf64bb97a73bb51e115aa89c17ffa8dd167";


//Sigma Pre-deployed contract address
let SIG = "0x94a2a6308c0a3782d83ad590d82ff0ffcc515312";
let SIG_oUSDT_LP = "0xb821e4cc5b913f307db7d11d3360a6eb5b38bf9f";

// TODO: Test 용도로 직접 deploy 하여 사용 실제로는 아예 필요없는 값.
// let sigKSP_KSP_LP = "";

// TODO: Test 용도로 직접 deploy 하여 사용 .address 삭제
let LpFarm = "0xc6E648B0440DF716a09c13dc19fE8C3Aa6b44a0e";
// TODO: Test 용도로 직접 deploy 하여 사용 .address 삭제
let vxSIGToken = "0x8C132112e098AEcDD0d4eDCb6441A902f5b7908c";
let BOT_ACCOUNT = "0x3a7c4274d4e91299aF7e760a11F7A6Acf40D6BF4";
// 진짜 lockdrop
let Lockdrop = "0xF796253c5dEF51e34b3F5e201E09fAf8423B3322";


// Sigma Contract To be Deployed
let treasury;
let feeDistributor;
let klayswapEscrow;
let sigKSPStaking;
let sigFarm;
let xSIGFarm;
let lockdropLpFarmProxy;
let xSIGToken;
let sigmaVoter;

let sigKSPFarm;

let impl;

module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts();
    const owner = accounts[0];

    // // ==== TODO TEST PURPOSE NEET TO DELETE AFTER TEST ====

    // await deployer.deploy(MockERC20);
    // sigKSP_KSP_LP = await MockERC20.deployed();

    // await deployer.deploy(MockERC20);
    // SIG = await MockERC20.deployed();

    // await deployer.deploy(MockERC20);
    // SIG_oUSDT_LP = await MockERC20.deployed();


    // //lpFarmV3 
    // await deployer.deploy(LpFarmV3);
    // impl = await LpFarmV3.deployed()
    // await deployer.deploy(UUPSProxy, impl.address, "0x");
    // LpFarm = await LpFarmV3.at((await UUPSProxy.deployed()).address)


    // //vxSIG Token
    // await deployer.deploy(VXSIG_TOKEN)
    // vxSIGToken = await VXSIG_TOKEN.deployed()

    // // TODO: END OF THEST PURPOSE =================

    /**
     * [Table of deployment]
     * 1. Deploy all contract that are needed. 
     * 2. Initialize All
     * 3. setInitialInfo
     * 4. Extra setting for each of the contract.
     */

    try {
        // 1. Deploy all contarct that are needed.

        //Treasury 
        await deployer.deploy(TREASURY);
        impl = await TREASURY.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        treasury = await TREASURY.at((await UUPSProxy.deployed()).address)


        //FeeDistributor 
        await deployer.deploy(FEE_DISTRIBUTOR);
        impl = await FEE_DISTRIBUTOR.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        feeDistributor = await FEE_DISTRIBUTOR.at((await UUPSProxy.deployed()).address)

        //KlayswapEscorw 
        await deployer.deploy(KLAYSWAP_ESCORW);
        impl = await KLAYSWAP_ESCORW.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        klayswapEscrow = await KLAYSWAP_ESCORW.at((await UUPSProxy.deployed()).address)

        //sigKSPStakingV1 
        await deployer.deploy(SIGKSP_STAKING);
        impl = await SIGKSP_STAKING.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        sigKSPStaking = await SIGKSP_STAKING.at((await UUPSProxy.deployed()).address)

        //SIGFarmV1 
        await deployer.deploy(SIGFARM);
        impl = await SIGFARM.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        sigFarm = await SIGFARM.at((await UUPSProxy.deployed()).address)

        //xSIGFarm 
        await deployer.deploy(XSIG_FARM);
        impl = await XSIG_FARM.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        xSIGFarm = await XSIG_FARM.at((await UUPSProxy.deployed()).address)

        // LockdropLpFarmProxyV1
        await deployer.deploy(LOCKDROP_LPFARM_PROXY);
        impl = await LOCKDROP_LPFARM_PROXY.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        lockdropLpFarmProxy = await LOCKDROP_LPFARM_PROXY.at((await UUPSProxy.deployed()).address)

        // SigmaVoter 
        await deployer.deploy(SIGMA_VOTER);
        impl = await SIGMA_VOTER.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        sigmaVoter = await SIGMA_VOTER.at((await UUPSProxy.deployed()).address)

        // xSIG Token
        await deployer.deploy(XSIG_TOKEN)
        xSIGToken = await XSIG_TOKEN.deployed()

        // sigKSPFarm 
        await deployer.deploy(SIGKSP_FARM)
        impl = await SIGKSP_FARM.deployed()
        await deployer.deploy(UUPSProxy, impl.address, "0x");
        sigKSPFarm = await SIGKSP_FARM.at((await UUPSProxy.deployed()).address)
    } catch (e) {
        console.log(e)
        console.log("sig address ", SIG);
        console.log("SIG_oUSDT_LP address ", SIG_oUSDT_LP);
        console.log("LpFarm address ", LpFarm);
        console.log("vxSIGToken address ", vxSIGToken);


        console.log("treasury address ", treasury.address);
        console.log("feeDistributor address ", feeDistributor.address);
        console.log("klayswapEscrow address ", klayswapEscrow.address);
        console.log("sigKSPStaking address ", sigKSPStaking.address);
        console.log("sigFarm address ", sigFarm.address);
        console.log("xSIGFarm address ", xSIGFarm.address);
        console.log("lockdropLpFarmProxy address ", lockdropLpFarmProxy.address);
        console.log("sigmaVoter address ", sigmaVoter.address);

        console.log("xSIGToken address ", xSIGToken.address);

        console.log("sigKSPFarm address ", sigKSPFarm.address);

    }


    console.log("sig address ", SIG);
    console.log("SIG_oUSDT_LP address ", SIG_oUSDT_LP);
    console.log("LpFarm address ", LpFarm);
    console.log("vxSIGToken address ", vxSIGToken);


    console.log("treasury address ", treasury.address);
    console.log("feeDistributor address ", feeDistributor.address);
    console.log("klayswapEscrow address ", klayswapEscrow.address);
    console.log("sigKSPStaking address ", sigKSPStaking.address);
    console.log("sigFarm address ", sigFarm.address);
    console.log("xSIGFarm address ", xSIGFarm.address);
    console.log("lockdropLpFarmProxy address ", lockdropLpFarmProxy.address);
    console.log("sigmaVoter address ", sigmaVoter.address);

    console.log("xSIGToken address ", xSIGToken.address);

    console.log("sigKSPFarm address ", sigKSPFarm.address);



    // // Sigma Contract To be Deployed
    // treasury = await TREASURY.at("0x70857f694D6e7A3569c8Bfb4b0BD78130C8c4211")
    // feeDistributor = await FEE_DISTRIBUTOR.at("0x47B58457eb305E8bdc50aa09D66bDcFa3eFda540")
    // klayswapEscrow = await KLAYSWAP_ESCORW.at("0x6026c432c420dce0E7Bc5f84b9Df1637B9CE953b")
    // sigKSPStaking = await SIGKSP_STAKING.at("0x20B36ed48754C92860166BbAB4Fc5376Ca10A932")
    // sigFarm = await SIGFARM.at("0xE1Bf4B5BF7aBb40a5a0F9334Ed1B482ab8A3E13b")
    // xSIGFarm = await XSIG_FARM.at("0x206430E1800A6db49F2eABf9645f5C6fFf8F66B9")
    // lockdropLpFarmProxy = await LOCKDROP_LPFARM_PROXY.at("0x354f9f52bE59E30c5958b465E0e42998B17602e5")
    // xSIGToken = await XSIG_TOKEN.at("0x84F1898EA932E3428FA6EF447928567B98Db8BAc")
    // sigmaVoter = await SIGMA_VOTER.at("0x7190251B690795908a3794AEbA49eE1E6EbFC126")
    // sigKSPFarm = await SIGKSP_FARM.at("0xdc37Cec80cB4c53A070fBA765Ef7A3c80B97f730")


    // weird log is because of the weird of Klaytn's error.

    // 2. Initialize all upgradeable smart contract 

    await treasury.initialize()
    await feeDistributor.initialize()
    console.log('  d ')

    await klayswapEscrow.initialize()
    await sigKSPStaking.initialize()
    console.log('  o ')

    await sigFarm.initialize()
    await xSIGFarm.initialize()
    console.log('  n ')

    await lockdropLpFarmProxy.initialize()
    await sigmaVoter.initialize()
    console.log('  3 ')

    await sigKSPFarm.initialize()


    console.log('  done ')

    // 3. Set initialInfo

    // 1. Treasury
    // TODO : CHANGE THIS TO SIG-oUSDT 
    await treasury.setInitialInfo(SIG_oUSDT_LP)
    console.log('  done 1')


    // 2. FeeDistributor
    await feeDistributor.setInitialInfo(sigKSPStaking.address, treasury.address, sigFarm.address, Factory_KSP, SIG_oUSDT_LP, oUSDT, SIG, Factory_KSP)
    await feeDistributor.setOperator([BOT_ACCOUNT])

    console.log('  done 2')


    // 3. KlayswapEscrow
    await klayswapEscrow.setInitialInfo(Factory_KSP, oUSDT, VotingKSP_vKSP, PoolVoting, sigmaVoter.address, Factory_KSP, feeDistributor.address)
    await klayswapEscrow.setOperator([BOT_ACCOUNT, owner])

    console.log('  done 3')

    for (const [key, value] of Object.entries(TOKEN_CONFIG.TOKEN)) {
        console.log('approve token', value);
        if (key !== "KLAY") {
            await klayswapEscrow.approveToken(value.toString(), Factory_KSP)
        }
    }


    console.log('  done 4')


    // 4. SigKSP Staking 
    await sigKSPStaking.setInitialInfo(klayswapEscrow.address, [SIG, Factory_KSP], sigKSPStaking_REWARD_DURATION, feeDistributor.address)

    console.log('  done 5')

    // 5. SigFarm
    await sigFarm.setInitialInfo(SIG, sigFarm_LOCKING_PERIOD, xSIGToken.address)


    console.log('  done 6')

    // 6. xSIGFarm
    await xSIGFarm.setInitialInfo(xSIGToken.address, vxSIGToken, sigmaVoter.address, sigKSPFarm.address, LpFarm)

    console.log('  done 7')

    // // TODO : Need to be deleted 
    // // 7. lpFarm 
    // let block = await web3.eth.getBlock("latest")
    // console.log(block.number)

    // await LpFarm.setInitialInfo(SIG, vxSIGToken.address, new BN("1000000"), block.number + 30)
    // await LpFarm.addPool(285714, 285714, SIG_oUSDT_LP)
    // await LpFarm.addPool(214286, 214286, sigKSP_KSP_LP.address)

    // let sigToken = await SigmaToken.at(SIG)
    // await sigToken.approve(LpFarm.address, bnMantissa(5));
    // await LpFarm.fund(bnMantissa(5))
    // await LpFarm.setLockdropProxy(lockdropLpFarmProxy.address)

    // console.log('  done 8')
    // // END

    // //TODO : NEED TO BE DELETED - 매뉴얼하게 해야함
    // await lockdropLpFarmProxy.setInitialInfo(sigKSP_KSP_LP.address, Lockdrop, LpFarm.address, new BN("227100212865627939698517"))

    // await sigKSP_KSP_LP.mint(bnMantissa(1000))
    // await sigKSP_KSP_LP.approve(lockdropLpFarmProxy.address, bnMantissa(1000))
    // await lockdropLpFarmProxy.releaseLPToken(bnMantissa(1000))
    // console.log('  done 10')

    // // END

    // SigmaVoter  
    await sigmaVoter.setInitialInfo(TOKEN_CONFIG.LP_POOLS, TOKEN_CONFIG.TOP_LP_POOLS, vxSIGToken, sigmaVoter_USER_MAX_VOTE, xSIGFarm.address)
    console.log('  done 11')

    // xSIG Token
    await xSIGToken.setOperator([sigFarm.address])
    console.log('  done 12')


    // vxSIG Token
    let vxSIGTokenInstance = await VXSIG_TOKEN.at(vxSIGToken)
    await vxSIGTokenInstance.setOperator([xSIGFarm.address])
    console.log('  done 13')

};
