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

-   All auditing contracts above are UUPSUpgradeableSmartContract.
-   Test codes are provided for all auditing contract except KlayswapEscrow.sol (It's too dependent on Klayswap Contract. Only Mainnet test has been done).
-   All auditing contracts above are conducted static security analyze using slither. You can find a result at **./slither-analyze/**.
