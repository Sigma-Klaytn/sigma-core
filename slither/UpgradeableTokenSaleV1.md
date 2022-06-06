Summary
 - [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
 - [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
 - [reentrancy-no-eth](#reentrancy-no-eth) (2 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [unused-return](#unused-return) (1 results) (Medium)
 - [variable-scope](#variable-scope) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (2 results) (Low)
 - [timestamp](#timestamp) (7 results) (Low)
 - [assembly](#assembly) (5 results) (Informational)
 - [boolean-equal](#boolean-equal) (2 results) (Informational)
 - [dead-code](#dead-code) (24 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (27 results) (Informational)
 - [reentrancy-unlimited-gas](#reentrancy-unlimited-gas) (2 results) (Informational)
 - [similar-names](#similar-names) (2 results) (Informational)
 - [too-many-digits](#too-many-digits) (1 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (2 results) (Optimization)
## controlled-delegatecall
Impact: High
Confidence: Medium
 - [ ] ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/UpgradeableTokenSaleV1.sol#L1038-L1055) uses delegatecall to a input-controlled function id
	- [(success,returndata) = target.delegatecall(data)](flattened/UpgradeableTokenSaleV1.sol#L1048)

flattened/UpgradeableTokenSaleV1.sol#L1038-L1055


## unprotected-upgrade
Impact: High
Confidence: High
 - [ ] ID-1
[UpgradeableTokenSaleV1](flattened/UpgradeableTokenSaleV1.sol#L1355-L1688) is an upgradeable contract that does not protect its initiliaze functions: [UpgradeableTokenSaleV1.initialize()](flattened/UpgradeableTokenSaleV1.sol#L1401-L1405). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/UpgradeableTokenSaleV1.sol#L1146-L1149)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/UpgradeableTokenSaleV1.sol#L1159-L1167)
flattened/UpgradeableTokenSaleV1.sol#L1355-L1688


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-2
Reentrancy in [UpgradeableTokenSaleV1.withdrawTokens()](flattened/UpgradeableTokenSaleV1.sol#L1489-L1513):
	External calls:
	- [SIG.safeTransfer(msg.sender,amount)](flattened/UpgradeableTokenSaleV1.sol#L1508)
	State variables written after the call(s):
	- [userDeposit.tokensClaimed = true](flattened/UpgradeableTokenSaleV1.sol#L1510)

flattened/UpgradeableTokenSaleV1.sol#L1489-L1513


 - [ ] ID-3
Reentrancy in [UpgradeableTokenSaleV1.releaseToken()](flattened/UpgradeableTokenSaleV1.sol#L1644-L1655):
	External calls:
	- [SIG.safeTransferFrom(msg.sender,address(this),TOTAL_SIG_SUPPLY)](flattened/UpgradeableTokenSaleV1.sol#L1651)
	State variables written after the call(s):
	- [tokensReleased = true](flattened/UpgradeableTokenSaleV1.sol#L1652)

flattened/UpgradeableTokenSaleV1.sol#L1644-L1655


## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-4
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/UpgradeableTokenSaleV1.sol#L922) is a local variable never initialized

flattened/UpgradeableTokenSaleV1.sol#L922


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-5
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/UpgradeableTokenSaleV1.sol#L909-L932) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/UpgradeableTokenSaleV1.sol#L920-L929)

flattened/UpgradeableTokenSaleV1.sol#L909-L932


## variable-scope
Impact: Low
Confidence: High
 - [ ] ID-6
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/UpgradeableTokenSaleV1.sol#L922)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/UpgradeableTokenSaleV1.sol#L909-L932) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/UpgradeableTokenSaleV1.sol#L923-L926)

flattened/UpgradeableTokenSaleV1.sol#L922


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-7
Reentrancy in [UpgradeableTokenSaleV1.withdrawTokens()](flattened/UpgradeableTokenSaleV1.sol#L1489-L1513):
	External calls:
	- [SIG.safeTransfer(msg.sender,amount)](flattened/UpgradeableTokenSaleV1.sol#L1508)
	Event emitted after the call(s):
	- [TokenClaimed(msg.sender,amount)](flattened/UpgradeableTokenSaleV1.sol#L1512)

flattened/UpgradeableTokenSaleV1.sol#L1489-L1513


 - [ ] ID-8
Reentrancy in [UpgradeableTokenSaleV1.releaseToken()](flattened/UpgradeableTokenSaleV1.sol#L1644-L1655):
	External calls:
	- [SIG.safeTransferFrom(msg.sender,address(this),TOTAL_SIG_SUPPLY)](flattened/UpgradeableTokenSaleV1.sol#L1651)
	Event emitted after the call(s):
	- [SIGTokenReleased(block.timestamp,TOTAL_SIG_SUPPLY)](flattened/UpgradeableTokenSaleV1.sol#L1654)

flattened/UpgradeableTokenSaleV1.sol#L1644-L1655


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-9
[UpgradeableTokenSaleV1.releaseToken()](flattened/UpgradeableTokenSaleV1.sol#L1644-L1655) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > phase2EndTs,Phase 2 should end to release SIG Tokens.)](flattened/UpgradeableTokenSaleV1.sol#L1646-L1649)

flattened/UpgradeableTokenSaleV1.sol#L1644-L1655


 - [ ] ID-10
[UpgradeableTokenSaleV1.withdrawTokens()](flattened/UpgradeableTokenSaleV1.sol#L1489-L1513) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > phase2EndTs,You can't withdraw tokens before phase 2 ends.)](flattened/UpgradeableTokenSaleV1.sol#L1490-L1493)

flattened/UpgradeableTokenSaleV1.sol#L1489-L1513


 - [ ] ID-11
[UpgradeableTokenSaleV1.getWithdrawableAmount()](flattened/UpgradeableTokenSaleV1.sol#L1517-L1542) uses timestamp for comparisons
	Dangerous comparisons:
	- [phase2EndTs < block.timestamp](flattened/UpgradeableTokenSaleV1.sol#L1518)
	- [block.timestamp < phase2StartTs](flattened/UpgradeableTokenSaleV1.sol#L1522)

flattened/UpgradeableTokenSaleV1.sol#L1517-L1542


 - [ ] ID-12
[UpgradeableTokenSaleV1.adminWithdraw()](flattened/UpgradeableTokenSaleV1.sol#L1627-L1639) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > phase2EndTs,Phase 2 should end to withdraw KLAY Tokens.)](flattened/UpgradeableTokenSaleV1.sol#L1628-L1631)

flattened/UpgradeableTokenSaleV1.sol#L1627-L1639


 - [ ] ID-13
[UpgradeableTokenSaleV1.deposit()](flattened/UpgradeableTokenSaleV1.sol#L1410-L1427) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > phase1StartTs,Phase 1 did not start yet.)](flattened/UpgradeableTokenSaleV1.sol#L1412)
	- [require(bool,string)(block.timestamp < phase2StartTs,Deposit period is already ended)](flattened/UpgradeableTokenSaleV1.sol#L1413-L1416)

flattened/UpgradeableTokenSaleV1.sol#L1410-L1427


 - [ ] ID-14
[UpgradeableTokenSaleV1._getWithdrawablePortion(uint256,uint256)](flattened/UpgradeableTokenSaleV1.sol#L1561-L1572) uses timestamp for comparisons
	Dangerous comparisons:
	- [portion < 1e18](flattened/UpgradeableTokenSaleV1.sol#L1567)

flattened/UpgradeableTokenSaleV1.sol#L1561-L1572


 - [ ] ID-15
[UpgradeableTokenSaleV1.withdraw(uint256)](flattened/UpgradeableTokenSaleV1.sol#L1432-L1484) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp < phase2EndTs,Withdraw period is already done.)](flattened/UpgradeableTokenSaleV1.sol#L1437-L1440)
	- [block.timestamp > phase2StartTs](flattened/UpgradeableTokenSaleV1.sol#L1451)
	- [require(bool,string)(_requiredAmount <= withdrawableAmount,You can't withdraw more than current withdrawable amount)](flattened/UpgradeableTokenSaleV1.sol#L1473-L1476)

flattened/UpgradeableTokenSaleV1.sol#L1432-L1484


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-16
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L803-L811) uses assembly
	- [INLINE ASM](flattened/UpgradeableTokenSaleV1.sol#L808-L810)

flattened/UpgradeableTokenSaleV1.sol#L803-L811


 - [ ] ID-17
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/UpgradeableTokenSaleV1.sol#L203-L223) uses assembly
	- [INLINE ASM](flattened/UpgradeableTokenSaleV1.sol#L215-L218)

flattened/UpgradeableTokenSaleV1.sol#L203-L223


 - [ ] ID-18
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L790-L798) uses assembly
	- [INLINE ASM](flattened/UpgradeableTokenSaleV1.sol#L795-L797)

flattened/UpgradeableTokenSaleV1.sol#L790-L798


 - [ ] ID-19
[StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L777-L785) uses assembly
	- [INLINE ASM](flattened/UpgradeableTokenSaleV1.sol#L782-L784)

flattened/UpgradeableTokenSaleV1.sol#L777-L785


 - [ ] ID-20
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L816-L824) uses assembly
	- [INLINE ASM](flattened/UpgradeableTokenSaleV1.sol#L821-L823)

flattened/UpgradeableTokenSaleV1.sol#L816-L824


## boolean-equal
Impact: Informational
Confidence: High
 - [ ] ID-21
[UpgradeableTokenSaleV1.releaseToken()](flattened/UpgradeableTokenSaleV1.sol#L1644-L1655) compares to a boolean constant:
	-[require(bool,string)(tokensReleased == false,Tokens are already released.)](flattened/UpgradeableTokenSaleV1.sol#L1645)

flattened/UpgradeableTokenSaleV1.sol#L1644-L1655


 - [ ] ID-22
[UpgradeableTokenSaleV1.withdraw(uint256)](flattened/UpgradeableTokenSaleV1.sol#L1432-L1484) compares to a boolean constant:
	-[require(bool,string)(userDeposit.withdrewAtPhase2 == false,Already withdrew fund. Withdrawal is only permitted once.)](flattened/UpgradeableTokenSaleV1.sol#L1452-L1455)

flattened/UpgradeableTokenSaleV1.sol#L1432-L1484


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-23
[ContextUpgradeable._msgData()](flattened/UpgradeableTokenSaleV1.sol#L393-L395) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L393-L395


 - [ ] ID-24
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/UpgradeableTokenSaleV1.sol#L123-L135) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L123-L135


 - [ ] ID-25
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](flattened/UpgradeableTokenSaleV1.sol#L619-L635) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L619-L635


 - [ ] ID-26
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L838) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L838


 - [ ] ID-27
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/UpgradeableTokenSaleV1.sol#L637-L651) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L637-L651


 - [ ] ID-28
[AddressUpgradeable.functionCall(address,bytes)](flattened/UpgradeableTokenSaleV1.sol#L91-L96) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L91-L96


 - [ ] ID-29
[ERC1967UpgradeUpgradeable._getBeacon()](flattened/UpgradeableTokenSaleV1.sol#L990-L992) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L990-L992


 - [ ] ID-30
[ContextUpgradeable.__Context_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L387) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L387


 - [ ] ID-31
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L816-L824) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L816-L824


 - [ ] ID-32
[AddressUpgradeable.sendValue(address,uint256)](flattened/UpgradeableTokenSaleV1.sol#L60-L71) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L60-L71


 - [ ] ID-33
[AddressUpgradeable.functionStaticCall(address,bytes)](flattened/UpgradeableTokenSaleV1.sol#L167-L178) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L167-L178


 - [ ] ID-34
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](flattened/UpgradeableTokenSaleV1.sol#L1017-L1030) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L1017-L1030


 - [ ] ID-35
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/UpgradeableTokenSaleV1.sol#L653-L674) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L653-L674


 - [ ] ID-36
[ERC1967UpgradeUpgradeable._setBeacon(address)](flattened/UpgradeableTokenSaleV1.sol#L997-L1009) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L997-L1009


 - [ ] ID-37
[UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/UpgradeableTokenSaleV1.sol#L1082) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L1082


 - [ ] ID-38
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/UpgradeableTokenSaleV1.sol#L836) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L836


 - [ ] ID-39
[ERC1967UpgradeUpgradeable._setAdmin(address)](flattened/UpgradeableTokenSaleV1.sol#L957-L963) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L957-L963


 - [ ] ID-40
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L1084) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L1084


 - [ ] ID-41
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/UpgradeableTokenSaleV1.sol#L803-L811) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L803-L811


 - [ ] ID-42
[ERC1967UpgradeUpgradeable._changeAdmin(address)](flattened/UpgradeableTokenSaleV1.sol#L970-L973) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L970-L973


 - [ ] ID-43
[ERC1967UpgradeUpgradeable._getAdmin()](flattened/UpgradeableTokenSaleV1.sol#L950-L952) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L950-L952


 - [ ] ID-44
[AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/UpgradeableTokenSaleV1.sol#L186-L195) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L186-L195


 - [ ] ID-45
[Initializable._disableInitializers()](flattened/UpgradeableTokenSaleV1.sol#L349-L351) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L349-L351


 - [ ] ID-46
[ContextUpgradeable.__Context_init()](flattened/UpgradeableTokenSaleV1.sol#L385) is never used and should be removed

flattened/UpgradeableTokenSaleV1.sol#L385


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-47
Pragma version[^0.8.0](flattened/UpgradeableTokenSaleV1.sol#L4) allows old versions

flattened/UpgradeableTokenSaleV1.sol#L4


 - [ ] ID-48
solc-0.8.9 is not recommended for deployment

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-49
Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/UpgradeableTokenSaleV1.sol#L60-L71):
	- [(success) = recipient.call{value: amount}()](flattened/UpgradeableTokenSaleV1.sol#L66)

flattened/UpgradeableTokenSaleV1.sol#L60-L71


 - [ ] ID-50
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/UpgradeableTokenSaleV1.sol#L143-L159):
	- [(success,returndata) = target.call{value: value}(data)](flattened/UpgradeableTokenSaleV1.sol#L155-L157)

flattened/UpgradeableTokenSaleV1.sol#L143-L159


 - [ ] ID-51
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/UpgradeableTokenSaleV1.sol#L186-L195):
	- [(success,returndata) = target.staticcall(data)](flattened/UpgradeableTokenSaleV1.sol#L193)

flattened/UpgradeableTokenSaleV1.sol#L186-L195


 - [ ] ID-52
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/UpgradeableTokenSaleV1.sol#L1038-L1055):
	- [(success,returndata) = target.delegatecall(data)](flattened/UpgradeableTokenSaleV1.sol#L1048)

flattened/UpgradeableTokenSaleV1.sol#L1038-L1055


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-53
Parameter [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._SIG](flattened/UpgradeableTokenSaleV1.sol#L1593) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1593


 - [ ] ID-54
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L838) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L838


 - [ ] ID-55
Variable [ContextUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L402) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L402


 - [ ] ID-56
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L1226-L1228) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1226-L1228


 - [ ] ID-57
Parameter [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._phase2StartTs](flattened/UpgradeableTokenSaleV1.sol#L1591) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1591


 - [ ] ID-58
Parameter [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._phase1StartTs](flattened/UpgradeableTokenSaleV1.sol#L1590) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1590


 - [ ] ID-59
Variable [UpgradeableTokenSaleV1.SIG](flattened/UpgradeableTokenSaleV1.sol#L1366) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1366


 - [ ] ID-60
Function [OwnableUpgradeable.__Ownable_init()](flattened/UpgradeableTokenSaleV1.sol#L428-L430) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L428-L430


 - [ ] ID-61
Variable [OwnableUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L489) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L489


 - [ ] ID-62
Variable [UUPSUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L1186) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1186


 - [ ] ID-63
Variable [PausableUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L1352) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1352


 - [ ] ID-64
Variable [ERC1967UpgradeUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L1062) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1062


 - [ ] ID-65
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](flattened/UpgradeableTokenSaleV1.sol#L1222-L1224) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1222-L1224


 - [ ] ID-66
Function [ContextUpgradeable.__Context_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L387) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L387


 - [ ] ID-67
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L1084) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1084


 - [ ] ID-68
Variable [ReentrancyGuardUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L1256) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1256


 - [ ] ID-69
Function [OwnableUpgradeable.__Ownable_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L432-L434) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L432-L434


 - [ ] ID-70
Variable [UUPSUpgradeable.__self](flattened/UpgradeableTokenSaleV1.sol#L1087) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1087


 - [ ] ID-71
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/UpgradeableTokenSaleV1.sol#L836) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L836


 - [ ] ID-72
Parameter [UpgradeableTokenSaleV1.withdraw(uint256)._requiredAmount](flattened/UpgradeableTokenSaleV1.sol#L1432) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1432


 - [ ] ID-73
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/UpgradeableTokenSaleV1.sol#L1082) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1082


 - [ ] ID-74
Parameter [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._receiver](flattened/UpgradeableTokenSaleV1.sol#L1594) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1594


 - [ ] ID-75
Parameter [UpgradeableTokenSaleV1.setReceiver(address)._receiver](flattened/UpgradeableTokenSaleV1.sol#L1660) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1660


 - [ ] ID-76
Function [PausableUpgradeable.__Pausable_init()](flattened/UpgradeableTokenSaleV1.sol#L1284-L1286) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1284-L1286


 - [ ] ID-77
Function [ContextUpgradeable.__Context_init()](flattened/UpgradeableTokenSaleV1.sol#L385) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L385


 - [ ] ID-78
Parameter [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._phase2EndTs](flattened/UpgradeableTokenSaleV1.sol#L1592) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1592


 - [ ] ID-79
Function [PausableUpgradeable.__Pausable_init_unchained()](flattened/UpgradeableTokenSaleV1.sol#L1288-L1290) is not in mixedCase

flattened/UpgradeableTokenSaleV1.sol#L1288-L1290


## reentrancy-unlimited-gas
Impact: Informational
Confidence: Medium
 - [ ] ID-80
Reentrancy in [UpgradeableTokenSaleV1.adminWithdraw()](flattened/UpgradeableTokenSaleV1.sol#L1627-L1639):
	External calls:
	- [address(receiver).transfer(balanceOfKLAY)](flattened/UpgradeableTokenSaleV1.sol#L1636)
	Event emitted after the call(s):
	- [AdminWithdraw(balanceOfKLAY)](flattened/UpgradeableTokenSaleV1.sol#L1638)

flattened/UpgradeableTokenSaleV1.sol#L1627-L1639


 - [ ] ID-81
Reentrancy in [UpgradeableTokenSaleV1.withdraw(uint256)](flattened/UpgradeableTokenSaleV1.sol#L1432-L1484):
	External calls:
	- [address(msg.sender).transfer(_requiredAmount)](flattened/UpgradeableTokenSaleV1.sol#L1481)
	Event emitted after the call(s):
	- [Withdrawal(msg.sender,_requiredAmount)](flattened/UpgradeableTokenSaleV1.sol#L1483)

flattened/UpgradeableTokenSaleV1.sol#L1432-L1484


## similar-names
Impact: Informational
Confidence: Medium
 - [ ] ID-82
Variable [UpgradeableTokenSaleV1.phase1StartTs](flattened/UpgradeableTokenSaleV1.sol#L1372) is too similar to [UpgradeableTokenSaleV1.phase2StartTs](flattened/UpgradeableTokenSaleV1.sol#L1373)

flattened/UpgradeableTokenSaleV1.sol#L1372


 - [ ] ID-83
Variable [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._phase1StartTs](flattened/UpgradeableTokenSaleV1.sol#L1590) is too similar to [UpgradeableTokenSaleV1.setInitialInfo(uint256,uint256,uint256,address,address)._phase2StartTs](flattened/UpgradeableTokenSaleV1.sol#L1591)

flattened/UpgradeableTokenSaleV1.sol#L1590


## too-many-digits
Impact: Informational
Confidence: Medium
 - [ ] ID-84
[UpgradeableTokenSaleV1.slitherConstructorConstantVariables()](flattened/UpgradeableTokenSaleV1.sol#L1355-L1688) uses literals with too many digits:
	- [TOTAL_SIG_SUPPLY = 9000000000000000000000000](flattened/UpgradeableTokenSaleV1.sol#L1377)

flattened/UpgradeableTokenSaleV1.sol#L1355-L1688


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-85
[PausableUpgradeable.__gap](flattened/UpgradeableTokenSaleV1.sol#L1352) is never used in [UpgradeableTokenSaleV1](flattened/UpgradeableTokenSaleV1.sol#L1355-L1688)

flattened/UpgradeableTokenSaleV1.sol#L1352


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-86
transferOwnership(address) should be declared external:
	- [OwnableUpgradeable.transferOwnership(address)](flattened/UpgradeableTokenSaleV1.sol#L466-L472)

flattened/UpgradeableTokenSaleV1.sol#L466-L472


 - [ ] ID-87
renounceOwnership() should be declared external:
	- [OwnableUpgradeable.renounceOwnership()](flattened/UpgradeableTokenSaleV1.sol#L458-L460)

flattened/UpgradeableTokenSaleV1.sol#L458-L460


