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
const KSPConverter = artifacts.require('KSPConverter');
const SigKSPStaking = artifacts.require('SigKSPStaking');
const SIGLocker = artifacts.require('SIGLocker');
const TokenSale = artifacts.require('TokenSale');
const SIGFarm = artifacts.require('SIGFarm');
const xSIGToken = artifacts.require('xSIGToken');
const vxSIGToken = artifacts.require('vxSIGToken');
const xSIGFarm = artifacts.require('xSIGFarm');

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

async function makeKSPConverter(kspToken, votingKSP, opts = {}) {
    return await KSPConverter.new(kspToken, votingKSP);
}

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


module.exports = {
    MockERC20,
    DepositingVault,
    Vault,
    KSPVault,
    MockVotingKSP,
    KSPConverter,
    SigKSPStaking,
    SIGLocker,
    TokenSale,
    SIGFarm,
    xSIGToken,
    xSIGFarm,
    vxSIGToken,
    IPoolVoting,


    makeErc20Token,
    makeDepositingVault,
    makeVault,
    makeKSPVault,
    makeMockVotingKSP,
    makeKSPConverter,
    makeSigKSPStaking,
    makeSIGLocker,
    makeTokenSale,
    makeSIGFarm,
    makeXSIGToken,
    makeXSIGFarm,
    makeVxSIGToken,
    makeIPoolVoting
};
