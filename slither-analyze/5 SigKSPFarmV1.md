# 5. SigKSPFarmV1.sol

sigKSP Farm is a bootstrapping phase go to market strategy for sigKSP. The goal is to provide attractive alternative yield opportunity to sigKSP holders, attracting more sigKSP minting demand itself. sigKSP farm itself is a staking vault where the user may deposit or withdraw sigKSP any time to yield SIG tokens. We will operate 2 reward pools, base pool and boost pool.

# ✨ Resolved Issue ( 0 issue)

---

# Summary

- [controlled-delegatecall](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#controlled-delegatecall) (1 results) (High)
- [reentrancy-eth](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#reentrancy-eth) (3 results) (High)
- [unprotected-upgrade](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#unprotected-upgrade) (1 results) (High)
- [divide-before-multiply](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#divide-before-multiply) (4 results) (Medium)
- [incorrect-equality](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#incorrect-equality) (1 results) (Medium)
- [uninitialized-local](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#uninitialized-local) (1 results) (Medium)
- [unused-return](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#unused-return) (1 results) (Medium)
- [events-maths](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#events-maths) (1 results) (Low)
- [variable-scope](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#variable-scope) (1 results) (Low)
- [reentrancy-events](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#reentrancy-events) (4 results) (Low)
- [assembly](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#assembly) (5 results) (Informational)
- [dead-code](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#dead-code) (24 results) (Informational)
- [solc-version](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#naming-convention) (35 results) (Informational)
- [unused-state](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/5-SigKSPFarmV1-sol-d537ff58cb974cdaa63692210e20789b#external-function) (4 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1038-L1055) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1048)

flattened/SigKSPFarmV1.sol#L1038-L1055

## reentrancy-eth

**comment** : nonReentrant modifier is protecting functions below.

Impact: High
Confidence: Medium

- [ ]  ID-1
Reentrancy in [SigKSPFarmV1.deposit(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1543-L1572):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1560)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
    - [sigKSP.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1562)
    External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1560)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        State variables written after the call(s):
    - [user.amount += _amount](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1563)
    - [user.rewardDebt = (user.amount * accERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1564)
    - [user.boostRewardDebt = (user.boostWeight * boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1566-L1568)

flattened/SigKSPFarmV1.sol#L1543-L1572

- [ ]  ID-2
Reentrancy in [SigKSPFarmV1.withdraw(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1578-L1612):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1598)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1598)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        State variables written after the call(s):
    - [_updateBoostWeight(msg.sender)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1607)
        - [boostAccERC20PerShare = boostAccERC20PerShare + ((erc20Reward * 1e36) / _totalBoostWeight)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1756-L1758)
    - [_updateBoostWeight(msg.sender)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1607)
        - [boostLastRewardBlock = lastBlock](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1747)
        - [boostLastRewardBlock = block.number](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1759)
    - [_updateBoostWeight(msg.sender)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1607)
        - [totalBoostWeight = totalBoostWeight - oldBoostWeight + newBoostWeight](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1696)
    - [user.amount -= _amount](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1600)
    - [user.rewardDebt = (user.amount * accERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1601)
    - [user.boostRewardDebt = (user.boostWeight * boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1603-L1605)
    - [_updateBoostWeight(msg.sender)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1607)
        - [user.boostWeight = newBoostWeight](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1695)

flattened/SigKSPFarmV1.sol#L1578-L1612

- [ ]  ID-3
Reentrancy in [SigKSPFarmV1.claim()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1617-L1636):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1627)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1627)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        State variables written after the call(s):
    - [user.rewardDebt = (user.amount * accERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1629)
    - [user.boostRewardDebt = (user.boostWeight * boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1631-L1633)

flattened/SigKSPFarmV1.sol#L1617-L1636

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-4
[SigKSPFarmV1](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1374-L1861) is an upgradeable contract that does not protect its initiliaze functions: [SigKSPFarmV1.initialize()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1446-L1450). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1146-L1149)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1159-L1167)
flattened/SigKSPFarmV1.sol#L1374-L1861

## divide-before-multiply

Impact: Medium
Confidence: Medium

- [ ]  ID-5
[SigKSPFarmV1._updateBoostReward()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1739-L1760) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * boostAllocPoint) / totalAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1753-L1754)
-[boostAccERC20PerShare = boostAccERC20PerShare + ((erc20Reward * 1e36) / _totalBoostWeight)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1756-L1758)

flattened/SigKSPFarmV1.sol#L1739-L1760

- [ ]  ID-6
[SigKSPFarmV1.boostPending(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1821-L1852) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * boostAllocPoint) / (totalAllocPoint)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1838-L1840)
-[_boostAccERC20PerShare = _boostAccERC20PerShare + (erc20Reward * 1e36) / _totalBoostWeight](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1842-L1845)

flattened/SigKSPFarmV1.sol#L1821-L1852

- [ ]  ID-7
[SigKSPFarmV1._updateBaseReward()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1712-L1734) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * baseAllocPoint) / totalAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1726-L1727)
-[accERC20PerShare = accERC20PerShare + (erc20Reward * 1e36) / totalSigKSP](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1729-L1732)

flattened/SigKSPFarmV1.sol#L1712-L1734

- [ ]  ID-8
[SigKSPFarmV1.basePending(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1792-L1816) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * (rewardPerBlock) * (baseAllocPoint)) / (totalAllocPoint)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1807-L1809)
-[_accERC20PerShare = _accERC20PerShare + ((erc20Reward * 1e36) / totalSigKSP)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1810-L1812)

flattened/SigKSPFarmV1.sol#L1792-L1816

## incorrect-equality

Impact: Medium
Confidence: High

- [ ]  ID-9
[SigKSPFarmV1._updateBaseReward()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1712-L1734) uses a dangerous strict equality:
    - [totalSigKSP == 0](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1719)

flattened/SigKSPFarmV1.sol#L1712-L1734

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-10
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L922) is a local variable never initialized

flattened/SigKSPFarmV1.sol#L922

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-11
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L909-L932) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L920-L929)

flattened/SigKSPFarmV1.sol#L909-L932

## events-maths

Impact: Low
Confidence: Medium

- [ ]  ID-12
[SigKSPFarmV1.setBaseAndBoostAllocPoint(uint256,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1511-L1519) should emit an event for:
    - [baseAllocPoint = _baseAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1516)
    - [boostAllocPoint = _boostAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1517)
    - [totalAllocPoint = baseAllocPoint + boostAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1518)

flattened/SigKSPFarmV1.sol#L1511-L1519

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-13
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L922)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L909-L932) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L923-L926)

flattened/SigKSPFarmV1.sol#L922

## reentrancy-events

Impact: Low
Confidence: Medium

- [ ]  ID-14
Reentrancy in [SigKSPFarmV1.fund(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1662-L1670):
External calls:
    - [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1667)
    Event emitted after the call(s):
    - [Funded(msg.sender,_amount,endBlock)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1669)

flattened/SigKSPFarmV1.sol#L1662-L1670

- [ ]  ID-15
Reentrancy in [SigKSPFarmV1.claim()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1617-L1636):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1627)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1627)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        Event emitted after the call(s):
    - [Claim(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1635)

flattened/SigKSPFarmV1.sol#L1617-L1636

- [ ]  ID-16
Reentrancy in [SigKSPFarmV1.withdraw(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1578-L1612):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1598)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
    - [sigKSP.safeTransfer(address(msg.sender),_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1610)
    External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1598)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        Event emitted after the call(s):
    - [Withdraw(msg.sender,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1611)

flattened/SigKSPFarmV1.sol#L1578-L1612

- [ ]  ID-17
Reentrancy in [SigKSPFarmV1.deposit(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1543-L1572):
External calls:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1560)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L425-L428)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1706)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
    - [sigKSP.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1562)
    External calls sending eth:
    - [_transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1560)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)
        Event emitted after the call(s):
    - [Deposit(msg.sender,_amount)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1571)

flattened/SigKSPFarmV1.sol#L1543-L1572

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-18
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L777-L785) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L782-L784)

