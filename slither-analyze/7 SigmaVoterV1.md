# 7. SigmaVoterV1.sol

User votes for LP pools with vxSIG(which is accured from xSIG Farm) in this contract. 

- It is UUPS proxy pattern.

# **✨ Resolved Issue ( 1 issue)**

## uninitialized-local

**comment** : uint256 _minTopVoteIndexMem; → uint256 _minTopVoteIndexMem = 0; 

Impact: Medium
Confidence: Medium

- [ ]  ID-2
[SigmaVoterV1._findMinTopVote(uint64[13],uint256)._minTopVoteIndexMem](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1487) is a local variable never initialized

flattened/SigmaVoterV1.sol#L1487

---

# Summary

- [controlled-delegatecall](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#controlled-delegatecall) (1 results) (High)
- [unprotected-upgrade](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#unprotected-upgrade) (1 results) (High)
- [uninitialized-local](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#uninitialized-local) (2 results) (Medium)
- [unused-return](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#unused-return) (1 results) (Medium)
- [events-maths](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#events-maths) (1 results) (Low)
- [calls-loop](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#calls-loop) (1 results) (Low)
- [variable-scope](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#variable-scope) (1 results) (Low)
- [assembly](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#assembly) (6 results) (Informational)
- [costly-loop](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#costly-loop) (6 results) (Informational)
- [dead-code](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#dead-code) (23 results) (Informational)
- [solc-version](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#naming-convention) (31 results) (Informational)
- [unused-state](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/7-SigmaVoter-sol-dc6b6c2552934e51b3bb283d489273d0#external-function) (3 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L827-L844) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L837)

flattened/SigmaVoterV1.sol#L827-L844

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-1
[SigmaVoterV1](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1103-L1695) is an upgradeable contract that does not protect its initiliaze functions: [SigmaVoterV1.initialize()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1178-L1184). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L935-L938)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L948-L956)
flattened/SigmaVoterV1.sol#L1103-L1695

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-2
[SigmaVoterV1._findMinTopVote(uint64[13],uint256)._minTopVoteIndexMem](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1487) is a local variable never initialized

flattened/SigmaVoterV1.sol#L1487

- [ ]  ID-3
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigmaVoterV1.sol#L711) is a local variable never initialized

flattened/SigmaVoterV1.sol#L711

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-4
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L698-L721) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L709-L718)

flattened/SigmaVoterV1.sol#L698-L721

## events-maths

Impact: Low
Confidence: Medium

- [ ]  ID-5
[SigmaVoterV1.addAllPoolVote(address[],uint256[])](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1269-L1352) should emit an event for:
    - [totalUsedVxSIG += _totalVxSIGUsed](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1346)

flattened/SigmaVoterV1.sol#L1269-L1352

## calls-loop

Impact: Low
Confidence: Medium

- [ ]  ID-6
[SigmaVoterV1.availableVotes(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1674-L1678) has external calls inside a loop: [totalWeight = vxSIG.balanceOf(_user) / 1e18](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1676)

flattened/SigmaVoterV1.sol#L1674-L1678

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-7
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigmaVoterV1.sol#L711)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L698-L721) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L712-L715)

flattened/SigmaVoterV1.sol#L711

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-8
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L592-L600) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L597-L599)

flattened/SigmaVoterV1.sol#L592-L600

- [ ]  ID-9
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L579-L587) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L584-L586)

flattened/SigmaVoterV1.sol#L579-L587

- [ ]  ID-10
[SigmaVoterV1.getCurrentVotes()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1587-L1653) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1627-L1630)

flattened/SigmaVoterV1.sol#L1587-L1653

- [ ]  ID-11
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L205-L225) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L217-L220)

flattened/SigmaVoterV1.sol#L205-L225

- [ ]  ID-12
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L566-L574) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L571-L573)

flattened/SigmaVoterV1.sol#L566-L574

- [ ]  ID-13
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L605-L613) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigmaVoterV1.sol#L610-L612)

flattened/SigmaVoterV1.sol#L605-L613

## costly-loop

Impact: Informational
Confidence: Medium

- [ ]  ID-14
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [topVotesLength = _topVotesLengthMem](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1423)

flattened/SigmaVoterV1.sol#L1359-L1457

- [ ]  ID-15
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [topVotes = t](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1422)

flattened/SigmaVoterV1.sol#L1359-L1457

- [ ]  ID-16
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [minTopVoteIndex = _minTopVoteIndexMem](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1425)

flattened/SigmaVoterV1.sol#L1359-L1457

- [ ]  ID-17
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [totalUsedVxSIG -= _vxSIGAmount](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1369)

