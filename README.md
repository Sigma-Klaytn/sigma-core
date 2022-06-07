# Sigma - Certik Audit

Date : 8th June 2022 -
Stakeholders :

-   Sigma :
    -   0xCrispyCake (Smart contract dev)
    -   deenice (Product Design, Strategy)
-   Certik :
    -   Need to be updated.

## Audit Scope

```
At sigma-core/contracts/Upgradeable/
- KlayswapEscrow.sol
- LPFarm.sol
- SIGFarm.sol
- xSIGFarm.sol
- sigKSPFarm.sol
- sigKSPStaking.sol
- SigmaVoter.sol
```

## Before the audit, please be noted

-   All contracts above are UUPSUpgradeableSmartContract.
-   Test codes are provided for all auditing contract except KlayswapEscrow.sol (It's too dependent on Klayswap Contract. Only Mainnet test has been done).

## Sigma

Sigma presents a capital efficient solution which affords users to earn the maximum boosted rewards from staking without having to lock their tokens.

## Installation

Clone repo and install the dependencies and devDependencies.

```sh
git clone git@github.com:Sigma-Klaytn/sigma-core.git
cd sigma-core
npm install
```

Change `env.example` file name to `.env` and fill out the requirements.

```sh
PRIVATE_KEY=[YOUR_ACCOUNT_PRIVATE_KEY]
KAS_ACCESSKEY_ID=[KAS_ACCESS_KEY_ID]
KAS_SECRET_ACCESS_KEY=[KAS_SECRET_ACCESS_KEY]
```

## Scripts

Use the scripts below on the command line to deploy, test, compile code.

| Shell Command             | Description                                                           |
| ------------------------- | --------------------------------------------------------------------- |
| npm run deploy:baobab     | Deploy contract on baobab (testnet) using Private Key                 |
| npm run deploy:kasBaobab  | Deploy contract on baobab (testnet) using KAS                         |
| npm run deploy:kasCypress | Deploy contract on cypress (mainnet) using KAS                        |
| npm run deploy:local      | Deploy contracts on local blockchain. (need to run ganache-cli first) |
| npm run test:local        | test smart contract codes on local                                    |
| npm run test:baobab       | test smart contract codes on testnet                                  |
| npm run test:mainnet      | test smart contract codes on mainnet                                  |

"test:local": "truffle test --network development",
"test:baobab": "truffle test --network baobab",
"test:mainnet": "truffle test --network kasCypress",

## Editor Setting

```sh
npm install --save-dev prettier prettier-plugin-solidity
```

Set setting.json in VSCode.

```
"solidity.formatter": "prettier", // This is the default so it might be missing.
"[solidity]": {
    "editor.defaultFormatter": "JuanBlanco.solidity"
}
```