flattened/SigKSPFarmV1.sol#L777-L785

- [ ]  ID-19
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L290-L310) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L302-L305)

flattened/SigKSPFarmV1.sol#L290-L310

- [ ]  ID-20
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L803-L811) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L808-L810)

flattened/SigKSPFarmV1.sol#L803-L811

- [ ]  ID-21
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L816-L824) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L821-L823)

flattened/SigKSPFarmV1.sol#L816-L824

- [ ]  ID-22
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L790-L798) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L795-L797)

flattened/SigKSPFarmV1.sol#L790-L798

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-23
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L604-L606) is never used and should be removed

flattened/SigKSPFarmV1.sol#L604-L606

- [ ]  ID-24
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L210-L222) is never used and should be removed

flattened/SigKSPFarmV1.sol#L210-L222

- [ ]  ID-25
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L355-L371) is never used and should be removed

flattened/SigKSPFarmV1.sol#L355-L371

- [ ]  ID-26
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L838) is never used and should be removed

flattened/SigKSPFarmV1.sol#L838

- [ ]  ID-27
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L373-L387) is never used and should be removed

flattened/SigKSPFarmV1.sol#L373-L387

- [ ]  ID-28
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L178-L183) is never used and should be removed

flattened/SigKSPFarmV1.sol#L178-L183

