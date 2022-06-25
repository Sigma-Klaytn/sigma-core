const HDWalletProvider = require('truffle-hdwallet-provider-klaytn');
const Caver = require('caver-js');
const dotenv = require('dotenv');
dotenv.config();

module.exports = {
    plugins: ["truffle-contract-size"],
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*', // Match any network id,
            gas: '6721975',

        },
        klaytn: {
            provider: () => {
                const pks = JSON.parse(
                    fs.readFileSync(path.resolve(__dirname) + '/privateKeys.js')
                );

                return new HDWalletProvider(
                    pks,
                    'http://localhost:8551',
                    0,
                    pks.length
                );
            },
            network_id: '1001', //Klaytn baobab testnet's network id
            gas: '8500000',
            gasPrice: null
        },
        kasBaobab: {
            provider: () => {
                const option = {
                    headers: [
                        {
                            name: 'Authorization',
                            value:
                                'Basic ' +
                                Buffer.from(
                                    process.env.KAS_ACCESSKEY_ID +
                                    ':' +
                                    process.env.KAS_SECRET_ACCESS_KEY
                                ).toString('base64')
                        },
                        { name: 'x-chain-id', value: '1001' }
                    ],
                    keepAlive: false
                };
                return new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    new Caver.providers.HttpProvider(
                        'https://node-api.klaytnapi.com/v1/klaytn',
                        option
                    )
                );
            },
            network_id: '1001', //Klaytn baobab testnet's network id
            gas: '8500000',
            gasPrice: '750000000000'
        },
        kasCypress: {
            provider: () => {
                const option = {
                    headers: [
                        {
                            name: 'Authorization',
                            value:
                                'Basic ' +
                                Buffer.from(
                                    process.env.KAS_ACCESSKEY_ID +
                                    ':' +
                                    process.env.KAS_SECRET_ACCESS_KEY
                                ).toString('base64')
                        },
                        { name: 'x-chain-id', value: '8217' }
                    ],
                    keepAlive: false
                };
                return new HDWalletProvider(
                    process.env.PRIVATE_KEY,
                    new Caver.providers.HttpProvider(
                        'https://node-api.klaytnapi.com/v1/klaytn',
                        option
                    )
                );
            },
            network_id: '8217', //Klaytn baobab testnet's network id
            gas: '10000000',
            gasPrice: null,
            networkCheckTimeout: 7000000,
            timeoutBlocks: 500
        },
        baobab: {
            provider: () => {
                return new HDWalletProvider(
                    [
                        process.env.PRIVATE_KEY_3, // Get two addresses for test.
                        process.env.PRIVATE_KEY_2
                    ],
                    'https://api.baobab.klaytn.net:8651',
                    0,
                    2
                );
            },
            network_id: '1001', //Klaytn baobab testnet's network id
            gas: '8500000',
            gasPrice: null
        },

        cypress: {
            provider: () => {
                return new HDWalletProvider(process.env.PRIVATE_KEY, 'https://public-node-api.klaytnapi.com/v1/cypress');
            },
            network_id: '8217', //Klaytn mainnet’s network id
            gas: '8500000',
        },
    },

    compilers: {
        solc: {
            version: '0.8.9',
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    }
};
