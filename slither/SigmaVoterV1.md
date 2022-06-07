Summary

-   [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
-   [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
-   [uninitialized-local](#uninitialized-local) (1 results) (Medium)
-   [unused-return](#unused-return) (1 results) (Medium)
-   [events-maths](#events-maths) (1 results) (Low)
-   [calls-loop](#calls-loop) (1 results) (Low)
-   [variable-scope](#variable-scope) (1 results) (Low)
-   [assembly](#assembly) (6 results) (Informational)
-   [costly-loop](#costly-loop) (6 results) (Informational)
-   [dead-code](#dead-code) (23 results) (Informational)
-   [solc-version](#solc-version) (2 results) (Informational)
-   [low-level-calls](#low-level-calls) (4 results) (Informational)
-   [naming-convention](#naming-convention) (31 results) (Informational)
-   [unused-state](#unused-state) (1 results) (Informational)
-   [external-function](#external-function) (3 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

-   [ ] ID-0
        [ERC1967UpgradeUpgradeable.\_functionDelegateCall(address,bytes)](flattened/SigmaVoterV1.sol#L827-L844) uses delegatecall to a input-controlled function id - [(success,returndata) = target.delegatecall(data)](flattened/SigmaVoterV1.sol#L837)

flattened/SigmaVoterV1.sol#L827-L844

## unprotected-upgrade

Impact: High
Confidence: High

-   [ ] ID-1
        [SigmaVoterV1](flattened/SigmaVoterV1.sol#L1103-L1695) is an upgradeable contract that does not protect its initiliaze functions: [SigmaVoterV1.initialize()](flattened/SigmaVoterV1.sol#L1178-L1184). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/SigmaVoterV1.sol#L935-L938)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/SigmaVoterV1.sol#L948-L956)
        flattened/SigmaVoterV1.sol#L1103-L1695

## uninitialized-local

Impact: Medium
Confidence: Medium

-   [ ] ID-2
        [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigmaVoterV1.sol#L711) is a local variable never initialized

flattened/SigmaVoterV1.sol#L711

## unused-return

Impact: Medium
Confidence: Medium

-   [ ] ID-3
        [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigmaVoterV1.sol#L698-L721) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/SigmaVoterV1.sol#L709-L718)

flattened/SigmaVoterV1.sol#L698-L721

## events-maths

Impact: Low
Confidence: Medium

-   [ ] ID-4
        [SigmaVoterV1.addAllPoolVote(address[],uint256[])](flattened/SigmaVoterV1.sol#L1269-L1352) should emit an event for: - [totalUsedVxSIG += \_totalVxSIGUsed](flattened/SigmaVoterV1.sol#L1346)

flattened/SigmaVoterV1.sol#L1269-L1352

## calls-loop

Impact: Low
Confidence: Medium

-   [ ] ID-5
        [SigmaVoterV1.availableVotes(address)](flattened/SigmaVoterV1.sol#L1674-L1678) has external calls inside a loop: [totalWeight = vxSIG.balanceOf(\_user) / 1e18](flattened/SigmaVoterV1.sol#L1676)

flattened/SigmaVoterV1.sol#L1674-L1678

## variable-scope

Impact: Low
Confidence: High

-   [ ] ID-6
        Variable '[ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigmaVoterV1.sol#L711)' in [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigmaVoterV1.sol#L698-L721) potentially used before declaration: [require(bool,string)(slot == \_IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/SigmaVoterV1.sol#L712-L715)

flattened/SigmaVoterV1.sol#L711

## assembly

Impact: Informational
Confidence: High

-   [ ] ID-7
        [StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigmaVoterV1.sol#L592-L600) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L597-L599)

flattened/SigmaVoterV1.sol#L592-L600

-   [ ] ID-8
        [StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/SigmaVoterV1.sol#L579-L587) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L584-L586)

flattened/SigmaVoterV1.sol#L579-L587

-   [ ] ID-9
        [SigmaVoterV1.getCurrentVotes()](flattened/SigmaVoterV1.sol#L1587-L1653) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L1627-L1630)

flattened/SigmaVoterV1.sol#L1587-L1653

-   [ ] ID-10
        [AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/SigmaVoterV1.sol#L205-L225) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L217-L220)

flattened/SigmaVoterV1.sol#L205-L225

-   [ ] ID-11
        [StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/SigmaVoterV1.sol#L566-L574) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L571-L573)

flattened/SigmaVoterV1.sol#L566-L574

-   [ ] ID-12
        [StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigmaVoterV1.sol#L605-L613) uses assembly - [INLINE ASM](flattened/SigmaVoterV1.sol#L610-L612)

flattened/SigmaVoterV1.sol#L605-L613

## costly-loop

Impact: Informational
Confidence: Medium

-   [ ] ID-13
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [topVotesLength = \_topVotesLengthMem](flattened/SigmaVoterV1.sol#L1423)

flattened/SigmaVoterV1.sol#L1359-L1457

-   [ ] ID-14
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [topVotes = t](flattened/SigmaVoterV1.sol#L1422)

flattened/SigmaVoterV1.sol#L1359-L1457

-   [ ] ID-15
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [minTopVoteIndex = \_minTopVoteIndexMem](flattened/SigmaVoterV1.sol#L1425)

flattened/SigmaVoterV1.sol#L1359-L1457

-   [ ] ID-16
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [totalUsedVxSIG -= \_vxSIGAmount](flattened/SigmaVoterV1.sol#L1369)

flattened/SigmaVoterV1.sol#L1359-L1457

-   [ ] ID-17
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [delete userPoolVotes[msg.sender]](flattened/SigmaVoterV1.sol#L1452)

flattened/SigmaVoterV1.sol#L1359-L1457

-   [ ] ID-18
        [SigmaVoterV1.deletePoolVote(address,uint256)](flattened/SigmaVoterV1.sol#L1359-L1457) has costly operations inside a loop: - [minTopVote = \_minTopVoteMem](flattened/SigmaVoterV1.sol#L1424)

flattened/SigmaVoterV1.sol#L1359-L1457

## dead-code

Impact: Informational
Confidence: Medium

-   [ ] ID-19
        [ContextUpgradeable.\_msgData()](flattened/SigmaVoterV1.sol#L393-L395) is never used and should be removed

flattened/SigmaVoterV1.sol#L393-L395

-   [ ] ID-20
        [AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/SigmaVoterV1.sol#L125-L137) is never used and should be removed

flattened/SigmaVoterV1.sol#L125-L137

-   [ ] ID-21
        [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init_unchained()](flattened/SigmaVoterV1.sol#L627) is never used and should be removed

flattened/SigmaVoterV1.sol#L627

-   [ ] ID-22
        [AddressUpgradeable.functionCall(address,bytes)](flattened/SigmaVoterV1.sol#L93-L98) is never used and should be removed

flattened/SigmaVoterV1.sol#L93-L98

-   [ ] ID-23
        [ERC1967UpgradeUpgradeable.\_getBeacon()](flattened/SigmaVoterV1.sol#L779-L781) is never used and should be removed

flattened/SigmaVoterV1.sol#L779-L781

-   [ ] ID-24
        [ContextUpgradeable.\_\_Context_init_unchained()](flattened/SigmaVoterV1.sol#L387) is never used and should be removed

flattened/SigmaVoterV1.sol#L387

-   [ ] ID-25
        [StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigmaVoterV1.sol#L605-L613) is never used and should be removed

flattened/SigmaVoterV1.sol#L605-L613

-   [ ] ID-26
        [AddressUpgradeable.functionCall(address,bytes,string)](flattened/SigmaVoterV1.sol#L106-L112) is never used and should be removed

flattened/SigmaVoterV1.sol#L106-L112

-   [ ] ID-27
        [AddressUpgradeable.sendValue(address,uint256)](flattened/SigmaVoterV1.sol#L62-L73) is never used and should be removed

flattened/SigmaVoterV1.sol#L62-L73

-   [ ] ID-28
        [AddressUpgradeable.functionStaticCall(address,bytes)](flattened/SigmaVoterV1.sol#L169-L180) is never used and should be removed

flattened/SigmaVoterV1.sol#L169-L180

-   [ ] ID-29
        [ERC1967UpgradeUpgradeable.\_upgradeBeaconToAndCall(address,bytes,bool)](flattened/SigmaVoterV1.sol#L806-L819) is never used and should be removed

flattened/SigmaVoterV1.sol#L806-L819

-   [ ] ID-30
        [ERC1967UpgradeUpgradeable.\_setBeacon(address)](flattened/SigmaVoterV1.sol#L786-L798) is never used and should be removed

flattened/SigmaVoterV1.sol#L786-L798

-   [ ] ID-31
        [UUPSUpgradeable.\_\_UUPSUpgradeable_init()](flattened/SigmaVoterV1.sol#L871) is never used and should be removed

flattened/SigmaVoterV1.sol#L871

-   [ ] ID-32
        [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init()](flattened/SigmaVoterV1.sol#L625) is never used and should be removed

flattened/SigmaVoterV1.sol#L625

-   [ ] ID-33
        [ERC1967UpgradeUpgradeable.\_setAdmin(address)](flattened/SigmaVoterV1.sol#L746-L752) is never used and should be removed

flattened/SigmaVoterV1.sol#L746-L752

-   [ ] ID-34
        [UUPSUpgradeable.\_\_UUPSUpgradeable_init_unchained()](flattened/SigmaVoterV1.sol#L873) is never used and should be removed

flattened/SigmaVoterV1.sol#L873

-   [ ] ID-35
        [StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigmaVoterV1.sol#L592-L600) is never used and should be removed

flattened/SigmaVoterV1.sol#L592-L600

-   [ ] ID-36
        [ERC1967UpgradeUpgradeable.\_changeAdmin(address)](flattened/SigmaVoterV1.sol#L759-L762) is never used and should be removed

flattened/SigmaVoterV1.sol#L759-L762

-   [ ] ID-37
        [ERC1967UpgradeUpgradeable.\_getAdmin()](flattened/SigmaVoterV1.sol#L739-L741) is never used and should be removed

flattened/SigmaVoterV1.sol#L739-L741

-   [ ] ID-38
        [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigmaVoterV1.sol#L188-L197) is never used and should be removed

flattened/SigmaVoterV1.sol#L188-L197

-   [ ] ID-39
        [Initializable.\_disableInitializers()](flattened/SigmaVoterV1.sol#L349-L351) is never used and should be removed

flattened/SigmaVoterV1.sol#L349-L351

-   [ ] ID-40
        [ContextUpgradeable.\_\_Context_init()](flattened/SigmaVoterV1.sol#L385) is never used and should be removed

flattened/SigmaVoterV1.sol#L385

-   [ ] ID-41
        [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/SigmaVoterV1.sol#L145-L161) is never used and should be removed

flattened/SigmaVoterV1.sol#L145-L161

## solc-version

Impact: Informational
Confidence: High

-   [ ] ID-42
        Pragma version[^0.8.0](flattened/SigmaVoterV1.sol#L6) allows old versions

flattened/SigmaVoterV1.sol#L6

-   [ ] ID-43
        solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

-   [ ] ID-44
        Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/SigmaVoterV1.sol#L62-L73): - [(success) = recipient.call{value: amount}()](flattened/SigmaVoterV1.sol#L68)

flattened/SigmaVoterV1.sol#L62-L73

-   [ ] ID-45
        Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigmaVoterV1.sol#L188-L197): - [(success,returndata) = target.staticcall(data)](flattened/SigmaVoterV1.sol#L195)

flattened/SigmaVoterV1.sol#L188-L197

-   [ ] ID-46
        Low level call in [ERC1967UpgradeUpgradeable.\_functionDelegateCall(address,bytes)](flattened/SigmaVoterV1.sol#L827-L844): - [(success,returndata) = target.delegatecall(data)](flattened/SigmaVoterV1.sol#L837)

flattened/SigmaVoterV1.sol#L827-L844

-   [ ] ID-47
        Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/SigmaVoterV1.sol#L145-L161): - [(success,returndata) = target.call{value: value}(data)](flattened/SigmaVoterV1.sol#L157-L159)

flattened/SigmaVoterV1.sol#L145-L161

## naming-convention

Impact: Informational
Confidence: High

-   [ ] ID-48
        Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256).\_userMaxVote](flattened/SigmaVoterV1.sol#L1214) is not in mixedCase

flattened/SigmaVoterV1.sol#L1214

-   [ ] ID-49
        Parameter [SigmaVoterV1.isPool(address).\_pool](flattened/SigmaVoterV1.sol#L1658) is not in mixedCase

flattened/SigmaVoterV1.sol#L1658

-   [ ] ID-50
        Function [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init_unchained()](flattened/SigmaVoterV1.sol#L627) is not in mixedCase

flattened/SigmaVoterV1.sol#L627

-   [ ] ID-51
        Parameter [SigmaVoterV1.setTopYieldPools(address[]).\_pools](flattened/SigmaVoterV1.sol#L1233) is not in mixedCase

flattened/SigmaVoterV1.sol#L1233

-   [ ] ID-52
        Variable [ContextUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L402) is not in mixedCase

flattened/SigmaVoterV1.sol#L402

-   [ ] ID-53
        Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256).\_lpPools](flattened/SigmaVoterV1.sol#L1211) is not in mixedCase

flattened/SigmaVoterV1.sol#L1211

-   [ ] ID-54
        Parameter [SigmaVoterV1.addAllPoolVote(address[],uint256[]).\_pools](flattened/SigmaVoterV1.sol#L1270) is not in mixedCase

flattened/SigmaVoterV1.sol#L1270

-   [ ] ID-55
        Parameter [SigmaVoterV1.getUserVotesCount(address).\_user](flattened/SigmaVoterV1.sol#L1683) is not in mixedCase

flattened/SigmaVoterV1.sol#L1683

-   [ ] ID-56
        Function [OwnableUpgradeable.\_\_Ownable_init()](flattened/SigmaVoterV1.sol#L428-L430) is not in mixedCase

flattened/SigmaVoterV1.sol#L428-L430

-   [ ] ID-57
        Variable [OwnableUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L489) is not in mixedCase

flattened/SigmaVoterV1.sol#L489

-   [ ] ID-58
        Variable [UUPSUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L975) is not in mixedCase

flattened/SigmaVoterV1.sol#L975

-   [ ] ID-59
        Variable [PausableUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L1071) is not in mixedCase

flattened/SigmaVoterV1.sol#L1071

-   [ ] ID-60
        Variable [ERC1967UpgradeUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L851) is not in mixedCase

flattened/SigmaVoterV1.sol#L851

-   [ ] ID-61
        Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256).\_vxSIG](flattened/SigmaVoterV1.sol#L1213) is not in mixedCase

flattened/SigmaVoterV1.sol#L1213

-   [ ] ID-62
        Function [ContextUpgradeable.\_\_Context_init_unchained()](flattened/SigmaVoterV1.sol#L387) is not in mixedCase

flattened/SigmaVoterV1.sol#L387

-   [ ] ID-63
        Parameter [SigmaVoterV1.deletePoolVote(address,uint256).\_vxSIGAmount](flattened/SigmaVoterV1.sol#L1359) is not in mixedCase

flattened/SigmaVoterV1.sol#L1359

-   [ ] ID-64
        Parameter [SigmaVoterV1.addPool(address).\_pool](flattened/SigmaVoterV1.sol#L1247) is not in mixedCase

flattened/SigmaVoterV1.sol#L1247

-   [ ] ID-65
        Function [UUPSUpgradeable.\_\_UUPSUpgradeable_init_unchained()](flattened/SigmaVoterV1.sol#L873) is not in mixedCase

flattened/SigmaVoterV1.sol#L873

-   [ ] ID-66
        Parameter [SigmaVoterV1.availableVotes(address).\_user](flattened/SigmaVoterV1.sol#L1674) is not in mixedCase

flattened/SigmaVoterV1.sol#L1674

-   [ ] ID-67
        Parameter [SigmaVoterV1.addAllPoolVote(address[],uint256[]).\_vxSIGAmounts](flattened/SigmaVoterV1.sol#L1271) is not in mixedCase

flattened/SigmaVoterV1.sol#L1271

-   [ ] ID-68
        Parameter [SigmaVoterV1.deletePoolVote(address,uint256).\_pool](flattened/SigmaVoterV1.sol#L1359) is not in mixedCase

flattened/SigmaVoterV1.sol#L1359

-   [ ] ID-69
        Function [OwnableUpgradeable.\_\_Ownable_init_unchained()](flattened/SigmaVoterV1.sol#L432-L434) is not in mixedCase

flattened/SigmaVoterV1.sol#L432-L434

-   [ ] ID-70
        Variable [UUPSUpgradeable.\_\_self](flattened/SigmaVoterV1.sol#L876) is not in mixedCase

flattened/SigmaVoterV1.sol#L876

-   [ ] ID-71
        Function [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init()](flattened/SigmaVoterV1.sol#L625) is not in mixedCase

flattened/SigmaVoterV1.sol#L625

-   [ ] ID-72
        Function [UUPSUpgradeable.\_\_UUPSUpgradeable_init()](flattened/SigmaVoterV1.sol#L871) is not in mixedCase

flattened/SigmaVoterV1.sol#L871

-   [ ] ID-73
        Parameter [SigmaVoterV1.setInitialInfo(address[],address[],IvxERC20,uint256).\_topYieldPools](flattened/SigmaVoterV1.sol#L1212) is not in mixedCase

flattened/SigmaVoterV1.sol#L1212

-   [ ] ID-74
        Variable [SigmaVoterV1.USER_MAX_VOTE_POOL](flattened/SigmaVoterV1.sol#L1123) is not in mixedCase

flattened/SigmaVoterV1.sol#L1123

-   [ ] ID-75
        Function [PausableUpgradeable.\_\_Pausable_init()](flattened/SigmaVoterV1.sol#L1003-L1005) is not in mixedCase

flattened/SigmaVoterV1.sol#L1003-L1005

-   [ ] ID-76
        Parameter [SigmaVoterV1.setUserMaxVotePool(uint256).\_value](flattened/SigmaVoterV1.sol#L1240) is not in mixedCase

flattened/SigmaVoterV1.sol#L1240

-   [ ] ID-77
        Function [ContextUpgradeable.\_\_Context_init()](flattened/SigmaVoterV1.sol#L385) is not in mixedCase

flattened/SigmaVoterV1.sol#L385

-   [ ] ID-78
        Function [PausableUpgradeable.\_\_Pausable_init_unchained()](flattened/SigmaVoterV1.sol#L1007-L1009) is not in mixedCase

flattened/SigmaVoterV1.sol#L1007-L1009

## unused-state

Impact: Informational
Confidence: High

-   [ ] ID-79
        [PausableUpgradeable.\_\_gap](flattened/SigmaVoterV1.sol#L1071) is never used in [SigmaVoterV1](flattened/SigmaVoterV1.sol#L1103-L1695)

flattened/SigmaVoterV1.sol#L1071

## external-function

Impact: Optimization
Confidence: High

-   [ ] ID-80
        getPoolCount() should be declared external: - [SigmaVoterV1.getPoolCount()](flattened/SigmaVoterV1.sol#L1665-L1667)

flattened/SigmaVoterV1.sol#L1665-L1667

-   [ ] ID-81
        transferOwnership(address) should be declared external: - [OwnableUpgradeable.transferOwnership(address)](flattened/SigmaVoterV1.sol#L466-L472)

flattened/SigmaVoterV1.sol#L466-L472

-   [ ] ID-82
        renounceOwnership() should be declared external: - [OwnableUpgradeable.renounceOwnership()](flattened/SigmaVoterV1.sol#L458-L460)

flattened/SigmaVoterV1.sol#L458-L460