- [ ]  ID-29
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L990-L992) is never used and should be removed

flattened/SigKSPFarmV1.sol#L990-L992

- [ ]  ID-30
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L598) is never used and should be removed

flattened/SigKSPFarmV1.sol#L598

- [ ]  ID-31
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L816-L824) is never used and should be removed

flattened/SigKSPFarmV1.sol#L816-L824

- [ ]  ID-32
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L147-L158) is never used and should be removed

flattened/SigKSPFarmV1.sol#L147-L158

- [ ]  ID-33
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L254-L265) is never used and should be removed

flattened/SigKSPFarmV1.sol#L254-L265

- [ ]  ID-34
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1017-L1030) is never used and should be removed

flattened/SigKSPFarmV1.sol#L1017-L1030

- [ ]  ID-35
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L389-L410) is never used and should be removed

flattened/SigKSPFarmV1.sol#L389-L410

- [ ]  ID-36
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L997-L1009) is never used and should be removed

flattened/SigKSPFarmV1.sol#L997-L1009

- [ ]  ID-37
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1082) is never used and should be removed

flattened/SigKSPFarmV1.sol#L1082

- [ ]  ID-38
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L836) is never used and should be removed

flattened/SigKSPFarmV1.sol#L836

- [ ]  ID-39
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L957-L963) is never used and should be removed

flattened/SigKSPFarmV1.sol#L957-L963

- [ ]  ID-40
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1084) is never used and should be removed

flattened/SigKSPFarmV1.sol#L1084

- [ ]  ID-41
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L803-L811) is never used and should be removed

flattened/SigKSPFarmV1.sol#L803-L811

- [ ]  ID-42
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L970-L973) is never used and should be removed

flattened/SigKSPFarmV1.sol#L970-L973

- [ ]  ID-43
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L950-L952) is never used and should be removed

flattened/SigKSPFarmV1.sol#L950-L952

- [ ]  ID-44
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L273-L282) is never used and should be removed

flattened/SigKSPFarmV1.sol#L273-L282

- [ ]  ID-45
[Initializable._disableInitializers()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L560-L562) is never used and should be removed

flattened/SigKSPFarmV1.sol#L560-L562

- [ ]  ID-46
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L596) is never used and should be removed

flattened/SigKSPFarmV1.sol#L596

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-47
Pragma version[^0.8.0](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L6) allows old versions

flattened/SigKSPFarmV1.sol#L6

- [ ]  ID-48
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-49
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1038-L1055):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1048)

flattened/SigKSPFarmV1.sol#L1038-L1055

- [ ]  ID-50
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L147-L158):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L153)

flattened/SigKSPFarmV1.sol#L147-L158

- [ ]  ID-51
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L230-L246):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L242-L244)

flattened/SigKSPFarmV1.sol#L230-L246

- [ ]  ID-52
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L273-L282):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L280)

flattened/SigKSPFarmV1.sol#L273-L282

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-53
Parameter [SigKSPFarmV1.fund(uint256)._amount](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1662) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1662

