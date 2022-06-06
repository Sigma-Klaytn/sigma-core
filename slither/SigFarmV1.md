Summary
 - [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
 - [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
 - [incorrect-equality](#incorrect-equality) (2 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (2 results) (Medium)
 - [unused-return](#unused-return) (3 results) (Medium)
 - [events-maths](#events-maths) (2 results) (Low)
 - [variable-scope](#variable-scope) (1 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (4 results) (Low)
 - [timestamp](#timestamp) (2 results) (Low)
 - [assembly](#assembly) (5 results) (Informational)
 - [dead-code](#dead-code) (24 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (27 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (2 results) (Optimization)
## controlled-delegatecall
Impact: High
Confidence: Medium
 - [ ] ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/SigFarmV1.sol#L833-L850) uses delegatecall to a input-controlled function id
	- [(success,returndata) = target.delegatecall(data)](flattened/SigFarmV1.sol#L843)

flattened/SigFarmV1.sol#L833-L850


## unprotected-upgrade
Impact: High
Confidence: High
 - [ ] ID-1
[SigFarmV1](flattened/SigFarmV1.sol#L1371-L1615) is an upgradeable contract that does not protect its initiliaze functions: [SigFarmV1.initialize()](flattened/SigFarmV1.sol#L1428-L1432). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/SigFarmV1.sol#L941-L944)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/SigFarmV1.sol#L954-L962)
flattened/SigFarmV1.sol#L1371-L1615


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-2
[SigFarmV1.getxSIGExchangeRate()](flattened/SigFarmV1.sol#L1606-L1614) uses a dangerous strict equality:
	- [sigAmount == 0](flattened/SigFarmV1.sol#L1608)

flattened/SigFarmV1.sol#L1606-L1614


 - [ ] ID-3
[SigFarmV1.stake(uint256)](flattened/SigFarmV1.sol#L1464-L1485) uses a dangerous strict equality:
	- [sigAmount == 0](flattened/SigFarmV1.sol#L1475)

flattened/SigFarmV1.sol#L1464-L1485


## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-4
[SigFarmV1.getRedeemableSIG().withdrawableSIG](flattened/SigFarmV1.sol#L1590) is a local variable never initialized

flattened/SigFarmV1.sol#L1590


 - [ ] ID-5
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigFarmV1.sol#L717) is a local variable never initialized

flattened/SigFarmV1.sol#L717


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-6
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigFarmV1.sol#L704-L727) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/SigFarmV1.sol#L715-L724)

flattened/SigFarmV1.sol#L704-L727


 - [ ] ID-7
[SigFarmV1.stake(uint256)](flattened/SigFarmV1.sol#L1464-L1485) ignores return value by [xSIG.mint(msg.sender,xSIGToGet)](flattened/SigFarmV1.sol#L1482)

flattened/SigFarmV1.sol#L1464-L1485


 - [ ] ID-8
[SigFarmV1.claimUnlockedSIG()](flattened/SigFarmV1.sol#L1525-L1539) ignores return value by [xSIG.burn(address(this),totalBurningxSIG)](flattened/SigFarmV1.sol#L1535)

flattened/SigFarmV1.sol#L1525-L1539


## events-maths
Impact: Low
Confidence: Medium
 - [ ] ID-9
[SigFarmV1.setInitialInfo(address,uint256,address)](flattened/SigFarmV1.sol#L1415-L1423) should emit an event for: 
	- [lockingPeriod = _lockingPeriod](flattened/SigFarmV1.sol#L1422) 

flattened/SigFarmV1.sol#L1415-L1423


 - [ ] ID-10
[SigFarmV1.setLockingPeriod(uint256)](flattened/SigFarmV1.sol#L1411-L1413) should emit an event for: 
	- [lockingPeriod = _lockingPeriod](flattened/SigFarmV1.sol#L1412) 

flattened/SigFarmV1.sol#L1411-L1413


## variable-scope
Impact: Low
Confidence: High
 - [ ] ID-11
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigFarmV1.sol#L717)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigFarmV1.sol#L704-L727) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/SigFarmV1.sol#L718-L721)

flattened/SigFarmV1.sol#L717


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-12
Reentrancy in [SigFarmV1.unstake(uint256)](flattened/SigFarmV1.sol#L1491-L1520):
	External calls:
	- [xSIG.safeTransferFrom(msg.sender,address(this),_amount)](flattened/SigFarmV1.sol#L1497)
	State variables written after the call(s):
	- [pendingSIG += sigToReturn](flattened/SigFarmV1.sol#L1516)
	- [pendingxSIG += _amount](flattened/SigFarmV1.sol#L1517)
	- [withdrawInfoOf[msg.sender].push(WithdrawInfo(endTime,_amount,sigToReturn,false))](flattened/SigFarmV1.sol#L1507-L1514)

flattened/SigFarmV1.sol#L1491-L1520


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-13
Reentrancy in [SigFarmV1.depositFee(uint256)](flattened/SigFarmV1.sol#L1545-L1549):
	External calls:
	- [SIG.safeTransferFrom(msg.sender,address(this),_amount)](flattened/SigFarmV1.sol#L1547)
	Event emitted after the call(s):
	- [FeesReceived(msg.sender,_amount)](flattened/SigFarmV1.sol#L1548)

flattened/SigFarmV1.sol#L1545-L1549


 - [ ] ID-14
Reentrancy in [SigFarmV1.stake(uint256)](flattened/SigFarmV1.sol#L1464-L1485):
	External calls:
	- [SIG.safeTransferFrom(msg.sender,address(this),_amount)](flattened/SigFarmV1.sol#L1470)
	- [xSIG.mint(msg.sender,xSIGToGet)](flattened/SigFarmV1.sol#L1482)
	Event emitted after the call(s):
	- [Stake(_amount,xSIGToGet)](flattened/SigFarmV1.sol#L1484)

flattened/SigFarmV1.sol#L1464-L1485


 - [ ] ID-15
Reentrancy in [SigFarmV1.claimUnlockedSIG()](flattened/SigFarmV1.sol#L1525-L1539):
	External calls:
	- [xSIG.burn(address(this),totalBurningxSIG)](flattened/SigFarmV1.sol#L1535)
	- [SIG.safeTransfer(msg.sender,withdrawableSIG)](flattened/SigFarmV1.sol#L1536)
	Event emitted after the call(s):
	- [ClaimUnlockedSIG(withdrawableSIG,totalBurningxSIG)](flattened/SigFarmV1.sol#L1538)

flattened/SigFarmV1.sol#L1525-L1539


 - [ ] ID-16
Reentrancy in [SigFarmV1.unstake(uint256)](flattened/SigFarmV1.sol#L1491-L1520):
	External calls:
	- [xSIG.safeTransferFrom(msg.sender,address(this),_amount)](flattened/SigFarmV1.sol#L1497)
	Event emitted after the call(s):
	- [Unstake(_amount,sigToReturn)](flattened/SigFarmV1.sol#L1519)

flattened/SigFarmV1.sol#L1491-L1520


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-17
[SigFarmV1.getRedeemableSIG()](flattened/SigFarmV1.sol#L1588-L1601) uses timestamp for comparisons
	Dangerous comparisons:
	- [withdrawInfo.unlockTime < block.timestamp](flattened/SigFarmV1.sol#L1595)

flattened/SigFarmV1.sol#L1588-L1601


 - [ ] ID-18
[SigFarmV1._computeWithdrawableSIG(address)](flattened/SigFarmV1.sol#L1557-L1581) uses timestamp for comparisons
	Dangerous comparisons:
	- [withdrawInfo.unlockTime < block.timestamp](flattened/SigFarmV1.sol#L1568)

flattened/SigFarmV1.sol#L1557-L1581


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-19
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/SigFarmV1.sol#L585-L593) uses assembly
	- [INLINE ASM](flattened/SigFarmV1.sol#L590-L592)

flattened/SigFarmV1.sol#L585-L593


 - [ ] ID-20
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigFarmV1.sol#L598-L606) uses assembly
	- [INLINE ASM](flattened/SigFarmV1.sol#L603-L605)

flattened/SigFarmV1.sol#L598-L606


 - [ ] ID-21
[StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/SigFarmV1.sol#L572-L580) uses assembly
	- [INLINE ASM](flattened/SigFarmV1.sol#L577-L579)

flattened/SigFarmV1.sol#L572-L580


 - [ ] ID-22
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/SigFarmV1.sol#L205-L225) uses assembly
	- [INLINE ASM](flattened/SigFarmV1.sol#L217-L220)

flattened/SigFarmV1.sol#L205-L225


 - [ ] ID-23
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigFarmV1.sol#L611-L619) uses assembly
	- [INLINE ASM](flattened/SigFarmV1.sol#L616-L618)

flattened/SigFarmV1.sol#L611-L619


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-24
[ContextUpgradeable._msgData()](flattened/SigFarmV1.sol#L397-L399) is never used and should be removed

flattened/SigFarmV1.sol#L397-L399


 - [ ] ID-25
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/SigFarmV1.sol#L125-L137) is never used and should be removed

flattened/SigFarmV1.sol#L125-L137


 - [ ] ID-26
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](flattened/SigFarmV1.sol#L1277-L1293) is never used and should be removed

flattened/SigFarmV1.sol#L1277-L1293


 - [ ] ID-27
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/SigFarmV1.sol#L633) is never used and should be removed

flattened/SigFarmV1.sol#L633


 - [ ] ID-28
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/SigFarmV1.sol#L1295-L1309) is never used and should be removed

flattened/SigFarmV1.sol#L1295-L1309


 - [ ] ID-29
[AddressUpgradeable.functionCall(address,bytes)](flattened/SigFarmV1.sol#L93-L98) is never used and should be removed

flattened/SigFarmV1.sol#L93-L98


 - [ ] ID-30
[ERC1967UpgradeUpgradeable._getBeacon()](flattened/SigFarmV1.sol#L785-L787) is never used and should be removed

flattened/SigFarmV1.sol#L785-L787


 - [ ] ID-31
[ContextUpgradeable.__Context_init_unchained()](flattened/SigFarmV1.sol#L391) is never used and should be removed

flattened/SigFarmV1.sol#L391


 - [ ] ID-32
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigFarmV1.sol#L611-L619) is never used and should be removed

flattened/SigFarmV1.sol#L611-L619


 - [ ] ID-33
[AddressUpgradeable.sendValue(address,uint256)](flattened/SigFarmV1.sol#L62-L73) is never used and should be removed

flattened/SigFarmV1.sol#L62-L73


 - [ ] ID-34
[AddressUpgradeable.functionStaticCall(address,bytes)](flattened/SigFarmV1.sol#L169-L180) is never used and should be removed

flattened/SigFarmV1.sol#L169-L180


 - [ ] ID-35
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](flattened/SigFarmV1.sol#L812-L825) is never used and should be removed

flattened/SigFarmV1.sol#L812-L825


 - [ ] ID-36
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/SigFarmV1.sol#L1311-L1332) is never used and should be removed

flattened/SigFarmV1.sol#L1311-L1332


 - [ ] ID-37
[ERC1967UpgradeUpgradeable._setBeacon(address)](flattened/SigFarmV1.sol#L792-L804) is never used and should be removed

flattened/SigFarmV1.sol#L792-L804


 - [ ] ID-38
[UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/SigFarmV1.sol#L877) is never used and should be removed

flattened/SigFarmV1.sol#L877


 - [ ] ID-39
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/SigFarmV1.sol#L631) is never used and should be removed

flattened/SigFarmV1.sol#L631


 - [ ] ID-40
[ERC1967UpgradeUpgradeable._setAdmin(address)](flattened/SigFarmV1.sol#L752-L758) is never used and should be removed

flattened/SigFarmV1.sol#L752-L758


 - [ ] ID-41
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/SigFarmV1.sol#L879) is never used and should be removed

flattened/SigFarmV1.sol#L879


 - [ ] ID-42
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigFarmV1.sol#L598-L606) is never used and should be removed

flattened/SigFarmV1.sol#L598-L606


 - [ ] ID-43
[ERC1967UpgradeUpgradeable._changeAdmin(address)](flattened/SigFarmV1.sol#L765-L768) is never used and should be removed

flattened/SigFarmV1.sol#L765-L768


 - [ ] ID-44
[ERC1967UpgradeUpgradeable._getAdmin()](flattened/SigFarmV1.sol#L745-L747) is never used and should be removed

flattened/SigFarmV1.sol#L745-L747


 - [ ] ID-45
[AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigFarmV1.sol#L188-L197) is never used and should be removed

flattened/SigFarmV1.sol#L188-L197


 - [ ] ID-46
[Initializable._disableInitializers()](flattened/SigFarmV1.sol#L351-L353) is never used and should be removed

flattened/SigFarmV1.sol#L351-L353


 - [ ] ID-47
[ContextUpgradeable.__Context_init()](flattened/SigFarmV1.sol#L389) is never used and should be removed

flattened/SigFarmV1.sol#L389


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-48
Pragma version[^0.8.1](flattened/SigFarmV1.sol#L6) allows old versions

flattened/SigFarmV1.sol#L6


 - [ ] ID-49
solc-0.8.9 is not recommended for deployment

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-50
Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/SigFarmV1.sol#L62-L73):
	- [(success) = recipient.call{value: amount}()](flattened/SigFarmV1.sol#L68)

flattened/SigFarmV1.sol#L62-L73


 - [ ] ID-51
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/SigFarmV1.sol#L145-L161):
	- [(success,returndata) = target.call{value: value}(data)](flattened/SigFarmV1.sol#L157-L159)

flattened/SigFarmV1.sol#L145-L161


 - [ ] ID-52
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/SigFarmV1.sol#L833-L850):
	- [(success,returndata) = target.delegatecall(data)](flattened/SigFarmV1.sol#L843)

flattened/SigFarmV1.sol#L833-L850


 - [ ] ID-53
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigFarmV1.sol#L188-L197):
	- [(success,returndata) = target.staticcall(data)](flattened/SigFarmV1.sol#L195)

flattened/SigFarmV1.sol#L188-L197


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-54
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/SigFarmV1.sol#L633) is not in mixedCase

flattened/SigFarmV1.sol#L633


 - [ ] ID-55
Parameter [SigFarmV1.setLockingPeriod(uint256)._lockingPeriod](flattened/SigFarmV1.sol#L1411) is not in mixedCase

flattened/SigFarmV1.sol#L1411


 - [ ] ID-56
Variable [ContextUpgradeable.__gap](flattened/SigFarmV1.sol#L406) is not in mixedCase

flattened/SigFarmV1.sol#L406


 - [ ] ID-57
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](flattened/SigFarmV1.sol#L1021-L1023) is not in mixedCase

flattened/SigFarmV1.sol#L1021-L1023


 - [ ] ID-58
Parameter [SigFarmV1.depositFee(uint256)._amount](flattened/SigFarmV1.sol#L1545) is not in mixedCase

flattened/SigFarmV1.sol#L1545


 - [ ] ID-59
Parameter [SigFarmV1.stake(uint256)._amount](flattened/SigFarmV1.sol#L1464) is not in mixedCase

flattened/SigFarmV1.sol#L1464


 - [ ] ID-60
Function [OwnableUpgradeable.__Ownable_init()](flattened/SigFarmV1.sol#L434-L436) is not in mixedCase

flattened/SigFarmV1.sol#L434-L436


 - [ ] ID-61
Variable [OwnableUpgradeable.__gap](flattened/SigFarmV1.sol#L495) is not in mixedCase

flattened/SigFarmV1.sol#L495


 - [ ] ID-62
Variable [UUPSUpgradeable.__gap](flattened/SigFarmV1.sol#L981) is not in mixedCase

flattened/SigFarmV1.sol#L981


 - [ ] ID-63
Parameter [SigFarmV1.setInitialInfo(address,uint256,address)._SIG](flattened/SigFarmV1.sol#L1416) is not in mixedCase

flattened/SigFarmV1.sol#L1416


 - [ ] ID-64
Variable [PausableUpgradeable.__gap](flattened/SigFarmV1.sol#L1147) is not in mixedCase

flattened/SigFarmV1.sol#L1147


 - [ ] ID-65
Variable [SigFarmV1.SIG](flattened/SigFarmV1.sol#L1385) is not in mixedCase

flattened/SigFarmV1.sol#L1385


 - [ ] ID-66
Variable [ERC1967UpgradeUpgradeable.__gap](flattened/SigFarmV1.sol#L857) is not in mixedCase

flattened/SigFarmV1.sol#L857


 - [ ] ID-67
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](flattened/SigFarmV1.sol#L1017-L1019) is not in mixedCase

flattened/SigFarmV1.sol#L1017-L1019


 - [ ] ID-68
Function [ContextUpgradeable.__Context_init_unchained()](flattened/SigFarmV1.sol#L391) is not in mixedCase

flattened/SigFarmV1.sol#L391


 - [ ] ID-69
Parameter [SigFarmV1.setInitialInfo(address,uint256,address)._xSIG](flattened/SigFarmV1.sol#L1418) is not in mixedCase

flattened/SigFarmV1.sol#L1418


 - [ ] ID-70
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/SigFarmV1.sol#L879) is not in mixedCase

flattened/SigFarmV1.sol#L879


 - [ ] ID-71
Variable [ReentrancyGuardUpgradeable.__gap](flattened/SigFarmV1.sol#L1051) is not in mixedCase

flattened/SigFarmV1.sol#L1051


 - [ ] ID-72
Parameter [SigFarmV1.unstake(uint256)._amount](flattened/SigFarmV1.sol#L1491) is not in mixedCase

flattened/SigFarmV1.sol#L1491


 - [ ] ID-73
Function [OwnableUpgradeable.__Ownable_init_unchained()](flattened/SigFarmV1.sol#L438-L440) is not in mixedCase

flattened/SigFarmV1.sol#L438-L440


 - [ ] ID-74
Variable [UUPSUpgradeable.__self](flattened/SigFarmV1.sol#L882) is not in mixedCase

flattened/SigFarmV1.sol#L882


 - [ ] ID-75
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/SigFarmV1.sol#L631) is not in mixedCase

flattened/SigFarmV1.sol#L631


 - [ ] ID-76
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/SigFarmV1.sol#L877) is not in mixedCase

flattened/SigFarmV1.sol#L877


 - [ ] ID-77
Function [PausableUpgradeable.__Pausable_init()](flattened/SigFarmV1.sol#L1079-L1081) is not in mixedCase

flattened/SigFarmV1.sol#L1079-L1081


 - [ ] ID-78
Function [ContextUpgradeable.__Context_init()](flattened/SigFarmV1.sol#L389) is not in mixedCase

flattened/SigFarmV1.sol#L389


 - [ ] ID-79
Function [PausableUpgradeable.__Pausable_init_unchained()](flattened/SigFarmV1.sol#L1083-L1085) is not in mixedCase

flattened/SigFarmV1.sol#L1083-L1085


 - [ ] ID-80
Parameter [SigFarmV1.setInitialInfo(address,uint256,address)._lockingPeriod](flattened/SigFarmV1.sol#L1417) is not in mixedCase

flattened/SigFarmV1.sol#L1417


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-81
[PausableUpgradeable.__gap](flattened/SigFarmV1.sol#L1147) is never used in [SigFarmV1](flattened/SigFarmV1.sol#L1371-L1615)

flattened/SigFarmV1.sol#L1147


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-82
transferOwnership(address) should be declared external:
	- [OwnableUpgradeable.transferOwnership(address)](flattened/SigFarmV1.sol#L472-L478)

flattened/SigFarmV1.sol#L472-L478


 - [ ] ID-83
renounceOwnership() should be declared external:
	- [OwnableUpgradeable.renounceOwnership()](flattened/SigFarmV1.sol#L464-L466)

flattened/SigFarmV1.sol#L464-L466


