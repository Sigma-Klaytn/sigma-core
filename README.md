# Sigma-core

## Sigma Smart Contract

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
| npm run test              | test smart contract codes                                             |