- [ ]  ID-54
Parameter [SigKSPFarmV1.deposited(address)._user](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1857) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1857

- [ ]  ID-55
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L838) is not in mixedCase

flattened/SigKSPFarmV1.sol#L838

- [ ]  ID-56
Parameter [SigKSPFarmV1.setBaseAndBoostAllocPoint(uint256,uint256)._baseAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1512) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1512

- [ ]  ID-57
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._rewardPerBlock](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1483) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1483

- [ ]  ID-58
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L613) is not in mixedCase

flattened/SigKSPFarmV1.sol#L613

- [ ]  ID-59
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1226-L1228) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1226-L1228

- [ ]  ID-60
Parameter [SigKSPFarmV1.deposit(uint256)._amount](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1543) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1543

- [ ]  ID-61
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L639-L641) is not in mixedCase

flattened/SigKSPFarmV1.sol#L639-L641

- [ ]  ID-62
Parameter [SigKSPFarmV1.boostPending(address)._user](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1821) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1821

- [ ]  ID-63
Parameter [SigKSPFarmV1.setRewardPerBlock(uint256)._rewardPerBlock](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1524) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1524

- [ ]  ID-64
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L700) is not in mixedCase

flattened/SigKSPFarmV1.sol#L700

- [ ]  ID-65
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1186) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1186

- [ ]  ID-66
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._baseAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1485) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1485

- [ ]  ID-67
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1352) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1352

- [ ]  ID-68
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._boostAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1486) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1486

- [ ]  ID-69
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1062) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1062

- [ ]  ID-70
Parameter [SigKSPFarmV1.basePending(address)._user](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1792) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1792

- [ ]  ID-71
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1222-L1224) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1222-L1224

- [ ]  ID-72
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._vxSIG](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1482) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1482

- [ ]  ID-73
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L598) is not in mixedCase

flattened/SigKSPFarmV1.sol#L598

- [ ]  ID-74
Parameter [SigKSPFarmV1.withdraw(uint256)._amount](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1578) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1578

- [ ]  ID-75
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1084) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1084

- [ ]  ID-76
Parameter [SigKSPFarmV1.setBaseAndBoostAllocPoint(uint256,uint256)._boostAllocPoint](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1513) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1513

- [ ]  ID-77
Variable [ReentrancyGuardUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1256) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1256

- [ ]  ID-78
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._sig](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1480) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1480

- [ ]  ID-79
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._startBlock](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1484) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1484

- [ ]  ID-80
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L643-L645) is not in mixedCase

flattened/SigKSPFarmV1.sol#L643-L645

- [ ]  ID-81
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1087) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1087

- [ ]  ID-82
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L836) is not in mixedCase

flattened/SigKSPFarmV1.sol#L836

- [ ]  ID-83
Parameter [SigKSPFarmV1.setInitialInfo(address,address,address,uint256,uint256,uint256,uint256)._sigKSP](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1481) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1481

- [ ]  ID-84
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1082) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1082

- [ ]  ID-85
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1284-L1286) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1284-L1286

- [ ]  ID-86
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L596) is not in mixedCase

flattened/SigKSPFarmV1.sol#L596

- [ ]  ID-87
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1288-L1290) is not in mixedCase

flattened/SigKSPFarmV1.sol#L1288-L1290

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-88
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1352) is never used in [SigKSPFarmV1](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1374-L1861)

flattened/SigKSPFarmV1.sol#L1352

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-89
fund(uint256) should be declared external:
    - [SigKSPFarmV1.fund(uint256)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1662-L1670)

flattened/SigKSPFarmV1.sol#L1662-L1670

- [ ]  ID-90
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L677-L683)

flattened/SigKSPFarmV1.sol#L677-L683

- [ ]  ID-91
updateReward() should be declared external:
    - [SigKSPFarmV1.updateReward()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L1653-L1656)

flattened/SigKSPFarmV1.sol#L1653-L1656

- [ ]  ID-92
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/SigKSPFarmV1.sol#L669-L671)

flattened/SigKSPFarmV1.sol#L669-L671