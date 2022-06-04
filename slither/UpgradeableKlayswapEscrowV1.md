Summary
 - [arbitrary-send](#arbitrary-send) (2 results) (High)
 - [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
 - [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [unused-return](#unused-return) (5 results) (Medium)
 - [calls-loop](#calls-loop) (1 results) (Low)
 - [variable-scope](#variable-scope) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (3 results) (Low)
 - [assembly](#assembly) (5 results) (Informational)
 - [dead-code](#dead-code) (25 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (38 results) (Informational)
 - [too-many-digits](#too-many-digits) (1 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (2 results) (Optimization)
## arbitrary-send
Impact: High
Confidence: Medium
 - [ ] ID-0
[UpgradeableKlayswapEscrowV1.exchangeKlayPos(address,uint256,address[],uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L1758-L1765) sends eth to arbitrary user
	Dangerous calls:
	- [factory.exchangeKlayPos{value: klayAmount}(token,amount,path)](flattened/UpgradeableKlayswapEscrowV1.sol#L1764)

flattened/UpgradeableKlayswapEscrowV1.sol#L1758-L1765


 - [ ] ID-1
[UpgradeableKlayswapEscrowV1.exchangeKlayNeg(address,uint256,address[],uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L1770-L1777) sends eth to arbitrary user
	Dangerous calls:
	- [factory.exchangeKlayNeg{value: klayAmount}(token,amount,path)](flattened/UpgradeableKlayswapEscrowV1.sol#L1776)

flattened/UpgradeableKlayswapEscrowV1.sol#L1770-L1777


## controlled-delegatecall
Impact: High
Confidence: Medium
 - [ ] ID-2
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051) uses delegatecall to a input-controlled function id
	- [(success,returndata) = target.delegatecall(data)](flattened/UpgradeableKlayswapEscrowV1.sol#L1044)

flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051


## unprotected-upgrade
Impact: High
Confidence: High
 - [ ] ID-3
[UpgradeableKlayswapEscrowV1](flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1827) is an upgradeable contract that does not protect its initiliaze functions: [UpgradeableKlayswapEscrowV1.initialize()](flattened/UpgradeableKlayswapEscrowV1.sol#L1513-L1517). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/UpgradeableKlayswapEscrowV1.sol#L1142-L1145)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/UpgradeableKlayswapEscrowV1.sol#L1155-L1163)
flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1827


## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-4
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/UpgradeableKlayswapEscrowV1.sol#L918) is a local variable never initialized

flattened/UpgradeableKlayswapEscrowV1.sol#L918


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-5
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/UpgradeableKlayswapEscrowV1.sol#L916-L925)

flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928


 - [ ] ID-6
[UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542) ignores return value by [kspToken.approve(address(votingKSP),type()(uint256).max)](flattened/UpgradeableKlayswapEscrowV1.sol#L1539)

flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542


 - [ ] ID-7
[UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542) ignores return value by [oUsdtToken.approve(address(feeDistributor),type()(uint256).max)](flattened/UpgradeableKlayswapEscrowV1.sol#L1540)

flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542


 - [ ] ID-8
[UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542) ignores return value by [kspToken.approve(address(feeDistributor),type()(uint256).max)](flattened/UpgradeableKlayswapEscrowV1.sol#L1541)

flattened/UpgradeableKlayswapEscrowV1.sol#L1522-L1542


 - [ ] ID-9
[UpgradeableKlayswapEscrowV1.approveToken(address,address)](flattened/UpgradeableKlayswapEscrowV1.sol#L1810-L1812) ignores return value by [IERC20Upgradeable(_token).approve(address(_to),type()(uint256).max)](flattened/UpgradeableKlayswapEscrowV1.sol#L1811)

flattened/UpgradeableKlayswapEscrowV1.sol#L1810-L1812


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-10
[UpgradeableKlayswapEscrowV1.addVoting(address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L1680-L1683) has external calls inside a loop: [poolVoting.addVoting(exchange,amount)](flattened/UpgradeableKlayswapEscrowV1.sol#L1681)

flattened/UpgradeableKlayswapEscrowV1.sol#L1680-L1683


## variable-scope
Impact: Low
Confidence: High
 - [ ] ID-11
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/UpgradeableKlayswapEscrowV1.sol#L918)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/UpgradeableKlayswapEscrowV1.sol#L919-L922)

flattened/UpgradeableKlayswapEscrowV1.sol#L918


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-12
Reentrancy in [UpgradeableKlayswapEscrowV1.addVoting(address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L1680-L1683):
	External calls:
	- [poolVoting.addVoting(exchange,amount)](flattened/UpgradeableKlayswapEscrowV1.sol#L1681)
	Event emitted after the call(s):
	- [Voted(exchange,amount)](flattened/UpgradeableKlayswapEscrowV1.sol#L1682)

flattened/UpgradeableKlayswapEscrowV1.sol#L1680-L1683


 - [ ] ID-13
Reentrancy in [UpgradeableKlayswapEscrowV1.forwardFeeToFeeDistributor()](flattened/UpgradeableKlayswapEscrowV1.sol#L1571-L1589):
	External calls:
	- [feeDistributor.depositERC20(address(kspToken),kspTokenBalance)](flattened/UpgradeableKlayswapEscrowV1.sol#L1581)
	- [feeDistributor.depositERC20(address(oUsdtToken),oUsdtTokenBalance)](flattened/UpgradeableKlayswapEscrowV1.sol#L1585)
	Event emitted after the call(s):
	- [ForwardedFee(kspTokenBalance,oUsdtTokenBalance)](flattened/UpgradeableKlayswapEscrowV1.sol#L1588)

flattened/UpgradeableKlayswapEscrowV1.sol#L1571-L1589


 - [ ] ID-14
Reentrancy in [UpgradeableKlayswapEscrowV1.depositKSP(uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L1656-L1663):
	External calls:
	- [kspToken.safeTransferFrom(msg.sender,address(this),_amount * 1000000000000000000)](flattened/UpgradeableKlayswapEscrowV1.sol#L1659)
	- [votingKSP.lockKSP(_amount,MAX_LOCK_PERIOD)](flattened/UpgradeableKlayswapEscrowV1.sol#L1660)
	Event emitted after the call(s):
	- [DepositKSP(msg.sender,_amount * 1000000000000000000)](flattened/UpgradeableKlayswapEscrowV1.sol#L1662)

flattened/UpgradeableKlayswapEscrowV1.sol#L1656-L1663


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-15
[StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L773-L781) uses assembly
	- [INLINE ASM](flattened/UpgradeableKlayswapEscrowV1.sol#L778-L780)

flattened/UpgradeableKlayswapEscrowV1.sol#L773-L781


 - [ ] ID-16
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820) uses assembly
	- [INLINE ASM](flattened/UpgradeableKlayswapEscrowV1.sol#L817-L819)

flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820


 - [ ] ID-17
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/UpgradeableKlayswapEscrowV1.sol#L201-L221) uses assembly
	- [INLINE ASM](flattened/UpgradeableKlayswapEscrowV1.sol#L213-L216)

flattened/UpgradeableKlayswapEscrowV1.sol#L201-L221


 - [ ] ID-18
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807) uses assembly
	- [INLINE ASM](flattened/UpgradeableKlayswapEscrowV1.sol#L804-L806)

flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807


 - [ ] ID-19
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L786-L794) uses assembly
	- [INLINE ASM](flattened/UpgradeableKlayswapEscrowV1.sol#L791-L793)

flattened/UpgradeableKlayswapEscrowV1.sol#L786-L794


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-20
[ContextUpgradeable._msgData()](flattened/UpgradeableKlayswapEscrowV1.sol#L389-L391) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L389-L391


 - [ ] ID-21
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L121-L133) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L121-L133


 - [ ] ID-22
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L615-L631) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L615-L631


 - [ ] ID-23
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L834) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L834


 - [ ] ID-24
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L633-L647) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L633-L647


 - [ ] ID-25
[AddressUpgradeable.functionCall(address,bytes)](flattened/UpgradeableKlayswapEscrowV1.sol#L89-L94) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L89-L94


 - [ ] ID-26
[ERC1967UpgradeUpgradeable._getBeacon()](flattened/UpgradeableKlayswapEscrowV1.sol#L986-L988) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L986-L988


 - [ ] ID-27
[ContextUpgradeable.__Context_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L383) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L383


 - [ ] ID-28
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820


 - [ ] ID-29
[AddressUpgradeable.sendValue(address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69


 - [ ] ID-30
[AddressUpgradeable.functionStaticCall(address,bytes)](flattened/UpgradeableKlayswapEscrowV1.sol#L165-L176) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L165-L176


 - [ ] ID-31
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](flattened/UpgradeableKlayswapEscrowV1.sol#L1013-L1026) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1013-L1026


 - [ ] ID-32
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L649-L670) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L649-L670


 - [ ] ID-33
[ERC1967UpgradeUpgradeable._setBeacon(address)](flattened/UpgradeableKlayswapEscrowV1.sol#L993-L1005) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L993-L1005


 - [ ] ID-34
[UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L1078) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1078


 - [ ] ID-35
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L832) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L832


 - [ ] ID-36
[ERC1967UpgradeUpgradeable._setAdmin(address)](flattened/UpgradeableKlayswapEscrowV1.sol#L953-L959) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L953-L959


 - [ ] ID-37
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L1080) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1080


 - [ ] ID-38
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807


 - [ ] ID-39
[ERC1967UpgradeUpgradeable._changeAdmin(address)](flattened/UpgradeableKlayswapEscrowV1.sol#L966-L969) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L966-L969


 - [ ] ID-40
[ERC1967UpgradeUpgradeable._getAdmin()](flattened/UpgradeableKlayswapEscrowV1.sol#L946-L948) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L946-L948


 - [ ] ID-41
[AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193


 - [ ] ID-42
[Initializable._disableInitializers()](flattened/UpgradeableKlayswapEscrowV1.sol#L345-L347) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L345-L347


 - [ ] ID-43
[SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable,address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L585-L594) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L585-L594


 - [ ] ID-44
[ContextUpgradeable.__Context_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L381) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L381


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-45
Pragma version[^0.8.0](flattened/UpgradeableKlayswapEscrowV1.sol#L2) allows old versions

flattened/UpgradeableKlayswapEscrowV1.sol#L2


 - [ ] ID-46
solc-0.8.9 is not recommended for deployment

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-47
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157):
	- [(success,returndata) = target.call{value: value}(data)](flattened/UpgradeableKlayswapEscrowV1.sol#L153-L155)

flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157


 - [ ] ID-48
Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69):
	- [(success) = recipient.call{value: amount}()](flattened/UpgradeableKlayswapEscrowV1.sol#L64)

flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69


 - [ ] ID-49
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193):
	- [(success,returndata) = target.staticcall(data)](flattened/UpgradeableKlayswapEscrowV1.sol#L191)

flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193


 - [ ] ID-50
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051):
	- [(success,returndata) = target.delegatecall(data)](flattened/UpgradeableKlayswapEscrowV1.sol#L1044)

flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-51
Parameter [UpgradeableKlayswapEscrowV1.setOperator(address[])._operators](flattened/UpgradeableKlayswapEscrowV1.sol#L1495) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1495


 - [ ] ID-52
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._poolVoting](flattened/UpgradeableKlayswapEscrowV1.sol#L1526) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1526


 - [ ] ID-53
Parameter [UpgradeableKlayswapEscrowV1.approveToken(address,address)._token](flattened/UpgradeableKlayswapEscrowV1.sol#L1810) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1810


 - [ ] ID-54
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L834) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L834


 - [ ] ID-55
Parameter [UpgradeableKlayswapEscrowV1.transferFrom(address,address,uint256)._value](flattened/UpgradeableKlayswapEscrowV1.sol#L1615) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1615


 - [ ] ID-56
Variable [ContextUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L398) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L398


 - [ ] ID-57
Parameter [UpgradeableKlayswapEscrowV1.transferFrom(address,address,uint256)._to](flattened/UpgradeableKlayswapEscrowV1.sol#L1614) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1614


 - [ ] ID-58
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L1222-L1224) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1222-L1224


 - [ ] ID-59
Parameter [UpgradeableKlayswapEscrowV1.approve(address,uint256)._spender](flattened/UpgradeableKlayswapEscrowV1.sol#L1593) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1593


 - [ ] ID-60
Parameter [UpgradeableKlayswapEscrowV1.approveToken(address,address)._to](flattened/UpgradeableKlayswapEscrowV1.sol#L1810) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1810


 - [ ] ID-61
Function [OwnableUpgradeable.__Ownable_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L424-L426) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L424-L426


 - [ ] ID-62
Parameter [UpgradeableKlayswapEscrowV1.transfer(address,uint256)._to](flattened/UpgradeableKlayswapEscrowV1.sol#L1603) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1603


 - [ ] ID-63
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._sigmaVoter](flattened/UpgradeableKlayswapEscrowV1.sol#L1527) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1527


 - [ ] ID-64
Variable [OwnableUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L485) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L485


 - [ ] ID-65
Parameter [UpgradeableKlayswapEscrowV1.depositKSP(uint256)._amount](flattened/UpgradeableKlayswapEscrowV1.sol#L1656) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1656


 - [ ] ID-66
Variable [UUPSUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L1182) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1182


 - [ ] ID-67
Parameter [UpgradeableKlayswapEscrowV1.revokeOperator(address)._operator](flattened/UpgradeableKlayswapEscrowV1.sol#L1505) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1505


 - [ ] ID-68
Parameter [UpgradeableKlayswapEscrowV1.approve(address,uint256)._value](flattened/UpgradeableKlayswapEscrowV1.sol#L1593) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1593


 - [ ] ID-69
Variable [PausableUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L1348) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1348


 - [ ] ID-70
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._kusdtToken](flattened/UpgradeableKlayswapEscrowV1.sol#L1524) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1524


 - [ ] ID-71
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._factory](flattened/UpgradeableKlayswapEscrowV1.sol#L1528) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1528


 - [ ] ID-72
Variable [ERC1967UpgradeUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L1058) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1058


 - [ ] ID-73
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L1218-L1220) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1218-L1220


 - [ ] ID-74
Parameter [UpgradeableKlayswapEscrowV1.transferFrom(address,address,uint256)._from](flattened/UpgradeableKlayswapEscrowV1.sol#L1613) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1613


 - [ ] ID-75
Function [ContextUpgradeable.__Context_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L383) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L383


 - [ ] ID-76
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L1080) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1080


 - [ ] ID-77
Variable [ReentrancyGuardUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L1252) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1252


 - [ ] ID-78
Parameter [UpgradeableKlayswapEscrowV1.transfer(address,uint256)._value](flattened/UpgradeableKlayswapEscrowV1.sol#L1603) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1603


 - [ ] ID-79
Function [OwnableUpgradeable.__Ownable_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L428-L430) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L428-L430


 - [ ] ID-80
Variable [UUPSUpgradeable.__self](flattened/UpgradeableKlayswapEscrowV1.sol#L1083) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1083


 - [ ] ID-81
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L832) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L832


 - [ ] ID-82
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L1078) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1078


 - [ ] ID-83
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._votingKSP](flattened/UpgradeableKlayswapEscrowV1.sol#L1525) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1525


 - [ ] ID-84
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._feeDistributor](flattened/UpgradeableKlayswapEscrowV1.sol#L1529) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1529


 - [ ] ID-85
Function [PausableUpgradeable.__Pausable_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L1280-L1282) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1280-L1282


 - [ ] ID-86
Parameter [UpgradeableKlayswapEscrowV1.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._kspToken](flattened/UpgradeableKlayswapEscrowV1.sol#L1523) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1523


 - [ ] ID-87
Function [ContextUpgradeable.__Context_init()](flattened/UpgradeableKlayswapEscrowV1.sol#L381) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L381


 - [ ] ID-88
Function [PausableUpgradeable.__Pausable_init_unchained()](flattened/UpgradeableKlayswapEscrowV1.sol#L1284-L1286) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1284-L1286


## too-many-digits
Impact: Informational
Confidence: Medium
 - [ ] ID-89
[UpgradeableKlayswapEscrowV1.slitherConstructorConstantVariables()](flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1827) uses literals with too many digits:
	- [MAX_LOCK_PERIOD = 1555200000](flattened/UpgradeableKlayswapEscrowV1.sol#L1476)

flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1827


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-90
[PausableUpgradeable.__gap](flattened/UpgradeableKlayswapEscrowV1.sol#L1348) is never used in [UpgradeableKlayswapEscrowV1](flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1827)

flattened/UpgradeableKlayswapEscrowV1.sol#L1348


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-91
transferOwnership(address) should be declared external:
	- [OwnableUpgradeable.transferOwnership(address)](flattened/UpgradeableKlayswapEscrowV1.sol#L462-L468)

flattened/UpgradeableKlayswapEscrowV1.sol#L462-L468


 - [ ] ID-92
renounceOwnership() should be declared external:
	- [OwnableUpgradeable.renounceOwnership()](flattened/UpgradeableKlayswapEscrowV1.sol#L454-L456)

flattened/UpgradeableKlayswapEscrowV1.sol#L454-L456


