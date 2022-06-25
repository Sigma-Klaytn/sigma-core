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


// TEST PURPOSE NEET TO DELETE AFTER TEST
const LpFarmV3 = artifacts.require("LpFarmV3");
const MockERC20 = artifacts.require("MockERC20")
const SigmaToken = artifacts.require("SigmaToken");
// END OF THEST PURPOSE

// CONST 값 : Deploy 전 꼭 확인

//TODO 
const sigKSPStaking_REWARD_DURATION = 86400; // 실제로는 2일로 바꿔야함
//TODO 
const sigFarm_LOCKING_PERIOD = 300; // 실제로는 7일 
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

// TODO: Test 용도로 직접 deploy 하여 사용 .address 삭제
let sigKSP_KSP_LP = "";
// TODO: Test 용도로 직접 deploy 하여 사용 .address 삭제
let LpFarm = "";
// TODO: Test 용도로 직접 deploy 하여 사용 .address 삭제
let vxSIGToken;
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

    // ==== TEST PURPOSE NEET TO DELETE AFTER TEST ====

    await deployer.deploy(MockERC20);
    sigKSP_KSP_LP = await MockERC20.deployed();


    //lpFarmV3 
    await deployer.deploy(LpFarmV3);
    impl = await LpFarmV3.deployed()
    await deployer.deploy(UUPSProxy, impl.address, "0x");
    LpFarm = await LpFarmV3.at((await UUPSProxy.deployed()).address)


    //vxSIG Token
    await deployer.deploy(VXSIG_TOKEN)
    vxSIGToken = await VXSIG_TOKEN.deployed()

    // TODO : END OF THEST PURPOSE =================

    // /**
    //  * [Table of deployment]
    //  * 1. Deploy all contract that are needed. 
    //  * 2. Initialize All
    //  * 3. setInitialInfo
    //  * 4. Extra setting for each of the contract.
    //  */


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

    console.log("sig address ", SIG);
    console.log("SIG_oUSDT_LP address ", SIG_oUSDT_LP);
    console.log("sigKSP_KSP_LP address ", sigKSP_KSP_LP.address);

    console.log("LpFarm address ", LpFarm.address);

    console.log("treasury address ", treasury.address);
    console.log("feeDistributor address ", feeDistributor.address);
    console.log("klayswapEscrow address ", klayswapEscrow.address);
    console.log("sigKSPStaking address ", sigKSPStaking.address);
    console.log("sigFarm address ", sigFarm.address);
    console.log("xSIGFarm address ", xSIGFarm.address);
    console.log("lockdropLpFarmProxy address ", lockdropLpFarmProxy.address);
    console.log("sigmaVoter address ", sigmaVoter.address);

    console.log("xSIGToken address ", xSIGToken.address);
    console.log("vxSIGToken address ", vxSIGToken.address);

    console.log("sigKSPFarm address ", sigKSPFarm.address);


    // sigKSP_KSP_LP = await MockERC20.at("0x7a2690df94c439d390909d151301542afFB2a551");
    // LpFarm = await LpFarmV3.at("0x84c16Fcd5b9F370d902d2Bb886b34C55fC2cc956")
    // vxSIGToken = await VXSIG_TOKEN.at("0xfA17E89d9eB7B8a9183872CeBbF4e0d0a0721003")



    // Sigma Contract To be Deployed
    // treasury = await TREASURY.at("0xFA2628EffaA20f6E9D9adb369dEE754e6d2D01F6")
    // feeDistributor = await FEE_DISTRIBUTOR.at("0x51b9148fCdDAbA47DF56eB5A0eeD6B6d9E14112d")
    // klayswapEscrow = await KLAYSWAP_ESCORW.at("0x64871102A7229515961C8478CFdaED0A9BAa9aba")
    // sigKSPStaking = await SIGKSP_STAKING.at("0x774051cFC2bd4Cd9FBd9a8C5f8CF6B092Aa6FF1d")
    // sigFarm = await SIGFARM.at("0x21FDea4C86E55C46561e21e333885C2c6b42b57a")
    // xSIGFarm = await XSIG_FARM.at("0x752CFeC711a7f44b2901195D828189B9083fa2F4")
    // lockdropLpFarmProxy = await LOCKDROP_LPFARM_PROXY.at("0xdeB2bd13e328FF750e16A0b751D63B833B1a6712")
    // xSIGToken = await XSIG_TOKEN.at("0x7fE0A8B46D5830E64938e6Db09B8C44c5D664D04")
    // sigmaVoter = await SIGMA_VOTER.at("0x87c1b6F0892174B8E5ad9Eb12e7f915e528eeF2E")
    // sigKSPFarm = await SIGKSP_FARM.at("0x2d297688263b9313eeEf244e95b9e880aeA4481F")


    // weird log is because of the weird of Klaytn's error.

    // 2. Initialize all upgradeable smart contract 

    // TODO : should be deleted 
    await LpFarm.initialize()
    // END

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
    await xSIGFarm.setInitialInfo(xSIGToken.address, vxSIGToken.address, sigmaVoter.address, sigKSPFarm.address, LpFarm.address)

    console.log('  done 7')

    // TODO : Need to be deleted 
    // 7. lpFarm 
    let block = await web3.eth.getBlock("latest")
    console.log(block.number)

    await LpFarm.setInitialInfo(SIG, vxSIGToken.address, new BN("1000000"), block.number + 30)
    await LpFarm.addPool(285714, 285714, SIG_oUSDT_LP)
    await LpFarm.addPool(214286, 214286, sigKSP_KSP_LP.address)

    let sigToken = await SigmaToken.at(SIG)
    await sigToken.approve(LpFarm.address, bnMantissa(5));
    await LpFarm.fund(bnMantissa(5))
    await LpFarm.setLockdropProxy(lockdropLpFarmProxy.address)

    console.log('  done 8')
    // END

    //TODO : NEED TO BE DELETED - 매뉴얼하게 해야함
    await lockdropLpFarmProxy.setInitialInfo(sigKSP_KSP_LP.address, Lockdrop, LpFarm.address, new BN("227100212865627939698517"))

    await sigKSP_KSP_LP.mint(bnMantissa(1000))
    await sigKSP_KSP_LP.approve(lockdropLpFarmProxy.address, bnMantissa(1000))
    await lockdropLpFarmProxy.releaseLPToken(bnMantissa(1000))
    console.log('  done 10')

    // END

    // SigmaVoter  
    await sigmaVoter.setInitialInfo(TOKEN_CONFIG.LP_POOLS, TOKEN_CONFIG.TOP_LP_POOLS, vxSIGToken.address, sigmaVoter_USER_MAX_VOTE, xSIGFarm.address)
    console.log('  done 11')

    // xSIG Token
    await xSIGToken.setOperator([sigFarm.address])
    console.log('  done 12')


    // vxSIG Token
    await vxSIGToken.setOperator([xSIGFarm.address])
    console.log('  done 13')

};
