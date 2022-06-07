'use strict';

const { dfn, bnMantissa, BN, expectEqual } = require('./JS');
const {
    encodeParameters,
    etherBalance,
    etherUnsigned,
    address,
    encode,
    encodePacked
} = require('./Ethereum');
const { hexlify, keccak256, toUtf8Bytes } = require('ethers').utils;

// 1. [TEST]
const MockERC20 = artifacts.require('MockERC20');
const DepositingVault = artifacts.require('DepositingVault');
const Vault = artifacts.require('Vault');
const KSPVault = artifacts.require('KSPVault');
const MockVotingKSP = artifacts.require('MockVotingKSP');
const IPoolVoting = artifacts.require('IPoolVoting');
// const KSPConverter = artifacts.require('KSPConverter');
const SigKSPStaking = artifacts.require('SigKSPStaking');
const SIGLocker = artifacts.require('SIGLocker');
const TokenSale = artifacts.require('TokenSale');
// const SIGFarm = artifacts.require('SIGFarm');
const xSIGToken = artifacts.require('xSIGToken');
const vxSIGToken = artifacts.require('vxSIGToken');
// const xSIGFarm = artifacts.require('xSIGFarm');
// const LpFarm = artifacts.require('LPFarm');
const Lockdrop = artifacts.require('Lockdrop');
// const SigKSPFarm = artifacts.require('SigKSPFarm');
// const SigmaVoter = artifacts.require('SigmaVoter');
const UUPSProxy = artifacts.require('UUPSProxy')
const UpgradeableLockdrop = artifacts.require('UpgradeableLockdropV1')
const UpgradeableLockdropV2 = artifacts.require('UpgradeableLockdropV2')
const UpgradeableTokenSaleV1 = artifacts.require('UpgradeableTokenSaleV1')
const UpgradeableTokenSaleV2 = artifacts.require('UpgradeableTokenSaleV2')
const LpFarmV1 = artifacts.require('LpFarmV1')
const LpFarmV2_Test = artifacts.require('LpFarmV2_Test');
const SigFarmV1 = artifacts.require('SigFarmV1');
const SigFarmV2_Test = artifacts.require('SigFarmV2_Test');
const xSigFarmV1 = artifacts.require('xSigFarmV1')
const xSigFarmV2_Test = artifacts.require('xSigFarmV2_Test')
const SigKSPFarmV1 = artifacts.require('SigKSPFarmV1')
const SigKSPFarmV2_Test = artifacts.require('SigKSPFarmV2_Test')
const SigKSPStakingV1 = artifacts.require('SigKSPStakingV1')
const SigKSPStakingV2_Test = artifacts.require('SigKSPStakingV2_Test')
const SigmaVoterV1 = artifacts.require('SigmaVoterV1')
const SigmaVoterV2_Test = artifacts.require('SigmaVoterV2_Test')



async function makeErc20Token(opts = {}) {
    const quantity = etherUnsigned(dfn(opts.quantity, 1e25));
    const decimals = etherUnsigned(dfn(opts.decimals, 18));
    const symbol = opts.symbol || 'DAI';
    const name = opts.name || `Erc20 ${symbol}`;
    return await MockERC20.new();
}

async function makeIPoolVoting(opts = {}) {
    return await IPoolVoting.new();
}

async function makeDepositingVault(opts = {}) {
    return await DepositingVault.new();
}

async function makeVault(opts = {}) {
    return await Vault.new();
}
async function makeKSPVault(kspVotingAddress, kspTokenaddress, poolVotingAddress, opts = {}) {
    return await KSPVault.new(kspVotingAddress, kspTokenaddress, poolVotingAddress);
}

async function makeMockVotingKSP(kspToken, opts = {}) {
    return await MockVotingKSP.new(kspToken);
}



async function makeTokenSale(opts = {}) {
    return await TokenSale.new();
}


