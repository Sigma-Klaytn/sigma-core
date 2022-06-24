const TOKEN_CONFIG = require('../token.js');


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


// TEST PURPOSE NEET TO DELETE AFTER TEST
const LpFarmV3 = artifacts.require("LpFarmV3");
const MockERC20 = artifacts.require("MockERC20")
const SigmaToken = artifacts.require("SigmaToken");
// END OF THEST PURPOSE


//Klayswap 관련
const Factory_KSP = "0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654";
const PoolVoting = "0x71b59e4bc2995b57aa03437ed645ada7dd5b1890";
const VotingKSP_vKSP = "0x2f3713f388bc4b8b364a7a2d8d57c5ff4e054830";
const Utils = "0x7A74B3be679E194E1D6A0C29A343ef8D2a5AC876";
//(실제 deploy 때에는 oUSDT - SIG)
const oUSDT_KSP_LP = "0xE75a6A3a800A2C5123e67e3bde911Ba761FE0705"
const oUSDT = "0xcee8faf64bb97a73bb51e115aa89c17ffa8dd167";


//Sigma Pre-deployed contract address
// TODO: Test 용도로 직접 deploy 하여 사용
let SIG = "";
let SIG_oUSDT_LP = "";
let sigKSP_KSP_LP = "";
let LpFarm = "";
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
let vxSIGToken;
let sigmaVoter;


module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts();
    const owner = accounts[0];

    // ==== TEST PURPOSE NEET TO DELETE AFTER TEST ====

    await deployer.deploy(SigmaToken, owner);
    SIG = await SigmaToken.deployed();
    await deployer.deploy(MockERC20);
    SIG_oUSDT_LP = await MockERC20.deployed();
    await deployer.deploy(MockERC20);
    sigKSP_KSP_LP = await MockERC20.deployed();


    //lpFarmV3 
    await deployer.deploy(LpFarmV3);
    let impl = await LpFarmV3.deployed()
    await deployer.deploy(UUPSProxy, impl.address, "0x");
    LpFarm = await LpFarmV3.at((await UUPSProxy.deployed()).address)

    // TODO : END OF THEST PURPOSE =================

    /**
     * [Table of deployment]
     * 1. Deploy all contract that are needed. 
     * 2. Initialize All
     * 3. setInitialInfo
     * 4. Extra setting for each of the contract.
     */


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

    // vxSIG Token
    await deployer.deploy(VXSIG_TOKEN)
    vxSIGToken = await VXSIG_TOKEN.deployed()


    console.log("sig address ", SIG.address);
    console.log("SIG_oUSDT_LP address ", SIG_oUSDT_LP.address);
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


    // 2. Initialize all upgradeable smart contract 

    // TODO : should be deleted 
    await LpFarm.initialize()
    await treasury.initialize()
    await feeDistributor.initialize()
    await klayswapEscrow.initialize()
    await sigKSPStaking.initialize()
    await sigFarm.initialize()
    await xSIGFarm.initialize()
    await lockdropLpFarmProxy.initialize()
    await sigmaVoter.initialize()


    console.log(' Initialize done ')
    // 3. Set initialInfo

    // // 1. Treasury
    // // TODO : CHANGE THIS TO SIG-oUSDT 
    // await treasury.setInitialInfo(oUSDT_KSP_LP)

    // // 2. FeeDistributor

    // // here
    // // await feeDistributor.setInitialInfo(sigKSPStaking.address, treasury.address, sigFarm.address, Factory_KSP, oUSDT_KSP_LP, oUSDT, SIG.address, Factory_KSP)

    // await feeDistributor.setOperator([BOT_ACCOUNT])

    // // 3. KlayswapEscrow
    // // await klayswapEscrow.setInitialInfo(Factory_KSP, oUSDT, VotingKSP_vKSP, PoolVoting, sigmaVoter.address, Factory_KSP, feeDistributor.address)
    // await klayswapEscrow.setOperator([BOT_ACCOUNT])

    // for (const [key, value] of Object.entries(TOKEN_CONFIG.TOKEN)) {
    //     console.log('approve token', value);
    //     // await klayswapEscrow.approveToken(value.toString(), Factory_KSP)
    // }


};