flattened/SigmaVoterV1.sol#L1359-L1457

- [ ]  ID-18
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [delete userPoolVotes[msg.sender]](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1452)

flattened/SigmaVoterV1.sol#L1359-L1457

- [ ]  ID-19
[SigmaVoterV1.deletePoolVote(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop:
    - [minTopVote = _minTopVoteMem](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1424)

flattened/SigmaVoterV1.sol#L1359-L1457

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-20
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L393-L395) is never used and should be removed

flattened/SigmaVoterV1.sol#L393-L395

- [ ]  ID-21
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L125-L137) is never used and should be removed

flattened/SigmaVoterV1.sol#L125-L137

- [ ]  ID-22
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L627) is never used and should be removed

flattened/SigmaVoterV1.sol#L627

- [ ]  ID-23
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L93-L98) is never used and should be removed

flattened/SigmaVoterV1.sol#L93-L98

- [ ]  ID-24
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L779-L781) is never used and should be removed

flattened/SigmaVoterV1.sol#L779-L781

- [ ]  ID-25
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L387) is never used and should be removed

flattened/SigmaVoterV1.sol#L387

- [ ]  ID-26
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L605-L613) is never used and should be removed

flattened/SigmaVoterV1.sol#L605-L613

- [ ]  ID-27
[AddressUpgradeable.functionCall(address,bytes,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L106-L112) is never used and should be removed

flattened/SigmaVoterV1.sol#L106-L112

- [ ]  ID-28
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L62-L73) is never used and should be removed

flattened/SigmaVoterV1.sol#L62-L73

- [ ]  ID-29
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L169-L180) is never used and should be removed

flattened/SigmaVoterV1.sol#L169-L180

- [ ]  ID-30
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L806-L819) is never used and should be removed

flattened/SigmaVoterV1.sol#L806-L819

- [ ]  ID-31
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L786-L798) is never used and should be removed

flattened/SigmaVoterV1.sol#L786-L798

- [ ]  ID-32
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L871) is never used and should be removed

flattened/SigmaVoterV1.sol#L871

- [ ]  ID-33
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L625) is never used and should be removed

flattened/SigmaVoterV1.sol#L625

- [ ]  ID-34
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L746-L752) is never used and should be removed

flattened/SigmaVoterV1.sol#L746-L752

- [ ]  ID-35
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L873) is never used and should be removed

flattened/SigmaVoterV1.sol#L873

- [ ]  ID-36
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L592-L600) is never used and should be removed

flattened/SigmaVoterV1.sol#L592-L600

- [ ]  ID-37
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L759-L762) is never used and should be removed

flattened/SigmaVoterV1.sol#L759-L762

- [ ]  ID-38
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L739-L741) is never used and should be removed

flattened/SigmaVoterV1.sol#L739-L741

- [ ]  ID-39
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L188-L197) is never used and should be removed

flattened/SigmaVoterV1.sol#L188-L197

- [ ]  ID-40
[Initializable._disableInitializers()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L349-L351) is never used and should be removed

flattened/SigmaVoterV1.sol#L349-L351

- [ ]  ID-41
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L385) is never used and should be removed

flattened/SigmaVoterV1.sol#L385

- [ ]  ID-42
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L145-L161) is never used and should be removed

flattened/SigmaVoterV1.sol#L145-L161

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-43
Pragma version[^0.8.0](notion://www.notion.so/flattened/SigmaVoterV1.sol#L6) allows old versions

flattened/SigmaVoterV1.sol#L6

- [ ]  ID-44
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-45
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L62-L73):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L68)

flattened/SigmaVoterV1.sol#L62-L73

- [ ]  ID-46
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L188-L197):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L195)

flattened/SigmaVoterV1.sol#L188-L197

- [ ]  ID-47
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L827-L844):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L837)

flattened/SigmaVoterV1.sol#L827-L844

- [ ]  ID-48
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L145-L161):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L157-L159)

flattened/SigmaVoterV1.sol#L145-L161

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-49
Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256)._userMaxVote](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1214) is not in mixedCase

flattened/SigmaVoterV1.sol#L1214

- [ ]  ID-50
Parameter [SigmaVoterV1.isPool(address)._pool](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1658) is not in mixedCase

flattened/SigmaVoterV1.sol#L1658

- [ ]  ID-51
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L627) is not in mixedCase

flattened/SigmaVoterV1.sol#L627

- [ ]  ID-52
Parameter [SigmaVoterV1.setTopYieldPools(address[])._pools](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1233) is not in mixedCase

