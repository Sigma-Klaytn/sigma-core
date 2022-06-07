# 4. xSIGFarmV1.sol

- sigmaVoter, sigKSPFarm, lpFarm 이랑 함께 하는 테스트 해봐야함.

relatedContract: vxSIGToken.sol, Whitelist.sol

vxSIG is a voting escrow token for staked xSIG. Users may stake xSIG to start accrue vxSIG. vxSIG will accrue gradually over the time as xSIG is staked in the vxSIG vault. Users accrue 0.014 vxSIG per hour per xSIG, max capped at 100 vxSIG per xSIG. Meaning that it takes slightly less than 300 days to reach maximum vxSIG per xSIG. The user starts with 0.014 vxSIG per xSIG once staked. No unstaking period is related with vxSIG. vxSIG is fully resetted if any xSIG is unstaked from the vault.

```solidity
vxSIG = Qty xSIG staked * (hours xSIG staked +1) * 0.014
```

# ✨ Resolved Issue ( 0 issue)

---

# Summary

- [controlled-delegatecall](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#controlled-delegatecall) (1 results) (High)
- [unprotected-upgrade](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#unprotected-upgrade) (1 results) (High)
- [reentrancy-no-eth](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#reentrancy-no-eth) (1 results) (Medium)
- [tx-origin](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#tx-origin) (1 results) (Medium)
- [uninitialized-local](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#uninitialized-local) (1 results) (Medium)
- [unused-return](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#unused-return) (1 results) (Medium)
- [events-maths](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#events-maths) (2 results) (Low)
- [variable-scope](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#variable-scope) (1 results) (Low)
- [reentrancy-events](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#reentrancy-events) (3 results) (Low)
- [timestamp](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#timestamp) (4 results) (Low)
- [assembly](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#assembly) (5 results) (Informational)
- [dead-code](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#dead-code) (28 results) (Informational)
- [solc-version](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#naming-convention) (33 results) (Informational)
- [too-many-digits](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#too-many-digits) (1 results) (Informational)
- [unused-state](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/4-xSIGFarm-sol-06ca68a7fb214beab94442011951337e#external-function) (2 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1042-L1059) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1052)

flattened/xSigFarmV1.sol#L1042-L1059

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-1
[xSigFarmV1](notion://www.notion.so/flattened/xSigFarmV1.sol#L1506-L1831) is an upgradeable contract that does not protect its initiliaze functions: [xSigFarmV1.initialize()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1561-L1565). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1150-L1153)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1163-L1171)
flattened/xSigFarmV1.sol#L1506-L1831

## reentrancy-no-eth

comment : ignored.

Impact: Medium
Confidence: Medium

- [ ]  ID-2
Reentrancy in [xSigFarmV1.stake(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1658-L1680):
External calls:
    - [_claim(msg.sender)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1669)
        - [vxSIG.mint(_address,amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1758)
        State variables written after the call(s):
    - [userInfo.stakedXSIG += _amount](notion://www.notion.so/flattened/xSigFarmV1.sol#L1676)

flattened/xSigFarmV1.sol#L1658-L1680

## tx-origin

comment : tx-origin is not used for authorization. so it should be fine. (ref : [https://github.com/crytic/slither/wiki/Detector-Documentation#exploit-scenario-63](https://github.com/crytic/slither/wiki/Detector-Documentation#exploit-scenario-63))

Impact: Medium
Confidence: Medium

- [ ]  ID-3
[xSigFarmV1._assertNotContract(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1738-L1745) uses tx.origin for authorization: [_address != tx.origin](notion://www.notion.so/flattened/xSigFarmV1.sol#L1739)

flattened/xSigFarmV1.sol#L1738-L1745

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-4
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/xSigFarmV1.sol#L926) is a local variable never initialized

flattened/xSigFarmV1.sol#L926

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-5
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/xSigFarmV1.sol#L913-L936) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/xSigFarmV1.sol#L924-L933)

flattened/xSigFarmV1.sol#L913-L936

## events-maths

Impact: Low
Confidence: Medium

- [ ]  ID-6
[xSigFarmV1.setMaxVxSIGPerXSIG(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1633-L1640) should emit an event for:
    - [maxVxSIGPerXSIG = _maxVxSIGPerXSIG](notion://www.notion.so/flattened/xSigFarmV1.sol#L1639)

flattened/xSigFarmV1.sol#L1633-L1640

- [ ]  ID-7
[xSigFarmV1.setGenerationRate(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1619-L1627) should emit an event for:
    - [generationRate = _generationRate](notion://www.notion.so/flattened/xSigFarmV1.sol#L1626)

flattened/xSigFarmV1.sol#L1619-L1627

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-8
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/xSigFarmV1.sol#L926)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/xSigFarmV1.sol#L913-L936) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/xSigFarmV1.sol#L927-L930)

flattened/xSigFarmV1.sol#L926

## reentrancy-events

Impact: Low
Confidence: Medium

- [ ]  ID-9
Reentrancy in [xSigFarmV1.unstake(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1687-L1722):
External calls:
    - [vxSIG.burn(msg.sender,uservxSIGBalance)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1709)
    - [xSIG.safeTransfer(msg.sender,_amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1711)
    - [sigmaVoter.deleteAllPoolVote()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1715)
    - [lpFarm.updateBoostWeight()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1718)
    - [sigKSPFarm.updateBoostWeight()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1719)
    Event emitted after the call(s):
    - [Unstaked(msg.sender,_amount,userInfo.stakedXSIG)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1721)

flattened/xSigFarmV1.sol#L1687-L1722

- [ ]  ID-10
Reentrancy in [xSigFarmV1._claim(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1751-L1761):
External calls:
    - [vxSIG.mint(_address,amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1758)
    Event emitted after the call(s):
    - [Claimed(_address,amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1759)

flattened/xSigFarmV1.sol#L1751-L1761

- [ ]  ID-11
Reentrancy in [xSigFarmV1.stake(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1658-L1680):
External calls:
    - [_claim(msg.sender)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1669)
        - [vxSIG.mint(_address,amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1758)
    - [xSIG.safeTransferFrom(msg.sender,address(this),_amount)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1677)
    Event emitted after the call(s):
    - [Staked(msg.sender,_amount,userInfo.stakedXSIG)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1679)

flattened/xSigFarmV1.sol#L1658-L1680

## timestamp

Impact: Low
Confidence: Medium

- [ ]  ID-12
[xSigFarmV1.isUser(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1803-L1805) uses timestamp for comparisons
Dangerous comparisons:
    - [userInfoOf[_address].stakedXSIG > 0](notion://www.notion.so/flattened/xSigFarmV1.sol#L1804)

flattened/xSigFarmV1.sol#L1803-L1805

- [ ]  ID-13
[xSigFarmV1.unstake(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1687-L1722) uses timestamp for comparisons
Dangerous comparisons:
    - [require(bool,string)(userInfo.stakedXSIG >= _amount,Insuffcient xSIG to unstake)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1695)

flattened/xSigFarmV1.sol#L1687-L1722

- [ ]  ID-14
[xSigFarmV1._claim(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1751-L1761) uses timestamp for comparisons
Dangerous comparisons:
    - [amount > 0](notion://www.notion.so/flattened/xSigFarmV1.sol#L1757)

flattened/xSigFarmV1.sol#L1751-L1761

- [ ]  ID-15
[xSigFarmV1._claimable(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1767-L1794) uses timestamp for comparisons
Dangerous comparisons:
    - [userVxSIGBalance < maxVxSIGCap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1785)
    - [(userVxSIGBalance + pending) > maxVxSIGCap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1787)

flattened/xSigFarmV1.sol#L1767-L1794

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-16
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L807-L815) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/xSigFarmV1.sol#L812-L814)

flattened/xSigFarmV1.sol#L807-L815

- [ ]  ID-17
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L794-L802) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/xSigFarmV1.sol#L799-L801)

flattened/xSigFarmV1.sol#L794-L802

- [ ]  ID-18
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L781-L789) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/xSigFarmV1.sol#L786-L788)

flattened/xSigFarmV1.sol#L781-L789

- [ ]  ID-19
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/xSigFarmV1.sol#L205-L225) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/xSigFarmV1.sol#L217-L220)

flattened/xSigFarmV1.sol#L205-L225

- [ ]  ID-20
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L820-L828) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/xSigFarmV1.sol#L825-L827)

flattened/xSigFarmV1.sol#L820-L828

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-21
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/xSigFarmV1.sol#L395-L397) is never used and should be removed

flattened/xSigFarmV1.sol#L395-L397

- [ ]  ID-22
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L125-L137) is never used and should be removed

flattened/xSigFarmV1.sol#L125-L137

- [ ]  ID-23
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L623-L639) is never used and should be removed

flattened/xSigFarmV1.sol#L623-L639

- [ ]  ID-24
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L842) is never used and should be removed

flattened/xSigFarmV1.sol#L842

- [ ]  ID-25
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L641-L655) is never used and should be removed

flattened/xSigFarmV1.sol#L641-L655

- [ ]  ID-26
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/xSigFarmV1.sol#L93-L98) is never used and should be removed

flattened/xSigFarmV1.sol#L93-L98

- [ ]  ID-27
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/xSigFarmV1.sol#L994-L996) is never used and should be removed

flattened/xSigFarmV1.sol#L994-L996

- [ ]  ID-28
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L389) is never used and should be removed

flattened/xSigFarmV1.sol#L389

- [ ]  ID-29
[DSMath.reciprocal(uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1469-L1471) is never used and should be removed

flattened/xSigFarmV1.sol#L1469-L1471

- [ ]  ID-30
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L820-L828) is never used and should be removed

flattened/xSigFarmV1.sol#L820-L828

- [ ]  ID-31
[DSMath.rpow(uint256,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1488-L1498) is never used and should be removed

flattened/xSigFarmV1.sol#L1488-L1498

- [ ]  ID-32
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L62-L73) is never used and should be removed

flattened/xSigFarmV1.sol#L62-L73

- [ ]  ID-33
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/xSigFarmV1.sol#L169-L180) is never used and should be removed

flattened/xSigFarmV1.sol#L169-L180

- [ ]  ID-34
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1021-L1034) is never used and should be removed

flattened/xSigFarmV1.sol#L1021-L1034

- [ ]  ID-35
[DSMath.wdiv(uint256,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1465-L1467) is never used and should be removed

flattened/xSigFarmV1.sol#L1465-L1467

- [ ]  ID-36
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L657-L678) is never used and should be removed

flattened/xSigFarmV1.sol#L657-L678

- [ ]  ID-37
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1001-L1013) is never used and should be removed

flattened/xSigFarmV1.sol#L1001-L1013

- [ ]  ID-38
[DSMath.rmul(uint256,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1501-L1503) is never used and should be removed

flattened/xSigFarmV1.sol#L1501-L1503

- [ ]  ID-39
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1086) is never used and should be removed

flattened/xSigFarmV1.sol#L1086

- [ ]  ID-40
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L840) is never used and should be removed

flattened/xSigFarmV1.sol#L840

- [ ]  ID-41
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L961-L967) is never used and should be removed

flattened/xSigFarmV1.sol#L961-L967

- [ ]  ID-42
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1088) is never used and should be removed

flattened/xSigFarmV1.sol#L1088

- [ ]  ID-43
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/xSigFarmV1.sol#L807-L815) is never used and should be removed

flattened/xSigFarmV1.sol#L807-L815

- [ ]  ID-44
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L974-L977) is never used and should be removed

flattened/xSigFarmV1.sol#L974-L977

- [ ]  ID-45
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/xSigFarmV1.sol#L954-L956) is never used and should be removed

flattened/xSigFarmV1.sol#L954-L956

- [ ]  ID-46
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/xSigFarmV1.sol#L188-L197) is never used and should be removed

flattened/xSigFarmV1.sol#L188-L197

- [ ]  ID-47
[Initializable._disableInitializers()](notion://www.notion.so/flattened/xSigFarmV1.sol#L349-L351) is never used and should be removed

flattened/xSigFarmV1.sol#L349-L351

- [ ]  ID-48
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L387) is never used and should be removed

flattened/xSigFarmV1.sol#L387

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-49
Pragma version[^0.8.0](notion://www.notion.so/flattened/xSigFarmV1.sol#L6) allows old versions

flattened/xSigFarmV1.sol#L6

- [ ]  ID-50
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-51
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1042-L1059):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1052)

flattened/xSigFarmV1.sol#L1042-L1059

- [ ]  ID-52
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/xSigFarmV1.sol#L145-L161):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/xSigFarmV1.sol#L157-L159)

flattened/xSigFarmV1.sol#L145-L161

- [ ]  ID-53
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/xSigFarmV1.sol#L62-L73):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/xSigFarmV1.sol#L68)

flattened/xSigFarmV1.sol#L62-L73

- [ ]  ID-54
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/xSigFarmV1.sol#L188-L197):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/xSigFarmV1.sol#L195)

flattened/xSigFarmV1.sol#L188-L197

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-55
Parameter [xSigFarmV1.isUser(address)._address](notion://www.notion.so/flattened/xSigFarmV1.sol#L1803) is not in mixedCase

flattened/xSigFarmV1.sol#L1803

- [ ]  ID-56
Parameter [xSigFarmV1.setWhitelist(address)._whitelistAddr](notion://www.notion.so/flattened/xSigFarmV1.sol#L1646) is not in mixedCase

flattened/xSigFarmV1.sol#L1646

- [ ]  ID-57
Parameter [xSigFarmV1.setInitialInfo(address,address,address,address,address)._vxSIG](notion://www.notion.so/flattened/xSigFarmV1.sol#L1596) is not in mixedCase

flattened/xSigFarmV1.sol#L1596

- [ ]  ID-58
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L842) is not in mixedCase

flattened/xSigFarmV1.sol#L842

- [ ]  ID-59
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L404) is not in mixedCase

flattened/xSigFarmV1.sol#L404

- [ ]  ID-60
Parameter [xSigFarmV1.setInitialInfo(address,address,address,address,address)._sigKSPFarm](notion://www.notion.so/flattened/xSigFarmV1.sol#L1598) is not in mixedCase

flattened/xSigFarmV1.sol#L1598

- [ ]  ID-61
Parameter [xSigFarmV1.getStakedXSIG(address)._address](notion://www.notion.so/flattened/xSigFarmV1.sol#L1822) is not in mixedCase

flattened/xSigFarmV1.sol#L1822

- [ ]  ID-62
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1230-L1232) is not in mixedCase

flattened/xSigFarmV1.sol#L1230-L1232

- [ ]  ID-63
Parameter [xSigFarmV1.setMaxVxSIGPerXSIG(uint256)._maxVxSIGPerXSIG](notion://www.notion.so/flattened/xSigFarmV1.sol#L1633) is not in mixedCase

flattened/xSigFarmV1.sol#L1633

- [ ]  ID-64
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L432-L434) is not in mixedCase

flattened/xSigFarmV1.sol#L432-L434

- [ ]  ID-65
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L493) is not in mixedCase

flattened/xSigFarmV1.sol#L493

- [ ]  ID-66
Parameter [xSigFarmV1.setInitialInfo(address,address,address,address,address)._sigmaVoter](notion://www.notion.so/flattened/xSigFarmV1.sol#L1597) is not in mixedCase

flattened/xSigFarmV1.sol#L1597

- [ ]  ID-67
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1190) is not in mixedCase

flattened/xSigFarmV1.sol#L1190

- [ ]  ID-68
Parameter [xSigFarmV1.stake(uint256)._amount](notion://www.notion.so/flattened/xSigFarmV1.sol#L1658) is not in mixedCase

flattened/xSigFarmV1.sol#L1658

- [ ]  ID-69
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1356) is not in mixedCase

flattened/xSigFarmV1.sol#L1356

- [ ]  ID-70
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1066) is not in mixedCase

flattened/xSigFarmV1.sol#L1066

- [ ]  ID-71
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1226-L1228) is not in mixedCase

flattened/xSigFarmV1.sol#L1226-L1228

- [ ]  ID-72
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L389) is not in mixedCase

flattened/xSigFarmV1.sol#L389

- [ ]  ID-73
Parameter [xSigFarmV1.setInitialInfo(address,address,address,address,address)._xSIG](notion://www.notion.so/flattened/xSigFarmV1.sol#L1595) is not in mixedCase

flattened/xSigFarmV1.sol#L1595

- [ ]  ID-74
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1088) is not in mixedCase

flattened/xSigFarmV1.sol#L1088

- [ ]  ID-75
Variable [ReentrancyGuardUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1260) is not in mixedCase

flattened/xSigFarmV1.sol#L1260

- [ ]  ID-76
Parameter [xSigFarmV1.claimable(address)._address](notion://www.notion.so/flattened/xSigFarmV1.sol#L1813) is not in mixedCase

flattened/xSigFarmV1.sol#L1813

- [ ]  ID-77
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L436-L438) is not in mixedCase

flattened/xSigFarmV1.sol#L436-L438

- [ ]  ID-78
Parameter [xSigFarmV1.setInitialInfo(address,address,address,address,address)._lpFarm](notion://www.notion.so/flattened/xSigFarmV1.sol#L1599) is not in mixedCase

flattened/xSigFarmV1.sol#L1599

- [ ]  ID-79
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/xSigFarmV1.sol#L1091) is not in mixedCase

flattened/xSigFarmV1.sol#L1091

- [ ]  ID-80
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L840) is not in mixedCase

flattened/xSigFarmV1.sol#L840

- [ ]  ID-81
Contract [xSigFarmV1](notion://www.notion.so/flattened/xSigFarmV1.sol#L1506-L1831) is not in CapWords

flattened/xSigFarmV1.sol#L1506-L1831

- [ ]  ID-82
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1086) is not in mixedCase

flattened/xSigFarmV1.sol#L1086

- [ ]  ID-83
Parameter [xSigFarmV1.setGenerationRate(uint256)._generationRate](notion://www.notion.so/flattened/xSigFarmV1.sol#L1619) is not in mixedCase

flattened/xSigFarmV1.sol#L1619

- [ ]  ID-84
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1288-L1290) is not in mixedCase

flattened/xSigFarmV1.sol#L1288-L1290

- [ ]  ID-85
Parameter [xSigFarmV1.unstake(uint256)._amount](notion://www.notion.so/flattened/xSigFarmV1.sol#L1687) is not in mixedCase

flattened/xSigFarmV1.sol#L1687

- [ ]  ID-86
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/xSigFarmV1.sol#L387) is not in mixedCase

flattened/xSigFarmV1.sol#L387

- [ ]  ID-87
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/xSigFarmV1.sol#L1292-L1294) is not in mixedCase

flattened/xSigFarmV1.sol#L1292-L1294

## too-many-digits

Impact: Informational
Confidence: Medium

- [ ]  ID-88
[xSigFarmV1.setInitialInfo(address,address,address,address,address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L1594-L1613) uses literals with too many digits:
    - [maxVxSIGPerXSIG = 100000000000000000000](notion://www.notion.so/flattened/xSigFarmV1.sol#L1612)

flattened/xSigFarmV1.sol#L1594-L1613

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-89
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/xSigFarmV1.sol#L1356) is never used in [xSigFarmV1](notion://www.notion.so/flattened/xSigFarmV1.sol#L1506-L1831)

flattened/xSigFarmV1.sol#L1356

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-90
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/xSigFarmV1.sol#L470-L476)

flattened/xSigFarmV1.sol#L470-L476

- [ ]  ID-91
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/xSigFarmV1.sol#L462-L464)

flattened/xSigFarmV1.sol#L462-L464