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
const KlayswapGovernV1 = artifacts.require('KlayswapGovernV1');
const vxSIGToken = artifacts.require('vxSIGToken');
const UUPSProxy = artifacts.require('UUPSProxy')
const KlayswapEscrowGovernTest = artifacts.require('KlayswapEscrowGovernTest');
const xSIGFarmGovernTest = artifacts.require('xSIGFarmGovernTest')


async function makeErc20Token(opts = {}) {
    const quantity = etherUnsigned(dfn(opts.quantity, 1e25));
    const decimals = etherUnsigned(dfn(opts.decimals, 18));
    const symbol = opts.symbol || 'DAI';
    const name = opts.name || `Erc20 ${symbol}`;
    return await MockERC20.new();
}

async function makeVxSIGToken(opts = {}) {
    return await vxSIGToken.new();
}
async function makeXSIGFarm(opts = {}) {
    return await xSIGFarm.new();
}

async function makeUUPSProxy(implAddress, data, opts = {}) {
    return await UUPSProxy.new(implAddress, data);
}


async function makeKlayswapGovernV1(opts = {}) {
    return await KlayswapGovernV1.new()
}

//govern test

async function makeXSIGFarmGovernTest(opts = {}) {
    return await xSIGFarmGovernTest.new()
}

async function makeKlayswapEscrowGovernTest(opts = {}) {
    return await KlayswapEscrowGovernTest.new()
}



module.exports = {
    makeVxSIGToken,
    UUPSProxy,
    vxSIGToken,
    KlayswapGovernV1,
    makeKlayswapGovernV1,
    MockERC20,
    makeUUPSProxy,
    KlayswapEscrowGovernTest,
    xSIGFarmGovernTest,
    makeKlayswapEscrowGovernTest,
    makeXSIGFarmGovernTest
};