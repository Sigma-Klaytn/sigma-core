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
const KSPConverter = artifacts.require('KSPConverter');

async function makeErc20Token(opts = {}) {
    const quantity = etherUnsigned(dfn(opts.quantity, 1e25));
    const decimals = etherUnsigned(dfn(opts.decimals, 18));
    const symbol = opts.symbol || 'DAI';
    const name = opts.name || `Erc20 ${symbol}`;
    return await MockERC20.new();
}

async function makeDepositingVault(opts = {}) {
    return await DepositingVault.new();
}

async function makeVault(opts = {}) {
    return await Vault.new();
}
async function makeKSPVault(kspaddress, opts = {}) {
    return await KSPVault.new(kspaddress);
}

async function makeMockVotingKSP(kspToken, opts = {}) {
    return await MockVotingKSP.new(kspToken);
}

async function makeKSPConverter(kspToken, votingKSP, opts = {}) {
    return await KSPConverter.new(kspToken, votingKSP);
}

module.exports = {
    MockERC20,
    DepositingVault,
    Vault,
    KSPVault,
    MockVotingKSP,
    KSPConverter,

    makeErc20Token,
    makeDepositingVault,
    makeVault,
    makeKSPVault,
    makeMockVotingKSP,
    makeKSPConverter
};
