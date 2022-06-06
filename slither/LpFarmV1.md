Summary
 - [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
 - [reentrancy-eth](#reentrancy-eth) (3 results) (High)
 - [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (4 results) (Medium)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [unused-return](#unused-return) (1 results) (Medium)
 - [calls-loop](#calls-loop) (2 results) (Low)
 - [variable-scope](#variable-scope) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (4 results) (Low)
 - [assembly](#assembly) (5 results) (Informational)
 - [dead-code](#dead-code) (24 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (48 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (2 results) (Optimization)
## controlled-delegatecall
Impact: High
Confidence: Medium
 - [ ] ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/LpFarmV1.sol#L1034-L1051) uses delegatecall to a input-controlled function id
	- [(success,returndata) = target.delegatecall(data)](flattened/LpFarmV1.sol#L1044)

flattened/LpFarmV1.sol#L1034-L1051


## reentrancy-eth
Impact: High
Confidence: Medium
 - [ ] ID-1
Reentrancy in [LpFarmV1.claim(uint256)](flattened/LpFarmV1.sol#L1682-L1702):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1693)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1693)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	State variables written after the call(s):
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1695)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1697-L1699)

flattened/LpFarmV1.sol#L1682-L1702


 - [ ] ID-2
Reentrancy in [LpFarmV1.withdraw(uint256,uint256)](flattened/LpFarmV1.sol#L1637-L1676):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1662)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1662)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	State variables written after the call(s):
	- [_updateBoostWeight(msg.sender,_pid)](flattened/LpFarmV1.sol#L1671)
		- [pool.boostLastRewardBlock = lastBlock](flattened/LpFarmV1.sol#L1845)
		- [pool.totalBoostWeight = pool.totalBoostWeight - oldBoostWeight + newBoostWeight](flattened/LpFarmV1.sol#L1787-L1790)
		- [pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](flattened/LpFarmV1.sol#L1855-L1858)
		- [pool.boostLastRewardBlock = block.number](flattened/LpFarmV1.sol#L1859)
	- [user.amount -= _amount](flattened/LpFarmV1.sol#L1664)
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1665)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1667-L1669)
	- [_updateBoostWeight(msg.sender,_pid)](flattened/LpFarmV1.sol#L1671)
		- [user.boostWeight = newBoostWeight](flattened/LpFarmV1.sol#L1786)

flattened/LpFarmV1.sol#L1637-L1676


 - [ ] ID-3
Reentrancy in [LpFarmV1.deposit(uint256,uint256)](flattened/LpFarmV1.sol#L1590-L1630):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1611)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	- [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](flattened/LpFarmV1.sol#L1614-L1618)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1611)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	State variables written after the call(s):
	- [user.amount += _amount](flattened/LpFarmV1.sol#L1620)
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1621)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](flattened/LpFarmV1.sol#L1624-L1626)

flattened/LpFarmV1.sol#L1590-L1630


## unprotected-upgrade
Impact: High
Confidence: High
 - [ ] ID-4
[LpFarmV1](flattened/LpFarmV1.sol#L1367-L2001) is an upgradeable contract that does not protect its initiliaze functions: [LpFarmV1.initialize()](flattened/LpFarmV1.sol#L1445-L1449). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/LpFarmV1.sol#L1142-L1145)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/LpFarmV1.sol#L1155-L1163)
flattened/LpFarmV1.sol#L1367-L2001


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-5
[LpFarmV1.getUserBoostPending(uint256,address)](flattened/LpFarmV1.sol#L1952-L1988) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / (totalAllocPoint)](flattened/LpFarmV1.sol#L1974-L1976)
	-[boostAccERC20PerShare = boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](flattened/LpFarmV1.sol#L1978-L1981)

flattened/LpFarmV1.sol#L1952-L1988


 - [ ] ID-6
[LpFarmV1.getUserBasePending(uint256,address)](flattened/LpFarmV1.sol#L1918-L1947) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint](flattened/LpFarmV1.sol#L1938-L1940)
	-[accERC20PerShare = accERC20PerShare + ((erc20Reward * 1e36) / lpSupply)](flattened/LpFarmV1.sol#L1941-L1943)

flattened/LpFarmV1.sol#L1918-L1947


 - [ ] ID-7
[LpFarmV1._updatePoolWithBaseReward(uint256)](flattened/LpFarmV1.sol#L1807-L1830) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint](flattened/LpFarmV1.sol#L1822-L1823)
	-[pool.accERC20PerShare = pool.accERC20PerShare + (erc20Reward * 1e36) / lpSupply](flattened/LpFarmV1.sol#L1825-L1828)

flattened/LpFarmV1.sol#L1807-L1830


 - [ ] ID-8
[LpFarmV1._updatePoolWithBoostReward(uint256)](flattened/LpFarmV1.sol#L1836-L1860) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / totalAllocPoint](flattened/LpFarmV1.sol#L1851-L1853)
	-[pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](flattened/LpFarmV1.sol#L1855-L1858)

flattened/LpFarmV1.sol#L1836-L1860


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-9
[LpFarmV1._updatePoolWithBaseReward(uint256)](flattened/LpFarmV1.sol#L1807-L1830) uses a dangerous strict equality:
	- [lpSupply == 0](flattened/LpFarmV1.sol#L1815)

flattened/LpFarmV1.sol#L1807-L1830


## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-10
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/LpFarmV1.sol#L918) is a local variable never initialized

flattened/LpFarmV1.sol#L918


## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-11
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/LpFarmV1.sol#L905-L928) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/LpFarmV1.sol#L916-L925)

flattened/LpFarmV1.sol#L905-L928


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-12
[LpFarmV1._updateBoostWeight(address,uint256)](flattened/LpFarmV1.sol#L1776-L1791) has external calls inside a loop: [vxAmount = vxSIG.balanceOf(_addr)](flattened/LpFarmV1.sol#L1782)

flattened/LpFarmV1.sol#L1776-L1791


 - [ ] ID-13
[LpFarmV1._updatePoolWithBaseReward(uint256)](flattened/LpFarmV1.sol#L1807-L1830) has external calls inside a loop: [lpSupply = pool.lpToken.balanceOf(address(this))](flattened/LpFarmV1.sol#L1814)

flattened/LpFarmV1.sol#L1807-L1830


## variable-scope
Impact: Low
Confidence: High
 - [ ] ID-14
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/LpFarmV1.sol#L918)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](flattened/LpFarmV1.sol#L905-L928) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/LpFarmV1.sol#L919-L922)

flattened/LpFarmV1.sol#L918


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-15
Reentrancy in [LpFarmV1.fund(uint256)](flattened/LpFarmV1.sol#L1740-L1748):
	External calls:
	- [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](flattened/LpFarmV1.sol#L1745)
	Event emitted after the call(s):
	- [Funded(msg.sender,_amount,endBlock)](flattened/LpFarmV1.sol#L1747)

flattened/LpFarmV1.sol#L1740-L1748


 - [ ] ID-16
Reentrancy in [LpFarmV1.deposit(uint256,uint256)](flattened/LpFarmV1.sol#L1590-L1630):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1611)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	- [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](flattened/LpFarmV1.sol#L1614-L1618)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1611)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	Event emitted after the call(s):
	- [Deposit(msg.sender,_pid,_amount)](flattened/LpFarmV1.sol#L1629)

flattened/LpFarmV1.sol#L1590-L1630


 - [ ] ID-17
Reentrancy in [LpFarmV1.withdraw(uint256,uint256)](flattened/LpFarmV1.sol#L1637-L1676):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1662)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	- [pool.lpToken.safeTransfer(address(msg.sender),_amount)](flattened/LpFarmV1.sol#L1674)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1662)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	Event emitted after the call(s):
	- [Withdraw(msg.sender,_pid,_amount)](flattened/LpFarmV1.sol#L1675)

flattened/LpFarmV1.sol#L1637-L1676


 - [ ] ID-18
Reentrancy in [LpFarmV1.claim(uint256)](flattened/LpFarmV1.sol#L1682-L1702):
	External calls:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1693)
		- [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/LpFarmV1.sol#L421-L424)
		- [sig.safeTransfer(_to,_amount)](flattened/LpFarmV1.sol#L1800)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	External calls sending eth:
	- [transferSIG(msg.sender,pendingAmount)](flattened/LpFarmV1.sol#L1693)
		- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)
	Event emitted after the call(s):
	- [Claim(msg.sender,_pid,pendingAmount)](flattened/LpFarmV1.sol#L1701)

flattened/LpFarmV1.sol#L1682-L1702


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-19
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/LpFarmV1.sol#L786-L794) uses assembly
	- [INLINE ASM](flattened/LpFarmV1.sol#L791-L793)

flattened/LpFarmV1.sol#L786-L794


 - [ ] ID-20
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/LpFarmV1.sol#L286-L306) uses assembly
	- [INLINE ASM](flattened/LpFarmV1.sol#L298-L301)

flattened/LpFarmV1.sol#L286-L306


 - [ ] ID-21
[StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/LpFarmV1.sol#L773-L781) uses assembly
	- [INLINE ASM](flattened/LpFarmV1.sol#L778-L780)

flattened/LpFarmV1.sol#L773-L781


 - [ ] ID-22
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/LpFarmV1.sol#L812-L820) uses assembly
	- [INLINE ASM](flattened/LpFarmV1.sol#L817-L819)

flattened/LpFarmV1.sol#L812-L820


 - [ ] ID-23
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/LpFarmV1.sol#L799-L807) uses assembly
	- [INLINE ASM](flattened/LpFarmV1.sol#L804-L806)

flattened/LpFarmV1.sol#L799-L807


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-24
[ContextUpgradeable._msgData()](flattened/LpFarmV1.sol#L600-L602) is never used and should be removed

flattened/LpFarmV1.sol#L600-L602


 - [ ] ID-25
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/LpFarmV1.sol#L206-L218) is never used and should be removed

flattened/LpFarmV1.sol#L206-L218


 - [ ] ID-26
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](flattened/LpFarmV1.sol#L351-L367) is never used and should be removed

flattened/LpFarmV1.sol#L351-L367


 - [ ] ID-27
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/LpFarmV1.sol#L834) is never used and should be removed

flattened/LpFarmV1.sol#L834


 - [ ] ID-28
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/LpFarmV1.sol#L369-L383) is never used and should be removed

flattened/LpFarmV1.sol#L369-L383


 - [ ] ID-29
[AddressUpgradeable.functionCall(address,bytes)](flattened/LpFarmV1.sol#L174-L179) is never used and should be removed

flattened/LpFarmV1.sol#L174-L179


 - [ ] ID-30
[ERC1967UpgradeUpgradeable._getBeacon()](flattened/LpFarmV1.sol#L986-L988) is never used and should be removed

flattened/LpFarmV1.sol#L986-L988


 - [ ] ID-31
[ContextUpgradeable.__Context_init_unchained()](flattened/LpFarmV1.sol#L594) is never used and should be removed

flattened/LpFarmV1.sol#L594


 - [ ] ID-32
[StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/LpFarmV1.sol#L812-L820) is never used and should be removed

flattened/LpFarmV1.sol#L812-L820


 - [ ] ID-33
[AddressUpgradeable.sendValue(address,uint256)](flattened/LpFarmV1.sol#L143-L154) is never used and should be removed

flattened/LpFarmV1.sol#L143-L154


 - [ ] ID-34
[AddressUpgradeable.functionStaticCall(address,bytes)](flattened/LpFarmV1.sol#L250-L261) is never used and should be removed

flattened/LpFarmV1.sol#L250-L261


 - [ ] ID-35
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](flattened/LpFarmV1.sol#L1013-L1026) is never used and should be removed

flattened/LpFarmV1.sol#L1013-L1026


 - [ ] ID-36
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/LpFarmV1.sol#L385-L406) is never used and should be removed

flattened/LpFarmV1.sol#L385-L406


 - [ ] ID-37
[ERC1967UpgradeUpgradeable._setBeacon(address)](flattened/LpFarmV1.sol#L993-L1005) is never used and should be removed

flattened/LpFarmV1.sol#L993-L1005


 - [ ] ID-38
[UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/LpFarmV1.sol#L1078) is never used and should be removed

flattened/LpFarmV1.sol#L1078


 - [ ] ID-39
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/LpFarmV1.sol#L832) is never used and should be removed

flattened/LpFarmV1.sol#L832


 - [ ] ID-40
[ERC1967UpgradeUpgradeable._setAdmin(address)](flattened/LpFarmV1.sol#L953-L959) is never used and should be removed

flattened/LpFarmV1.sol#L953-L959


 - [ ] ID-41
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/LpFarmV1.sol#L1080) is never used and should be removed

flattened/LpFarmV1.sol#L1080


 - [ ] ID-42
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/LpFarmV1.sol#L799-L807) is never used and should be removed

flattened/LpFarmV1.sol#L799-L807


 - [ ] ID-43
[ERC1967UpgradeUpgradeable._changeAdmin(address)](flattened/LpFarmV1.sol#L966-L969) is never used and should be removed

flattened/LpFarmV1.sol#L966-L969


 - [ ] ID-44
[ERC1967UpgradeUpgradeable._getAdmin()](flattened/LpFarmV1.sol#L946-L948) is never used and should be removed

flattened/LpFarmV1.sol#L946-L948


 - [ ] ID-45
[AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/LpFarmV1.sol#L269-L278) is never used and should be removed

flattened/LpFarmV1.sol#L269-L278


 - [ ] ID-46
[Initializable._disableInitializers()](flattened/LpFarmV1.sol#L556-L558) is never used and should be removed

flattened/LpFarmV1.sol#L556-L558


 - [ ] ID-47
[ContextUpgradeable.__Context_init()](flattened/LpFarmV1.sol#L592) is never used and should be removed

flattened/LpFarmV1.sol#L592


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-48
Pragma version[^0.8.0](flattened/LpFarmV1.sol#L2) allows old versions

flattened/LpFarmV1.sol#L2


 - [ ] ID-49
solc-0.8.9 is not recommended for deployment

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-50
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/LpFarmV1.sol#L269-L278):
	- [(success,returndata) = target.staticcall(data)](flattened/LpFarmV1.sol#L276)

flattened/LpFarmV1.sol#L269-L278


 - [ ] ID-51
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](flattened/LpFarmV1.sol#L1034-L1051):
	- [(success,returndata) = target.delegatecall(data)](flattened/LpFarmV1.sol#L1044)

flattened/LpFarmV1.sol#L1034-L1051


 - [ ] ID-52
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/LpFarmV1.sol#L226-L242):
	- [(success,returndata) = target.call{value: value}(data)](flattened/LpFarmV1.sol#L238-L240)

flattened/LpFarmV1.sol#L226-L242


 - [ ] ID-53
Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/LpFarmV1.sol#L143-L154):
	- [(success) = recipient.call{value: amount}()](flattened/LpFarmV1.sol#L149)

flattened/LpFarmV1.sol#L143-L154


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-54
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._vxSIG](flattened/LpFarmV1.sol#L1456) is not in mixedCase

flattened/LpFarmV1.sol#L1456


 - [ ] ID-55
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._startBlock](flattened/LpFarmV1.sol#L1458) is not in mixedCase

flattened/LpFarmV1.sol#L1458


 - [ ] ID-56
Parameter [LpFarmV1.deposited(uint256,address)._pid](flattened/LpFarmV1.sol#L1993) is not in mixedCase

flattened/LpFarmV1.sol#L1993


 - [ ] ID-57
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._baseAllocPoint](flattened/LpFarmV1.sol#L1517) is not in mixedCase

flattened/LpFarmV1.sol#L1517


 - [ ] ID-58
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](flattened/LpFarmV1.sol#L834) is not in mixedCase

flattened/LpFarmV1.sol#L834


 - [ ] ID-59
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._rewardPerBlock](flattened/LpFarmV1.sol#L1457) is not in mixedCase

flattened/LpFarmV1.sol#L1457


 - [ ] ID-60
Parameter [LpFarmV1.getUserBoostPending(uint256,address)._pid](flattened/LpFarmV1.sol#L1952) is not in mixedCase

flattened/LpFarmV1.sol#L1952


 - [ ] ID-61
Parameter [LpFarmV1.getUserTotalPendingReward(uint256,address)._pid](flattened/LpFarmV1.sol#L1901) is not in mixedCase

flattened/LpFarmV1.sol#L1901


 - [ ] ID-62
Variable [ContextUpgradeable.__gap](flattened/LpFarmV1.sol#L609) is not in mixedCase

flattened/LpFarmV1.sol#L609


 - [ ] ID-63
Parameter [LpFarmV1.withdraw(uint256,uint256)._amount](flattened/LpFarmV1.sol#L1637) is not in mixedCase

flattened/LpFarmV1.sol#L1637


 - [ ] ID-64
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](flattened/LpFarmV1.sol#L1222-L1224) is not in mixedCase

flattened/LpFarmV1.sol#L1222-L1224


 - [ ] ID-65
Parameter [LpFarmV1.setVxSIGAddress(IvxERC20)._vxSIG](flattened/LpFarmV1.sol#L1472) is not in mixedCase

flattened/LpFarmV1.sol#L1472


 - [ ] ID-66
Function [OwnableUpgradeable.__Ownable_init()](flattened/LpFarmV1.sol#L635-L637) is not in mixedCase

flattened/LpFarmV1.sol#L635-L637


 - [ ] ID-67
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._boostAllocPoint](flattened/LpFarmV1.sol#L1484) is not in mixedCase

flattened/LpFarmV1.sol#L1484


 - [ ] ID-68
Parameter [LpFarmV1.getUserBoostPending(uint256,address)._user](flattened/LpFarmV1.sol#L1952) is not in mixedCase

flattened/LpFarmV1.sol#L1952


 - [ ] ID-69
Variable [OwnableUpgradeable.__gap](flattened/LpFarmV1.sol#L696) is not in mixedCase

flattened/LpFarmV1.sol#L696


 - [ ] ID-70
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._pid](flattened/LpFarmV1.sol#L1516) is not in mixedCase

flattened/LpFarmV1.sol#L1516


 - [ ] ID-71
Variable [UUPSUpgradeable.__gap](flattened/LpFarmV1.sol#L1182) is not in mixedCase

flattened/LpFarmV1.sol#L1182


 - [ ] ID-72
Variable [PausableUpgradeable.__gap](flattened/LpFarmV1.sol#L1348) is not in mixedCase

flattened/LpFarmV1.sol#L1348


 - [ ] ID-73
Parameter [LpFarmV1.getUserTotalPendingReward(uint256,address)._user](flattened/LpFarmV1.sol#L1901) is not in mixedCase

flattened/LpFarmV1.sol#L1901


 - [ ] ID-74
Variable [ERC1967UpgradeUpgradeable.__gap](flattened/LpFarmV1.sol#L1058) is not in mixedCase

flattened/LpFarmV1.sol#L1058


 - [ ] ID-75
Parameter [LpFarmV1.setRewardPerBlock(uint256)._rewardPerBlock](flattened/LpFarmV1.sol#L1547) is not in mixedCase

flattened/LpFarmV1.sol#L1547


 - [ ] ID-76
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](flattened/LpFarmV1.sol#L1218-L1220) is not in mixedCase

flattened/LpFarmV1.sol#L1218-L1220


 - [ ] ID-77
Parameter [LpFarmV1.transferSIG(address,uint256)._amount](flattened/LpFarmV1.sol#L1798) is not in mixedCase

flattened/LpFarmV1.sol#L1798


 - [ ] ID-78
Function [ContextUpgradeable.__Context_init_unchained()](flattened/LpFarmV1.sol#L594) is not in mixedCase

flattened/LpFarmV1.sol#L594


 - [ ] ID-79
Parameter [LpFarmV1.deposit(uint256,uint256)._pid](flattened/LpFarmV1.sol#L1590) is not in mixedCase

flattened/LpFarmV1.sol#L1590


 - [ ] ID-80
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](flattened/LpFarmV1.sol#L1080) is not in mixedCase

flattened/LpFarmV1.sol#L1080


 - [ ] ID-81
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._lpToken](flattened/LpFarmV1.sol#L1485) is not in mixedCase

flattened/LpFarmV1.sol#L1485


 - [ ] ID-82
Variable [ReentrancyGuardUpgradeable.__gap](flattened/LpFarmV1.sol#L1252) is not in mixedCase

flattened/LpFarmV1.sol#L1252


 - [ ] ID-83
Parameter [LpFarmV1.claim(uint256)._pid](flattened/LpFarmV1.sol#L1682) is not in mixedCase

flattened/LpFarmV1.sol#L1682


 - [ ] ID-84
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._baseAllocPoint](flattened/LpFarmV1.sol#L1483) is not in mixedCase

flattened/LpFarmV1.sol#L1483


 - [ ] ID-85
Parameter [LpFarmV1.transferSIG(address,uint256)._to](flattened/LpFarmV1.sol#L1798) is not in mixedCase

flattened/LpFarmV1.sol#L1798


 - [ ] ID-86
Function [OwnableUpgradeable.__Ownable_init_unchained()](flattened/LpFarmV1.sol#L639-L641) is not in mixedCase

flattened/LpFarmV1.sol#L639-L641


 - [ ] ID-87
Variable [UUPSUpgradeable.__self](flattened/LpFarmV1.sol#L1083) is not in mixedCase

flattened/LpFarmV1.sol#L1083


 - [ ] ID-88
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](flattened/LpFarmV1.sol#L832) is not in mixedCase

flattened/LpFarmV1.sol#L832


 - [ ] ID-89
Parameter [LpFarmV1.withdraw(uint256,uint256)._pid](flattened/LpFarmV1.sol#L1637) is not in mixedCase

flattened/LpFarmV1.sol#L1637


 - [ ] ID-90
Parameter [LpFarmV1.getUserBasePending(uint256,address)._user](flattened/LpFarmV1.sol#L1918) is not in mixedCase

flattened/LpFarmV1.sol#L1918


 - [ ] ID-91
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](flattened/LpFarmV1.sol#L1078) is not in mixedCase

flattened/LpFarmV1.sol#L1078


 - [ ] ID-92
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._sig](flattened/LpFarmV1.sol#L1455) is not in mixedCase

flattened/LpFarmV1.sol#L1455


 - [ ] ID-93
Parameter [LpFarmV1.deposited(uint256,address)._user](flattened/LpFarmV1.sol#L1993) is not in mixedCase

flattened/LpFarmV1.sol#L1993


 - [ ] ID-94
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._boostAllocPoint](flattened/LpFarmV1.sol#L1518) is not in mixedCase

flattened/LpFarmV1.sol#L1518


 - [ ] ID-95
Function [PausableUpgradeable.__Pausable_init()](flattened/LpFarmV1.sol#L1280-L1282) is not in mixedCase

flattened/LpFarmV1.sol#L1280-L1282


 - [ ] ID-96
Function [ContextUpgradeable.__Context_init()](flattened/LpFarmV1.sol#L592) is not in mixedCase

flattened/LpFarmV1.sol#L592


 - [ ] ID-97
Parameter [LpFarmV1.updatePool(uint256)._pid](flattened/LpFarmV1.sol#L1721) is not in mixedCase

flattened/LpFarmV1.sol#L1721


 - [ ] ID-98
Parameter [LpFarmV1.fund(uint256)._amount](flattened/LpFarmV1.sol#L1740) is not in mixedCase

flattened/LpFarmV1.sol#L1740


 - [ ] ID-99
Parameter [LpFarmV1.getUserBasePending(uint256,address)._pid](flattened/LpFarmV1.sol#L1918) is not in mixedCase

flattened/LpFarmV1.sol#L1918


 - [ ] ID-100
Parameter [LpFarmV1.deposit(uint256,uint256)._amount](flattened/LpFarmV1.sol#L1590) is not in mixedCase

flattened/LpFarmV1.sol#L1590


 - [ ] ID-101
Function [PausableUpgradeable.__Pausable_init_unchained()](flattened/LpFarmV1.sol#L1284-L1286) is not in mixedCase

flattened/LpFarmV1.sol#L1284-L1286


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-102
[PausableUpgradeable.__gap](flattened/LpFarmV1.sol#L1348) is never used in [LpFarmV1](flattened/LpFarmV1.sol#L1367-L2001)

flattened/LpFarmV1.sol#L1348


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-103
transferOwnership(address) should be declared external:
	- [OwnableUpgradeable.transferOwnership(address)](flattened/LpFarmV1.sol#L673-L679)

flattened/LpFarmV1.sol#L673-L679


 - [ ] ID-104
renounceOwnership() should be declared external:
	- [OwnableUpgradeable.renounceOwnership()](flattened/LpFarmV1.sol#L665-L667)

flattened/LpFarmV1.sol#L665-L667