async function makeXSIGToken(opts = {}) {
    return await xSIGToken.new()
}

async function makeVxSIGToken(opts = {}) {
    return await vxSIGToken.new();
}



async function makeLockdrop(opts = {}) {
    return await Lockdrop.new();
}



async function makeUUPSProxy(implAddress, data, opts = {}) {
    return await UUPSProxy.new(implAddress, data);
}

async function makeUpgradeableLockdrop(opts = {}) {
    return await UpgradeableLockdrop.new()
}
async function makeUpgradeableLockdropV2(opts = {}) {
    return await UpgradeableLockdropV2.new()
}

async function makeUpgradeableTokenSaleV1(opts = {}) {
    return await UpgradeableTokenSaleV1.new()
}

async function makeUpgradeableTokenSaleV2(opts = {}) {
    return await UpgradeableTokenSaleV2.new()
}

async function makeLpFarmV1(opts = {}) {
    return await LpFarmV1.new()
}
async function makeLpFarmV2_Test(opts = {}) {
    return await LpFarmV2_Test.new()
}

async function makeSigFarmV1(opts = {}) {
    return await SigFarmV1.new()
}
async function makeSigFarmV2_Test(opts = {}) {
    return await SigFarmV2_Test.new()
}

async function makexSigFarmV1(opts = {}) {
    return await xSigFarmV1.new()
}
async function makexSigFarmV2_Test(opts = {}) {
    return await xSigFarmV2_Test.new()
}

async function makeSigKSPFarmV1(opts = {}) {
    return await SigKSPFarmV1.new()
}
async function makeSigKSPFarmV2_Test(opts = {}) {
    return await SigKSPFarmV2_Test.new()
}

async function makeSigKSPStakingV1(opts = {}) {
    return await SigKSPStakingV1.new()
}
async function makeSigKSPStakingV2_Test(opts = {}) {
    return await SigKSPStakingV2_Test.new()
}

async function makeSigmaVoterV1(opts = {}) {
    return await SigmaVoterV1.new()
}
async function makeSigmaVoterV2_Test(opts = {}) {
    return await SigmaVoterV2_Test.new()
}


module.exports = {
    MockERC20,
    DepositingVault,
    Vault,
    KSPVault,
    MockVotingKSP,
    TokenSale,
    xSIGToken,
    vxSIGToken,
    IPoolVoting,
    Lockdrop,
    UUPSProxy,
    UpgradeableLockdrop,
    UpgradeableLockdropV2,
    UpgradeableTokenSaleV1,
    UpgradeableTokenSaleV2,
    LpFarmV1,
    LpFarmV2_Test,
    SigFarmV1,
    SigFarmV2_Test,
    xSigFarmV1,
    xSigFarmV2_Test,
    SigKSPFarmV1,
    SigKSPFarmV2_Test,
    SigKSPStakingV1,
    SigKSPStakingV2_Test,
    SigmaVoterV1,
    SigmaVoterV2_Test,
    makeErc20Token,
    makeDepositingVault,
    makeVault,
    makeKSPVault,
    makeMockVotingKSP,
    // makeKSPConverter,

    makeTokenSale,
    makeXSIGToken,
    makeVxSIGToken,
    makeIPoolVoting,
    makeLockdrop,

    makeUUPSProxy,
    makeUpgradeableLockdrop,
    makeUpgradeableLockdropV2,
    makeUpgradeableTokenSaleV1,
    makeUpgradeableTokenSaleV2,
    makeLpFarmV1,
    makeLpFarmV2_Test,
    makeSigFarmV1,
    makeSigFarmV2_Test,
    makexSigFarmV1,
    makexSigFarmV2_Test,
    makeSigKSPFarmV1,
    makeSigKSPFarmV2_Test,
    makeSigKSPStakingV1,
    makeSigKSPStakingV2_Test,
    makeSigmaVoterV1,
    makeSigmaVoterV2_Test
};
