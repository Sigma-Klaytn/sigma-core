Summary
 - [unchecked-transfer](#unchecked-transfer) (1 results) (High)
 - [divide-before-multiply](#divide-before-multiply) (4 results) (Medium)
 - [incorrect-equality](#incorrect-equality) (1 results) (Medium)
 - [reentrancy-no-eth](#reentrancy-no-eth) (5 results) (Medium)
 - [events-maths](#events-maths) (3 results) (Low)
 - [calls-loop](#calls-loop) (2 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (1 results) (Low)
 - [reentrancy-events](#reentrancy-events) (4 results) (Low)
 - [assembly](#assembly) (1 results) (Informational)
 - [dead-code](#dead-code) (11 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [low-level-calls](#low-level-calls) (4 results) (Informational)
 - [naming-convention](#naming-convention) (27 results) (Informational)
 - [external-function](#external-function) (7 results) (Optimization)
## unchecked-transfer
Impact: High
Confidence: Medium
 - [ ] ID-0
[LpFarm.erc20Transfer(address,uint256)](contracts/flattened/LpFarm.sol#L919-L922) ignores return value by [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)

contracts/flattened/LpFarm.sol#L919-L922


## divide-before-multiply
Impact: Medium
Confidence: Medium
 - [ ] ID-1
[LpFarm._updatePoolWithBaseReward(uint256)](contracts/flattened/LpFarm.sol#L928-L952) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * (rewardPerBlock) * (pool.allocPoint)) / (totalAllocPoint)](contracts/flattened/LpFarm.sol#L943-L945)
	-[pool.accERC20PerShare = pool.accERC20PerShare + (erc20Reward * 1e36) / lpSupply](contracts/flattened/LpFarm.sol#L947-L950)

contracts/flattened/LpFarm.sol#L928-L952


 - [ ] ID-2
[LpFarm.boostPending(uint256,address)](contracts/flattened/LpFarm.sol#L1054-L1090) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / (totalAllocPoint)](contracts/flattened/LpFarm.sol#L1076-L1078)
	-[boostAccERC20PerShare = boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](contracts/flattened/LpFarm.sol#L1080-L1083)

contracts/flattened/LpFarm.sol#L1054-L1090


 - [ ] ID-3
[LpFarm._updatePoolWithBoostReward(uint256)](contracts/flattened/LpFarm.sol#L958-L981) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / (totalAllocPoint)](contracts/flattened/LpFarm.sol#L973-L975)
	-[pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + ((erc20Reward * 1e36) / totalBoostWeight)](contracts/flattened/LpFarm.sol#L977-L979)

contracts/flattened/LpFarm.sol#L958-L981


 - [ ] ID-4
[LpFarm.basePending(uint256,address)](contracts/flattened/LpFarm.sol#L1020-L1049) performs a multiplication on the result of a division:
	-[erc20Reward = (nrOfBlocks * (rewardPerBlock) * (pool.allocPoint)) / (totalAllocPoint)](contracts/flattened/LpFarm.sol#L1040-L1042)
	-[accERC20PerShare = accERC20PerShare + ((erc20Reward * 1e36) / lpSupply)](contracts/flattened/LpFarm.sol#L1043-L1045)

contracts/flattened/LpFarm.sol#L1020-L1049


## incorrect-equality
Impact: Medium
Confidence: High
 - [ ] ID-5
[LpFarm._updatePoolWithBaseReward(uint256)](contracts/flattened/LpFarm.sol#L928-L952) uses a dangerous strict equality:
	- [lpSupply == 0](contracts/flattened/LpFarm.sol#L936)

contracts/flattened/LpFarm.sol#L928-L952


## reentrancy-no-eth
Impact: Medium
Confidence: Medium
 - [ ] ID-6
Reentrancy in [LpFarm.fund(uint256)](contracts/flattened/LpFarm.sol#L784-L792):
	External calls:
	- [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](contracts/flattened/LpFarm.sol#L788)
	State variables written after the call(s):
	- [endBlock += _amount / rewardPerBlock](contracts/flattened/LpFarm.sol#L789)

contracts/flattened/LpFarm.sol#L784-L792


 - [ ] ID-7
Reentrancy in [LpFarm.deposit(uint256,uint256)](contracts/flattened/LpFarm.sol#L644-L676):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L651)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [erc20Transfer(msg.sender,boostPendingaAmount)](contracts/flattened/LpFarm.sol#L659)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](contracts/flattened/LpFarm.sol#L662-L666)
	State variables written after the call(s):
	- [user.amount += _amount](contracts/flattened/LpFarm.sol#L667)
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L668)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L670-L672)

contracts/flattened/LpFarm.sol#L644-L676


 - [ ] ID-8
Reentrancy in [LpFarm.claim(uint256)](contracts/flattened/LpFarm.sol#L724-L743):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L734)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	State variables written after the call(s):
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L736)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L738-L740)

contracts/flattened/LpFarm.sol#L724-L743


 - [ ] ID-9
Reentrancy in [LpFarm.withdraw(uint256,uint256)](contracts/flattened/LpFarm.sol#L683-L718):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L704)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	State variables written after the call(s):
	- [updateBoostWeightToPool(_pid)](contracts/flattened/LpFarm.sol#L713)
		- [pool.totalBoostWeight = pool.totalBoostWeight - oldBoostWeight + newBoostWeight](contracts/flattened/LpFarm.sol#L908-L911)
		- [pool.boostLastRewardBlock = lastBlock](contracts/flattened/LpFarm.sol#L967)
		- [pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + ((erc20Reward * 1e36) / totalBoostWeight)](contracts/flattened/LpFarm.sol#L977-L979)
		- [pool.boostLastRewardBlock = block.number](contracts/flattened/LpFarm.sol#L980)
	- [user.amount -= _amount](contracts/flattened/LpFarm.sol#L706)
	- [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L707)
	- [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](contracts/flattened/LpFarm.sol#L709-L711)
	- [updateBoostWeightToPool(_pid)](contracts/flattened/LpFarm.sol#L713)
		- [user.boostWeight = newBoostWeight](contracts/flattened/LpFarm.sol#L907)

contracts/flattened/LpFarm.sol#L683-L718


 - [ ] ID-10
Reentrancy in [LpFarm.deposit(uint256,uint256)](contracts/flattened/LpFarm.sol#L644-L676):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L651)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [erc20Transfer(msg.sender,boostPendingaAmount)](contracts/flattened/LpFarm.sol#L659)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	State variables written after the call(s):
	- [erc20Transfer(msg.sender,boostPendingaAmount)](contracts/flattened/LpFarm.sol#L659)
		- [paidOut += _amount](contracts/flattened/LpFarm.sol#L921)

contracts/flattened/LpFarm.sol#L644-L676


## events-maths
Impact: Low
Confidence: Medium
 - [ ] ID-11
[LpFarm.setRewardPerBlock(uint256)](contracts/flattened/LpFarm.sol#L880-L888) should emit an event for: 
	- [rewardPerBlock = _rewardPerBlock](contracts/flattened/LpFarm.sol#L885) 
	- [endBlock = sigBalance / rewardPerBlock](contracts/flattened/LpFarm.sol#L887) 

contracts/flattened/LpFarm.sol#L880-L888


 - [ ] ID-12
[LpFarm.setPool(uint256,uint256,uint256)](contracts/flattened/LpFarm.sol#L856-L875) should emit an event for: 
	- [totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint](contracts/flattened/LpFarm.sol#L874) 

contracts/flattened/LpFarm.sol#L856-L875


 - [ ] ID-13
[LpFarm.setInitialInfo(IERC20,IvxERC20,uint256,uint256)](contracts/flattened/LpFarm.sol#L798-L813) should emit an event for: 
	- [rewardPerBlock = _rewardPerBlock](contracts/flattened/LpFarm.sol#L809) 
	- [startBlock = _startBlock](contracts/flattened/LpFarm.sol#L810) 
	- [endBlock = _startBlock](contracts/flattened/LpFarm.sol#L811) 

contracts/flattened/LpFarm.sol#L798-L813


## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-14
[LpFarm._updatePoolWithBaseReward(uint256)](contracts/flattened/LpFarm.sol#L928-L952) has external calls inside a loop: [lpSupply = pool.lpToken.balanceOf(address(this))](contracts/flattened/LpFarm.sol#L935)

contracts/flattened/LpFarm.sol#L928-L952


 - [ ] ID-15
[LpFarm._updateBoostWeight(address,uint256)](contracts/flattened/LpFarm.sol#L897-L912) has external calls inside a loop: [vxAmount = vxSIG.balanceOf(_addr)](contracts/flattened/LpFarm.sol#L903)

contracts/flattened/LpFarm.sol#L897-L912


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-16
Reentrancy in [LpFarm.erc20Transfer(address,uint256)](contracts/flattened/LpFarm.sol#L919-L922):
	External calls:
	- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	State variables written after the call(s):
	- [paidOut += _amount](contracts/flattened/LpFarm.sol#L921)

contracts/flattened/LpFarm.sol#L919-L922


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-17
Reentrancy in [LpFarm.deposit(uint256,uint256)](contracts/flattened/LpFarm.sol#L644-L676):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L651)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [erc20Transfer(msg.sender,boostPendingaAmount)](contracts/flattened/LpFarm.sol#L659)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](contracts/flattened/LpFarm.sol#L662-L666)
	Event emitted after the call(s):
	- [Deposit(msg.sender,_pid,_amount)](contracts/flattened/LpFarm.sol#L675)

contracts/flattened/LpFarm.sol#L644-L676


 - [ ] ID-18
Reentrancy in [LpFarm.withdraw(uint256,uint256)](contracts/flattened/LpFarm.sol#L683-L718):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L704)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	- [pool.lpToken.safeTransfer(address(msg.sender),_amount)](contracts/flattened/LpFarm.sol#L716)
	Event emitted after the call(s):
	- [Withdraw(msg.sender,_pid,_amount)](contracts/flattened/LpFarm.sol#L717)

contracts/flattened/LpFarm.sol#L683-L718


 - [ ] ID-19
Reentrancy in [LpFarm.claim(uint256)](contracts/flattened/LpFarm.sol#L724-L743):
	External calls:
	- [erc20Transfer(msg.sender,pendingAmount)](contracts/flattened/LpFarm.sol#L734)
		- [sig.transfer(_to,_amount)](contracts/flattened/LpFarm.sol#L920)
	Event emitted after the call(s):
	- [Claim(msg.sender,_pid,pendingAmount)](contracts/flattened/LpFarm.sol#L742)

contracts/flattened/LpFarm.sol#L724-L743


 - [ ] ID-20
Reentrancy in [LpFarm.fund(uint256)](contracts/flattened/LpFarm.sol#L784-L792):
	External calls:
	- [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](contracts/flattened/LpFarm.sol#L788)
	Event emitted after the call(s):
	- [Funded(msg.sender,_amount,endBlock)](contracts/flattened/LpFarm.sol#L791)

contracts/flattened/LpFarm.sol#L784-L792


## assembly
Impact: Informational
Confidence: High
 - [ ] ID-21
[Address.verifyCallResult(bool,bytes,string)](contracts/flattened/LpFarm.sol#L321-L341) uses assembly
	- [INLINE ASM](contracts/flattened/LpFarm.sol#L333-L336)

contracts/flattened/LpFarm.sol#L321-L341


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-22
[Address.sendValue(address,uint256)](contracts/flattened/LpFarm.sol#L143-L154) is never used and should be removed

contracts/flattened/LpFarm.sol#L143-L154


 - [ ] ID-23
[Address.functionCallWithValue(address,bytes,uint256)](contracts/flattened/LpFarm.sol#L206-L218) is never used and should be removed

contracts/flattened/LpFarm.sol#L206-L218


 - [ ] ID-24
[Address.functionDelegateCall(address,bytes,string)](contracts/flattened/LpFarm.sol#L304-L313) is never used and should be removed

contracts/flattened/LpFarm.sol#L304-L313


 - [ ] ID-25
[Address.functionDelegateCall(address,bytes)](contracts/flattened/LpFarm.sol#L286-L296) is never used and should be removed

contracts/flattened/LpFarm.sol#L286-L296


 - [ ] ID-26
[SafeERC20.safeIncreaseAllowance(IERC20,address,uint256)](contracts/flattened/LpFarm.sol#L404-L418) is never used and should be removed

contracts/flattened/LpFarm.sol#L404-L418


 - [ ] ID-27
[SafeERC20.safeApprove(IERC20,address,uint256)](contracts/flattened/LpFarm.sol#L386-L402) is never used and should be removed

contracts/flattened/LpFarm.sol#L386-L402


 - [ ] ID-28
[Context._msgData()](contracts/flattened/LpFarm.sol#L483-L485) is never used and should be removed

contracts/flattened/LpFarm.sol#L483-L485


 - [ ] ID-29
[Address.functionStaticCall(address,bytes)](contracts/flattened/LpFarm.sol#L250-L261) is never used and should be removed

contracts/flattened/LpFarm.sol#L250-L261


 - [ ] ID-30
[SafeERC20.safeDecreaseAllowance(IERC20,address,uint256)](contracts/flattened/LpFarm.sol#L420-L441) is never used and should be removed

contracts/flattened/LpFarm.sol#L420-L441


 - [ ] ID-31
[Address.functionStaticCall(address,bytes,string)](contracts/flattened/LpFarm.sol#L269-L278) is never used and should be removed

contracts/flattened/LpFarm.sol#L269-L278


 - [ ] ID-32
[Address.functionCall(address,bytes)](contracts/flattened/LpFarm.sol#L174-L179) is never used and should be removed

contracts/flattened/LpFarm.sol#L174-L179


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-33
Pragma version[^0.8.9](contracts/flattened/LpFarm.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/flattened/LpFarm.sol#L2


 - [ ] ID-34
solc-0.8.9 is not recommended for deployment

## low-level-calls
Impact: Informational
Confidence: High
 - [ ] ID-35
Low level call in [Address.functionCallWithValue(address,bytes,uint256,string)](contracts/flattened/LpFarm.sol#L226-L242):
	- [(success,returndata) = target.call{value: value}(data)](contracts/flattened/LpFarm.sol#L238-L240)

contracts/flattened/LpFarm.sol#L226-L242


 - [ ] ID-36
Low level call in [Address.sendValue(address,uint256)](contracts/flattened/LpFarm.sol#L143-L154):
	- [(success) = recipient.call{value: amount}()](contracts/flattened/LpFarm.sol#L149)

contracts/flattened/LpFarm.sol#L143-L154


 - [ ] ID-37
Low level call in [Address.functionDelegateCall(address,bytes,string)](contracts/flattened/LpFarm.sol#L304-L313):
	- [(success,returndata) = target.delegatecall(data)](contracts/flattened/LpFarm.sol#L311)

contracts/flattened/LpFarm.sol#L304-L313


 - [ ] ID-38
Low level call in [Address.functionStaticCall(address,bytes,string)](contracts/flattened/LpFarm.sol#L269-L278):
	- [(success,returndata) = target.staticcall(data)](contracts/flattened/LpFarm.sol#L276)

contracts/flattened/LpFarm.sol#L269-L278


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-39
Parameter [LpFarm.fund(uint256)._amount](contracts/flattened/LpFarm.sol#L784) is not in mixedCase

contracts/flattened/LpFarm.sol#L784


 - [ ] ID-40
Parameter [LpFarm.deposit(uint256,uint256)._amount](contracts/flattened/LpFarm.sol#L644) is not in mixedCase

contracts/flattened/LpFarm.sol#L644


 - [ ] ID-41
Parameter [LpFarm.updatePool(uint256)._pid](contracts/flattened/LpFarm.sol#L767) is not in mixedCase

contracts/flattened/LpFarm.sol#L767


 - [ ] ID-42
Parameter [LpFarm.boostPending(uint256,address)._user](contracts/flattened/LpFarm.sol#L1054) is not in mixedCase

contracts/flattened/LpFarm.sol#L1054


 - [ ] ID-43
Parameter [LpFarm.addPool(uint256,uint256,IERC20)._lpToken](contracts/flattened/LpFarm.sol#L824) is not in mixedCase

contracts/flattened/LpFarm.sol#L824


 - [ ] ID-44
Parameter [LpFarm.basePending(uint256,address)._user](contracts/flattened/LpFarm.sol#L1020) is not in mixedCase

contracts/flattened/LpFarm.sol#L1020


 - [ ] ID-45
Parameter [LpFarm.setPool(uint256,uint256,uint256)._pid](contracts/flattened/LpFarm.sol#L857) is not in mixedCase

contracts/flattened/LpFarm.sol#L857


 - [ ] ID-46
Parameter [LpFarm.withdraw(uint256,uint256)._amount](contracts/flattened/LpFarm.sol#L683) is not in mixedCase

contracts/flattened/LpFarm.sol#L683


 - [ ] ID-47
Parameter [LpFarm.setInitialInfo(IERC20,IvxERC20,uint256,uint256)._vxSIG](contracts/flattened/LpFarm.sol#L800) is not in mixedCase

contracts/flattened/LpFarm.sol#L800


 - [ ] ID-48
Parameter [LpFarm.setPool(uint256,uint256,uint256)._allocPoint](contracts/flattened/LpFarm.sol#L858) is not in mixedCase

contracts/flattened/LpFarm.sol#L858


 - [ ] ID-49
Parameter [LpFarm.erc20Transfer(address,uint256)._to](contracts/flattened/LpFarm.sol#L919) is not in mixedCase

contracts/flattened/LpFarm.sol#L919


 - [ ] ID-50
Parameter [LpFarm.setInitialInfo(IERC20,IvxERC20,uint256,uint256)._startBlock](contracts/flattened/LpFarm.sol#L802) is not in mixedCase

contracts/flattened/LpFarm.sol#L802


 - [ ] ID-51
Parameter [LpFarm.addPool(uint256,uint256,IERC20)._boostAllocPoint](contracts/flattened/LpFarm.sol#L823) is not in mixedCase

contracts/flattened/LpFarm.sol#L823


 - [ ] ID-52
Parameter [LpFarm.deposited(uint256,address)._pid](contracts/flattened/LpFarm.sol#L1095) is not in mixedCase

contracts/flattened/LpFarm.sol#L1095


 - [ ] ID-53
Parameter [LpFarm.setInitialInfo(IERC20,IvxERC20,uint256,uint256)._rewardPerBlock](contracts/flattened/LpFarm.sol#L801) is not in mixedCase

contracts/flattened/LpFarm.sol#L801


 - [ ] ID-54
Parameter [LpFarm.claim(uint256)._pid](contracts/flattened/LpFarm.sol#L724) is not in mixedCase

contracts/flattened/LpFarm.sol#L724


 - [ ] ID-55
Parameter [LpFarm.withdraw(uint256,uint256)._pid](contracts/flattened/LpFarm.sol#L683) is not in mixedCase

contracts/flattened/LpFarm.sol#L683


 - [ ] ID-56
Parameter [LpFarm.updateBoostWeightToPool(uint256)._pid](contracts/flattened/LpFarm.sol#L759) is not in mixedCase

contracts/flattened/LpFarm.sol#L759


 - [ ] ID-57
Parameter [LpFarm.setRewardPerBlock(uint256)._rewardPerBlock](contracts/flattened/LpFarm.sol#L880) is not in mixedCase

contracts/flattened/LpFarm.sol#L880


 - [ ] ID-58
Parameter [LpFarm.deposited(uint256,address)._user](contracts/flattened/LpFarm.sol#L1095) is not in mixedCase

contracts/flattened/LpFarm.sol#L1095


 - [ ] ID-59
Parameter [LpFarm.erc20Transfer(address,uint256)._amount](contracts/flattened/LpFarm.sol#L919) is not in mixedCase

contracts/flattened/LpFarm.sol#L919


 - [ ] ID-60
Parameter [LpFarm.setInitialInfo(IERC20,IvxERC20,uint256,uint256)._sig](contracts/flattened/LpFarm.sol#L799) is not in mixedCase

contracts/flattened/LpFarm.sol#L799


 - [ ] ID-61
Parameter [LpFarm.setPool(uint256,uint256,uint256)._boostAllocPoint](contracts/flattened/LpFarm.sol#L859) is not in mixedCase

contracts/flattened/LpFarm.sol#L859


 - [ ] ID-62
Parameter [LpFarm.deposit(uint256,uint256)._pid](contracts/flattened/LpFarm.sol#L644) is not in mixedCase

contracts/flattened/LpFarm.sol#L644


 - [ ] ID-63
Parameter [LpFarm.basePending(uint256,address)._pid](contracts/flattened/LpFarm.sol#L1020) is not in mixedCase

contracts/flattened/LpFarm.sol#L1020


 - [ ] ID-64
Parameter [LpFarm.boostPending(uint256,address)._pid](contracts/flattened/LpFarm.sol#L1054) is not in mixedCase

contracts/flattened/LpFarm.sol#L1054


 - [ ] ID-65
Parameter [LpFarm.addPool(uint256,uint256,IERC20)._allocPoint](contracts/flattened/LpFarm.sol#L822) is not in mixedCase

contracts/flattened/LpFarm.sol#L822


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-66
deposit(uint256,uint256) should be declared external:
	- [LpFarm.deposit(uint256,uint256)](contracts/flattened/LpFarm.sol#L644-L676)

contracts/flattened/LpFarm.sol#L644-L676


 - [ ] ID-67
addPool(uint256,uint256,IERC20) should be declared external:
	- [LpFarm.addPool(uint256,uint256,IERC20)](contracts/flattened/LpFarm.sol#L821-L848)

contracts/flattened/LpFarm.sol#L821-L848


 - [ ] ID-68
renounceOwnership() should be declared external:
	- [Ownable.renounceOwnership()](contracts/flattened/LpFarm.sol#L537-L539)

contracts/flattened/LpFarm.sol#L537-L539


 - [ ] ID-69
transferOwnership(address) should be declared external:
	- [Ownable.transferOwnership(address)](contracts/flattened/LpFarm.sol#L545-L551)

contracts/flattened/LpFarm.sol#L545-L551


 - [ ] ID-70
fund(uint256) should be declared external:
	- [LpFarm.fund(uint256)](contracts/flattened/LpFarm.sol#L784-L792)

contracts/flattened/LpFarm.sol#L784-L792


 - [ ] ID-71
withdraw(uint256,uint256) should be declared external:
	- [LpFarm.withdraw(uint256,uint256)](contracts/flattened/LpFarm.sol#L683-L718)

contracts/flattened/LpFarm.sol#L683-L718


 - [ ] ID-72
setPool(uint256,uint256,uint256) should be declared external:
	- [LpFarm.setPool(uint256,uint256,uint256)](contracts/flattened/LpFarm.sol#L856-L875)

contracts/flattened/LpFarm.sol#L856-L875