flattened/SigmaVoterV1.sol#L1233

- [ ]  ID-53
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L402) is not in mixedCase

flattened/SigmaVoterV1.sol#L402

- [ ]  ID-54
Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256)._lpPools](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1211) is not in mixedCase

flattened/SigmaVoterV1.sol#L1211

- [ ]  ID-55
Parameter [SigmaVoterV1.addAllPoolVote(address[],uint256[])._pools](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1270) is not in mixedCase

flattened/SigmaVoterV1.sol#L1270

- [ ]  ID-56
Parameter [SigmaVoterV1.getUserVotesCount(address)._user](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1683) is not in mixedCase

flattened/SigmaVoterV1.sol#L1683

- [ ]  ID-57
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L428-L430) is not in mixedCase

flattened/SigmaVoterV1.sol#L428-L430

- [ ]  ID-58
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L489) is not in mixedCase

flattened/SigmaVoterV1.sol#L489

- [ ]  ID-59
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L975) is not in mixedCase

flattened/SigmaVoterV1.sol#L975

- [ ]  ID-60
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1071) is not in mixedCase

flattened/SigmaVoterV1.sol#L1071

- [ ]  ID-61
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L851) is not in mixedCase

flattened/SigmaVoterV1.sol#L851

- [ ]  ID-62
Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256)._vxSIG](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1213) is not in mixedCase

flattened/SigmaVoterV1.sol#L1213

- [ ]  ID-63
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L387) is not in mixedCase

flattened/SigmaVoterV1.sol#L387

- [ ]  ID-64
Parameter [SigmaVoterV1.deletePoolVote(address,uint256)._vxSIGAmount](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359) is not in mixedCase

flattened/SigmaVoterV1.sol#L1359

- [ ]  ID-65
Parameter [SigmaVoterV1.addPool(address)._pool](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1247) is not in mixedCase

flattened/SigmaVoterV1.sol#L1247

- [ ]  ID-66
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L873) is not in mixedCase

flattened/SigmaVoterV1.sol#L873

- [ ]  ID-67
Parameter [SigmaVoterV1.availableVotes(address)._user](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1674) is not in mixedCase

flattened/SigmaVoterV1.sol#L1674

- [ ]  ID-68
Parameter [SigmaVoterV1.addAllPoolVote(address[],uint256[])._vxSIGAmounts](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1271) is not in mixedCase

flattened/SigmaVoterV1.sol#L1271

- [ ]  ID-69
Parameter [SigmaVoterV1.deletePoolVote(address,uint256)._pool](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1359) is not in mixedCase

flattened/SigmaVoterV1.sol#L1359

- [ ]  ID-70
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L432-L434) is not in mixedCase

flattened/SigmaVoterV1.sol#L432-L434

- [ ]  ID-71
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/SigmaVoterV1.sol#L876) is not in mixedCase

flattened/SigmaVoterV1.sol#L876

- [ ]  ID-72
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L625) is not in mixedCase

flattened/SigmaVoterV1.sol#L625

- [ ]  ID-73
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L871) is not in mixedCase

flattened/SigmaVoterV1.sol#L871

- [ ]  ID-74
Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256)._topYieldPools](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1212) is not in mixedCase

flattened/SigmaVoterV1.sol#L1212

- [ ]  ID-75
Variable [SigmaVoterV1.USER_MAX_VOTE_POOL](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1123) is not in mixedCase

flattened/SigmaVoterV1.sol#L1123

- [ ]  ID-76
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1003-L1005) is not in mixedCase

flattened/SigmaVoterV1.sol#L1003-L1005

- [ ]  ID-77
Parameter [SigmaVoterV1.setUserMaxVotePool(uint256)._value](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1240) is not in mixedCase

flattened/SigmaVoterV1.sol#L1240

- [ ]  ID-78
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L385) is not in mixedCase

flattened/SigmaVoterV1.sol#L385

- [ ]  ID-79
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1007-L1009) is not in mixedCase

flattened/SigmaVoterV1.sol#L1007-L1009

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-80
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1071) is never used in [SigmaVoterV1](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1103-L1695)

flattened/SigmaVoterV1.sol#L1071

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-81
getPoolCount() should be declared external:
    - [SigmaVoterV1.getPoolCount()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L1665-L1667)

flattened/SigmaVoterV1.sol#L1665-L1667

- [ ]  ID-82
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/SigmaVoterV1.sol#L466-L472)

flattened/SigmaVoterV1.sol#L466-L472

- [ ]  ID-83
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/SigmaVoterV1.sol#L458-L460)

flattened/SigmaVoterV1.sol#L458-L460