const {
    makeErc20Token,
    makeDepositingVault,
    makeVault,
    MockERC20,
    DepositingVault,
    Vault
} = require('../Utils/Sigma');

const {
    expectAlmostEqualMantissa,
    expectRevert,
    expectEvent,
    bnMantissa,
    BN
} = require('../Utils/JS');

const oneMantissa = new BN(10).pow(new BN(18));

contract('Vault', function (accounts) {
    describe('Vault function test.', () => {
        let depositingContract;
        let erc20Token;
        let vault;
        let withdrawableVault;

        before(async () => {
            console.log('Prepare for tests...');

            //Deploy now
            // depositingContract = await makeDepositingVault();
            // erc20Token = await makeErc20Token();
            // vault = await makeVault();

            //Use pre-deployed one
            depositingContract = await DepositingVault.at(
                `0xbbe34939eda3FD9876D0fAC713873dDd9E2eDb5a`
            );

            erc20Token = await MockERC20.at(
                '0x037372343DDB9C459B80727Ce07bBb76aF813e1F'
            );
            vault = await Vault.at(
                '0xA337800a4cD9c9f39614173cffF15E80a7Dd98F3'
            );

            console.log('depositing Contract : ', depositingContract.address);
            console.log('erc20 Token : ', erc20Token.address);
            console.log('vault : ', vault.address);
        });

        it(`Mints ERC20 token to contract`, async () => {
            let receipt = await depositingContract.mintERC20Token(
                erc20Token.address,
                bnMantissa(200)
            );
            expectEvent(receipt, 'MINT_TOKEN', {
                amount: bnMantissa(200)
            });
        });

        it(`Deposit to Vault contract`, async () => {
            await depositingContract.approveToken(
                erc20Token.address,
                vault.address,
                bnMantissa(10)
            );

            let receipt = await depositingContract.lockTokens(
                vault.address,
                erc20Token.address,
                depositingContract.address,
                bnMantissa(1),
                1648539278
            );

            expectEvent(receipt, 'LOCKED_TOKEN', {
                amount: bnMantissa(1)
            });
        });

        it(`Check depositing contract's vault balance.`, async () => {
            let ids = await depositingContract.getVaultsByWithdrawer(
                vault.address,
                depositingContract.address
            );

            for (i = 0; i < ids.length; i++) {
                let item = await vault.lockedToken(ids[i]);
                console.log(
                    'item id : ',
                    ids[i],
                    ' withdrawn: ',
                    item.withdrawn
                );
                // let item = items[i];
                if (item.withdrawn == false) {
                    withdrawableVault = ids[i];
                }
            }

            console.log(
                'withdrawableVault :  ',
                withdrawableVault,
                ' Total Vault Count : ',
                ids.length
            );
        });

        it(`Withdraw from vault`, async () => {
            let receipt = await depositingContract.withdrawTokens(
                vault.address,
                withdrawableVault
            );

            expectEvent.inTransaction(receipt, vault, 'Withdraw', {
                withdrawer: depositingContract.address
            });

            expectEvent.inTransaction(receipt, depositingContract, 'Withdraw', {
                id: withdrawableVault
            });
        });
    });
});
