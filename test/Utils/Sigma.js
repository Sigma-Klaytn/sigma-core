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
const SIGFarm = artifacts.require('SIGFarm');
const xSIGToken = artifacts.require('xSIGToken');
const vxSIGToken = artifacts.require('vxSIGToken');
const xSIGFarm = artifacts.require('xSIGFarm');
const LpFarm = artifacts.require('LPFarm');
const Lockdrop = artifacts.require('Lockdrop');
const SigKSPFarm = artifacts.require('SigKSPFarm');
const SigmaVoter = artifacts.require('SigmaVoter');
const UUPSProxy = artifacts.require('UUPSProxy')
const UpgradeableLockdrop = artifacts.require('UpgradeableLockdropV1')
const UpgradeableLockdropV2 = artifacts.require('UpgradeableLockdropV2')
const UpgradeableTokenSaleV1 = artifacts.require('UpgradeableTokenSaleV1')
const UpgradeableTokenSaleV2 = artifacts.require('UpgradeableTokenSaleV2')
const LpFarmV1 = artifacts.require('LpFarmV1')
const LpFarmV2_Test = artifacts.require('LpFarmV2_Test');
const SigFarmV1 = artifacts.require('SigFarmV1');
const SigFarmV2_Test = artifacts.require('SigFarmV2_Test');



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

// async function makeKSPConverter(kspToken, votingKSP, opts = {}) {
//     return await KSPConverter.new(kspToken, votingKSP);
// }

async function makeSigKSPStaking(opts = {}) {
    return await SigKSPStaking.new();
}

async function makeSIGLocker(maxLockWeeks, sigToken, opts = {}) {
    return await SIGLocker.new(maxLockWeeks, sigToken);
}

async function makeTokenSale(opts = {}) {
    return await TokenSale.new();
}

async function makeSIGFarm(opts = {}) {
    return await SIGFarm.new();
}

async function makeXSIGToken(opts = {}) {
    return await xSIGToken.new()
}

async function makeVxSIGToken(opts = {}) {
    return await vxSIGToken.new();
}
async function makeXSIGFarm(opts = {}) {
    return await xSIGFarm.new();
}

async function makeLpFarm(opts = {}) {
    return await LpFarm.new();
}

async function makeLockdrop(opts = {}) {
    return await Lockdrop.new();
}

async function makeSigKSPFarm(opts = {}) {
    return await SigKSPFarm.new();
}

async function makeSigmaVoter(opts = {}) {
    return await SigmaVoter.new();
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



module.exports = {
    MockERC20,
    DepositingVault,
    Vault,
    KSPVault,
    MockVotingKSP,
    // KSPConverter,
    SigKSPStaking,
    SIGLocker,
    TokenSale,
    SIGFarm,
    xSIGToken,
    xSIGFarm,
    vxSIGToken,
    IPoolVoting,
    LpFarm,
    Lockdrop,
    SigKSPFarm,
    SigmaVoter,
    UUPSProxy,
    UpgradeableLockdrop,
    UpgradeableLockdropV2,
    UpgradeableTokenSaleV1,
    UpgradeableTokenSaleV2,
    LpFarmV1,
    LpFarmV2_Test,
    SigFarmV1,
    SigFarmV2_Test,
    makeErc20Token,
    makeDepositingVault,
    makeVault,
    makeKSPVault,
    makeMockVotingKSP,
    // makeKSPConverter,
    makeSigKSPStaking,
    makeSIGLocker,
    makeTokenSale,
    makeSIGFarm,
    makeXSIGToken,
    makeXSIGFarm,
    makeVxSIGToken,
    makeIPoolVoting,
    makeLpFarm,
    makeLockdrop,
    makeSigKSPFarm,
    makeSigmaVoter,
    makeUUPSProxy,
    makeUpgradeableLockdrop,
    makeUpgradeableLockdropV2,
    makeUpgradeableTokenSaleV1,
    makeUpgradeableTokenSaleV2,
    makeLpFarmV1,
    makeLpFarmV2_Test,
    makeSigFarmV1,
    makeSigFarmV2_Test
};
