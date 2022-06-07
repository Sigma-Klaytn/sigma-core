# 2. LpFarmV1.sol

This is contract where user deposit their LP Token (sigKSP-KSP LP & SIG - oUSDT LP at this moment) and earn SIG token as a reward. Funding SIG will be done before farming starts.

- This contract is implementing UUPS proxy pattern.

---

# ✨ Resolved Issue (2 issue)

## reentrancy-no-eth

Impact: Medium
Confidence: Medium

- [x]  ID-10
Reentrancy in [LpFarmV1.fund(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1710-L1718):
External calls:
    - [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1714)
    State variables written after the call(s):
    - [endBlock += _amount / rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1715)

flattened/LpFarmV1.sol#L1710-L1718

resolved : change state variable after the call 

- code
    
    before: 
    
    ```solidity
    /**
          @notice Fund the farm, anyone call fund sig token.
          @param _amount amount of the token to fund.
         */
        function fund(uint256 _amount) external whenNotPaused nonReentrant {
            require(block.number < endBlock, "fund: too late, the farm is closed");
            require(_amount > 0, "Funding amount should be bigger than 0");
    
            sig.safeTransferFrom(address(msg.sender), address(this), _amount);
            endBlock += _amount / rewardPerBlock;
    
            emit Funded(msg.sender, _amount, endBlock);
        }
    ```
    
    after: 
    
    ```solidity
    /**
          @notice Fund the farm, anyone call fund sig token.
          @param _amount amount of the token to fund.
         */
        function fund(uint256 _amount) external whenNotPaused nonReentrant {
            require(block.number < endBlock, "fund: too late, the farm is closed");
            require(_amount > 0, "Funding amount should be bigger than 0");
    
            endBlock += _amount / rewardPerBlock;
            sig.safeTransferFrom(address(msg.sender), address(this), _amount);
    
            emit Funded(msg.sender, _amount, endBlock);
        }
    ```
    

## events-maths

Impact: Low
Confidence: Medium

- [x]  ID-13
[LpFarmV1.setPool(uint256,uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1494-L1513) should emit an event for:
    - [totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1512)

flattened/LpFarmV1.sol#L1494-L1513

- [x]  ID-14
[LpFarmV1.setRewardPerBlock(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1519-L1527) should emit an event for:
    - [rewardPerBlock = _rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1524)
    - [endBlock = startBlock + (sigBalance / rewardPerBlock)](notion://www.notion.so/flattened/LpFarmV1.sol#L1526)

flattened/LpFarmV1.sol#L1519-L1527

- [x]  ID-15
[LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1442-L1453) should emit an event for:
    - [rewardPerBlock = _rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1449)
    - [startBlock = _startBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1450)
    - [endBlock = _startBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1451)

flattened/LpFarmV1.sol#L1442-L1453

**resolved : Added 3 events.** 

```solidity
event PoolSet(
        uint256 pid,
        uint256 totalAlloc,
        uint256 baseTotalAlloc,
        uint256 boostTotalAlloc
    );
event RewardPerBlockSet(uint256 rewardPerBlock, uint256 endBlock);
event InitialInfoSet(
        uint256 rewardPerBlock,
        uint256 startBlock,
        uint256 endBlock
    );
```

## reentrancy-benign

Impact: Low
Confidence: Medium

- [x]  ID-19
Reentrancy in [LpFarmV1.transferSIG(address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1768-L1771):
External calls:
    - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
    State variables written after the call(s):
    - [paidOut += _amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1770)

flattened/LpFarmV1.sol#L1768-L1771

resolved : change the order of the line.

```solidity
//before
function transferSIG(address _to, uint256 _amount) internal {
        sig.safeTransfer(_to, _amount);
        paidOut += _amount;
    }

//after
function transferSIG(address _to, uint256 _amount) internal {
        paidOut += _amount;
        sig.safeTransfer(_to, _amount);
    }
```

---

# Summary

- [controlled-delegatecall](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#controlled-delegatecall) (1 results) (High)
- [reentrancy-eth](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#reentrancy-eth) (3 results) (High)
- [unprotected-upgrade](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#unprotected-upgrade) (1 results) (High)
- [divide-before-multiply](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#divide-before-multiply) (4 results) (Medium)
- [incorrect-equality](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#incorrect-equality) (1 results) (Medium)
- [reentrancy-no-eth](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#reentrancy-no-eth) (1 results) (Medium)
- [uninitialized-local](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#uninitialized-local) (1 results) (Medium)
- [unused-return](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#unused-return) (1 results) (Medium)
- [events-maths](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#events-maths) (3 results) (Low)
- [calls-loop](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#calls-loop) (2 results) (Low)
- [variable-scope](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#variable-scope) (1 results) (Low)
- [reentrancy-benign](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#reentrancy-benign) (1 results) (Low)
- [reentrancy-events](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#reentrancy-events) (4 results) (Low)
- [assembly](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#assembly) (5 results) (Informational)
- [dead-code](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#dead-code) (24 results) (Informational)
- [solc-version](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#naming-convention) (47 results) (Informational)
- [unused-state](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/2-UpgradeableLpFarmV1-sol-bc2b1f8a69254a23b54cc25832436f91#external-function) (2 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/LpFarmV1.sol#L1034-L1051) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L1044)

flattened/LpFarmV1.sol#L1034-L1051

## reentrancy-eth

Impact: High
Confidence: Medium

- [ ]  ID-1
Reentrancy in [LpFarmV1.withdraw(uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1607-L1646):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1632)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1632)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        State variables written after the call(s):
    - [_updateBoostWeight(msg.sender,_pid)](notion://www.notion.so/flattened/LpFarmV1.sol#L1641)
        - [pool.boostLastRewardBlock = lastBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1815)
        - [pool.totalBoostWeight = pool.totalBoostWeight - oldBoostWeight + newBoostWeight](notion://www.notion.so/flattened/LpFarmV1.sol#L1757-L1760)
        - [pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](notion://www.notion.so/flattened/LpFarmV1.sol#L1825-L1828)
        - [pool.boostLastRewardBlock = block.number](notion://www.notion.so/flattened/LpFarmV1.sol#L1829)
    
    - [user.amount -= _amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1634)
    - [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1635)
    - [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1637-L1639)
    - [_updateBoostWeight(msg.sender,_pid)](notion://www.notion.so/flattened/LpFarmV1.sol#L1641)
        - [user.boostWeight = newBoostWeight](notion://www.notion.so/flattened/LpFarmV1.sol#L1756)

flattened/LpFarmV1.sol#L1607-L1646

- [ ]  ID-2
Reentrancy in [LpFarmV1.deposit(uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1560-L1600):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1581)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
    - [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1584-L1588)
    External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1581)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        State variables written after the call(s):
    - [user.amount += _amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1590)
    - [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1591)
    - [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1594-L1596)

flattened/LpFarmV1.sol#L1560-L1600

- [ ]  ID-3
Reentrancy in [LpFarmV1.claim(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1652-L1672):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1663)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1663)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        State variables written after the call(s):
    - [user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1665)
    - [user.boostRewardDebt = (user.boostWeight * pool.boostAccERC20PerShare) / 1e36](notion://www.notion.so/flattened/LpFarmV1.sol#L1667-L1669)

flattened/LpFarmV1.sol#L1652-L1672

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-4
[LpFarmV1](notion://www.notion.so/flattened/LpFarmV1.sol#L1367-L1971) is an upgradeable contract that does not protect its initiliaze functions: [LpFarmV1.initialize()](notion://www.notion.so/flattened/LpFarmV1.sol#L1433-L1437). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/LpFarmV1.sol#L1142-L1145)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/LpFarmV1.sol#L1155-L1163)
flattened/LpFarmV1.sol#L1367-L1971

## divide-before-multiply

Impact: Medium
Confidence: Medium

- [ ]  ID-5
[LpFarmV1._updatePoolWithBaseReward(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1777-L1800) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1792-L1793)
-[pool.accERC20PerShare = pool.accERC20PerShare + (erc20Reward * 1e36) / lpSupply](notion://www.notion.so/flattened/LpFarmV1.sol#L1795-L1798)

flattened/LpFarmV1.sol#L1777-L1800

- [ ]  ID-6
[LpFarmV1._updatePoolWithBoostReward(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1806-L1830) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / totalAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1821-L1823)
-[pool.boostAccERC20PerShare = pool.boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](notion://www.notion.so/flattened/LpFarmV1.sol#L1825-L1828)

flattened/LpFarmV1.sol#L1806-L1830

- [ ]  ID-7
[LpFarmV1.getUserBoostPending(uint256,address)](notion://www.notion.so/flattened/LpFarmV1.sol#L1922-L1958) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.boostAllocPoint) / (totalAllocPoint)](notion://www.notion.so/flattened/LpFarmV1.sol#L1944-L1946)
-[boostAccERC20PerShare = boostAccERC20PerShare + (erc20Reward * 1e36) / totalBoostWeight](notion://www.notion.so/flattened/LpFarmV1.sol#L1948-L1951)

flattened/LpFarmV1.sol#L1922-L1958

- [ ]  ID-8
[LpFarmV1.getUserBasePending(uint256,address)](notion://www.notion.so/flattened/LpFarmV1.sol#L1888-L1917) performs a multiplication on the result of a division:
-[erc20Reward = (nrOfBlocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1908-L1910)
-[accERC20PerShare = accERC20PerShare + ((erc20Reward * 1e36) / lpSupply)](notion://www.notion.so/flattened/LpFarmV1.sol#L1911-L1913)

flattened/LpFarmV1.sol#L1888-L1917

## incorrect-equality

Impact: Medium
Confidence: High

- [ ]  ID-9
[LpFarmV1._updatePoolWithBaseReward(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1777-L1800) uses a dangerous strict equality:
    - [lpSupply == 0](notion://www.notion.so/flattened/LpFarmV1.sol#L1785)

flattened/LpFarmV1.sol#L1777-L1800

## reentrancy-no-eth

Impact: Medium
Confidence: Medium

- [ ]  ID-10
Reentrancy in [LpFarmV1.fund(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1710-L1718):
External calls:
    - [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1714)
    State variables written after the call(s):
    - [endBlock += _amount / rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1715)

flattened/LpFarmV1.sol#L1710-L1718

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-11
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/LpFarmV1.sol#L918) is a local variable never initialized

flattened/LpFarmV1.sol#L918

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-12
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/LpFarmV1.sol#L905-L928) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/LpFarmV1.sol#L916-L925)

flattened/LpFarmV1.sol#L905-L928

## events-maths

Impact: Low
Confidence: Medium

- [ ]  ID-13
[LpFarmV1.setPool(uint256,uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1494-L1513) should emit an event for:
    - [totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1512)

flattened/LpFarmV1.sol#L1494-L1513

- [ ]  ID-14
[LpFarmV1.setRewardPerBlock(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1519-L1527) should emit an event for:
    - [rewardPerBlock = _rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1524)
    - [endBlock = startBlock + (sigBalance / rewardPerBlock)](notion://www.notion.so/flattened/LpFarmV1.sol#L1526)

flattened/LpFarmV1.sol#L1519-L1527

- [ ]  ID-15
[LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1442-L1453) should emit an event for:
    - [rewardPerBlock = _rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1449)
    - [startBlock = _startBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1450)
    - [endBlock = _startBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1451)

flattened/LpFarmV1.sol#L1442-L1453

## calls-loop

Impact: Low
Confidence: Medium

- [ ]  ID-16
[LpFarmV1._updateBoostWeight(address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1746-L1761) has external calls inside a loop: [vxAmount = vxSIG.balanceOf(_addr)](notion://www.notion.so/flattened/LpFarmV1.sol#L1752)

flattened/LpFarmV1.sol#L1746-L1761

- [ ]  ID-17
[LpFarmV1._updatePoolWithBaseReward(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1777-L1800) has external calls inside a loop: [lpSupply = pool.lpToken.balanceOf(address(this))](notion://www.notion.so/flattened/LpFarmV1.sol#L1784)

flattened/LpFarmV1.sol#L1777-L1800

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-18
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/LpFarmV1.sol#L918)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/LpFarmV1.sol#L905-L928) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/LpFarmV1.sol#L919-L922)

flattened/LpFarmV1.sol#L918

## reentrancy-benign

Impact: Low
Confidence: Medium

- [ ]  ID-19
Reentrancy in [LpFarmV1.transferSIG(address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1768-L1771):
External calls:
    - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
    State variables written after the call(s):
    - [paidOut += _amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1770)

flattened/LpFarmV1.sol#L1768-L1771

## reentrancy-events

Impact: Low
Confidence: Medium

- [ ]  ID-20
Reentrancy in [LpFarmV1.deposit(uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1560-L1600):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1581)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
    - [pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1584-L1588)
    External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1581)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        Event emitted after the call(s):
    - [Deposit(msg.sender,_pid,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1599)

flattened/LpFarmV1.sol#L1560-L1600

- [ ]  ID-21
Reentrancy in [LpFarmV1.claim(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1652-L1672):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1663)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1663)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        Event emitted after the call(s):
    - [Claim(msg.sender,_pid,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1671)

flattened/LpFarmV1.sol#L1652-L1672

- [ ]  ID-22
Reentrancy in [LpFarmV1.fund(uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1710-L1718):
External calls:
    - [sig.safeTransferFrom(address(msg.sender),address(this),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1714)
    Event emitted after the call(s):
    - [Funded(msg.sender,_amount,endBlock)](notion://www.notion.so/flattened/LpFarmV1.sol#L1717)

flattened/LpFarmV1.sol#L1710-L1718

- [ ]  ID-23
Reentrancy in [LpFarmV1.withdraw(uint256,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L1607-L1646):
External calls:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1632)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/LpFarmV1.sol#L421-L424)
        - [sig.safeTransfer(_to,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1769)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
    - [pool.lpToken.safeTransfer(address(msg.sender),_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1644)
    External calls sending eth:
    - [transferSIG(msg.sender,pendingAmount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1632)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)
        Event emitted after the call(s):
    - [Withdraw(msg.sender,_pid,_amount)](notion://www.notion.so/flattened/LpFarmV1.sol#L1645)

flattened/LpFarmV1.sol#L1607-L1646

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-24
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L786-L794) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/LpFarmV1.sol#L791-L793)

flattened/LpFarmV1.sol#L786-L794

- [ ]  ID-25
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/LpFarmV1.sol#L286-L306) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/LpFarmV1.sol#L298-L301)

flattened/LpFarmV1.sol#L286-L306

- [ ]  ID-26
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L773-L781) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/LpFarmV1.sol#L778-L780)

flattened/LpFarmV1.sol#L773-L781

- [ ]  ID-27
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L812-L820) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/LpFarmV1.sol#L817-L819)

flattened/LpFarmV1.sol#L812-L820

- [ ]  ID-28
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L799-L807) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/LpFarmV1.sol#L804-L806)

flattened/LpFarmV1.sol#L799-L807

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-29
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/LpFarmV1.sol#L600-L602) is never used and should be removed

flattened/LpFarmV1.sol#L600-L602

- [ ]  ID-30
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L206-L218) is never used and should be removed

flattened/LpFarmV1.sol#L206-L218

- [ ]  ID-31
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L351-L367) is never used and should be removed

flattened/LpFarmV1.sol#L351-L367

- [ ]  ID-32
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L834) is never used and should be removed

flattened/LpFarmV1.sol#L834

- [ ]  ID-33
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L369-L383) is never used and should be removed

flattened/LpFarmV1.sol#L369-L383

- [ ]  ID-34
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/LpFarmV1.sol#L174-L179) is never used and should be removed

flattened/LpFarmV1.sol#L174-L179

- [ ]  ID-35
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/LpFarmV1.sol#L986-L988) is never used and should be removed

flattened/LpFarmV1.sol#L986-L988

- [ ]  ID-36
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L594) is never used and should be removed

flattened/LpFarmV1.sol#L594

- [ ]  ID-37
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L812-L820) is never used and should be removed

flattened/LpFarmV1.sol#L812-L820

- [ ]  ID-38
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L143-L154) is never used and should be removed

flattened/LpFarmV1.sol#L143-L154

- [ ]  ID-39
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/LpFarmV1.sol#L250-L261) is never used and should be removed

flattened/LpFarmV1.sol#L250-L261

- [ ]  ID-40
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/LpFarmV1.sol#L1013-L1026) is never used and should be removed

flattened/LpFarmV1.sol#L1013-L1026

- [ ]  ID-41
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L385-L406) is never used and should be removed

flattened/LpFarmV1.sol#L385-L406

- [ ]  ID-42
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/LpFarmV1.sol#L993-L1005) is never used and should be removed

flattened/LpFarmV1.sol#L993-L1005

- [ ]  ID-43
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L1078) is never used and should be removed

flattened/LpFarmV1.sol#L1078

- [ ]  ID-44
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L832) is never used and should be removed

flattened/LpFarmV1.sol#L832

- [ ]  ID-45
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/LpFarmV1.sol#L953-L959) is never used and should be removed

flattened/LpFarmV1.sol#L953-L959

- [ ]  ID-46
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L1080) is never used and should be removed

flattened/LpFarmV1.sol#L1080

- [ ]  ID-47
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/LpFarmV1.sol#L799-L807) is never used and should be removed

flattened/LpFarmV1.sol#L799-L807

- [ ]  ID-48
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/LpFarmV1.sol#L966-L969) is never used and should be removed

flattened/LpFarmV1.sol#L966-L969

- [ ]  ID-49
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/LpFarmV1.sol#L946-L948) is never used and should be removed

flattened/LpFarmV1.sol#L946-L948

- [ ]  ID-50
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/LpFarmV1.sol#L269-L278) is never used and should be removed

flattened/LpFarmV1.sol#L269-L278

- [ ]  ID-51
[Initializable._disableInitializers()](notion://www.notion.so/flattened/LpFarmV1.sol#L556-L558) is never used and should be removed

flattened/LpFarmV1.sol#L556-L558

- [ ]  ID-52
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L592) is never used and should be removed

flattened/LpFarmV1.sol#L592

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-53
Pragma version[^0.8.0](notion://www.notion.so/flattened/LpFarmV1.sol#L2) allows old versions

flattened/LpFarmV1.sol#L2

- [ ]  ID-54
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-55
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/LpFarmV1.sol#L269-L278):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L276)

flattened/LpFarmV1.sol#L269-L278

- [ ]  ID-56
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/LpFarmV1.sol#L1034-L1051):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L1044)

flattened/LpFarmV1.sol#L1034-L1051

- [ ]  ID-57
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/LpFarmV1.sol#L226-L242):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/LpFarmV1.sol#L238-L240)

flattened/LpFarmV1.sol#L226-L242

- [ ]  ID-58
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/LpFarmV1.sol#L143-L154):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/LpFarmV1.sol#L149)

flattened/LpFarmV1.sol#L143-L154

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-59
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._vxSIG](notion://www.notion.so/flattened/LpFarmV1.sol#L1444) is not in mixedCase

flattened/LpFarmV1.sol#L1444

- [ ]  ID-60
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._startBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1446) is not in mixedCase

flattened/LpFarmV1.sol#L1446

- [ ]  ID-61
Parameter [LpFarmV1.deposited(uint256,address)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1963) is not in mixedCase

flattened/LpFarmV1.sol#L1963

- [ ]  ID-62
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._baseAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1496) is not in mixedCase

flattened/LpFarmV1.sol#L1496

- [ ]  ID-63
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L834) is not in mixedCase

flattened/LpFarmV1.sol#L834

- [ ]  ID-64
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1445) is not in mixedCase

flattened/LpFarmV1.sol#L1445

- [ ]  ID-65
Parameter [LpFarmV1.getUserBoostPending(uint256,address)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1922) is not in mixedCase

flattened/LpFarmV1.sol#L1922

- [ ]  ID-66
Parameter [LpFarmV1.getUserTotalPendingReward(uint256,address)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1871) is not in mixedCase

flattened/LpFarmV1.sol#L1871

- [ ]  ID-67
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L609) is not in mixedCase

flattened/LpFarmV1.sol#L609

- [ ]  ID-68
Parameter [LpFarmV1.withdraw(uint256,uint256)._amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1607) is not in mixedCase

flattened/LpFarmV1.sol#L1607

- [ ]  ID-69
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L1222-L1224) is not in mixedCase

flattened/LpFarmV1.sol#L1222-L1224

- [ ]  ID-70
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L635-L637) is not in mixedCase

flattened/LpFarmV1.sol#L635-L637

- [ ]  ID-71
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._boostAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1463) is not in mixedCase

flattened/LpFarmV1.sol#L1463

- [ ]  ID-72
Parameter [LpFarmV1.getUserBoostPending(uint256,address)._user](notion://www.notion.so/flattened/LpFarmV1.sol#L1922) is not in mixedCase

flattened/LpFarmV1.sol#L1922

- [ ]  ID-73
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L696) is not in mixedCase

flattened/LpFarmV1.sol#L696

- [ ]  ID-74
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1495) is not in mixedCase

flattened/LpFarmV1.sol#L1495

- [ ]  ID-75
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L1182) is not in mixedCase

flattened/LpFarmV1.sol#L1182

- [ ]  ID-76
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L1348) is not in mixedCase

flattened/LpFarmV1.sol#L1348

- [ ]  ID-77
Parameter [LpFarmV1.getUserTotalPendingReward(uint256,address)._user](notion://www.notion.so/flattened/LpFarmV1.sol#L1871) is not in mixedCase

flattened/LpFarmV1.sol#L1871

- [ ]  ID-78
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L1058) is not in mixedCase

flattened/LpFarmV1.sol#L1058

- [ ]  ID-79
Parameter [LpFarmV1.setRewardPerBlock(uint256)._rewardPerBlock](notion://www.notion.so/flattened/LpFarmV1.sol#L1519) is not in mixedCase

flattened/LpFarmV1.sol#L1519

- [ ]  ID-80
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L1218-L1220) is not in mixedCase

flattened/LpFarmV1.sol#L1218-L1220

- [ ]  ID-81
Parameter [LpFarmV1.transferSIG(address,uint256)._amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1768) is not in mixedCase

flattened/LpFarmV1.sol#L1768

- [ ]  ID-82
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L594) is not in mixedCase

flattened/LpFarmV1.sol#L594

- [ ]  ID-83
Parameter [LpFarmV1.deposit(uint256,uint256)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1560) is not in mixedCase

flattened/LpFarmV1.sol#L1560

- [ ]  ID-84
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L1080) is not in mixedCase

flattened/LpFarmV1.sol#L1080

- [ ]  ID-85
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._lpToken](notion://www.notion.so/flattened/LpFarmV1.sol#L1464) is not in mixedCase

flattened/LpFarmV1.sol#L1464

- [ ]  ID-86
Variable [ReentrancyGuardUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L1252) is not in mixedCase

flattened/LpFarmV1.sol#L1252

- [ ]  ID-87
Parameter [LpFarmV1.claim(uint256)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1652) is not in mixedCase

flattened/LpFarmV1.sol#L1652

- [ ]  ID-88
Parameter [LpFarmV1.addPool(uint256,uint256,IERC20Upgradeable)._baseAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1462) is not in mixedCase

flattened/LpFarmV1.sol#L1462

- [ ]  ID-89
Parameter [LpFarmV1.transferSIG(address,uint256)._to](notion://www.notion.so/flattened/LpFarmV1.sol#L1768) is not in mixedCase

flattened/LpFarmV1.sol#L1768

- [ ]  ID-90
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L639-L641) is not in mixedCase

flattened/LpFarmV1.sol#L639-L641

- [ ]  ID-91
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/LpFarmV1.sol#L1083) is not in mixedCase

flattened/LpFarmV1.sol#L1083

- [ ]  ID-92
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L832) is not in mixedCase

flattened/LpFarmV1.sol#L832

- [ ]  ID-93
Parameter [LpFarmV1.withdraw(uint256,uint256)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1607) is not in mixedCase

flattened/LpFarmV1.sol#L1607

- [ ]  ID-94
Parameter [LpFarmV1.getUserBasePending(uint256,address)._user](notion://www.notion.so/flattened/LpFarmV1.sol#L1888) is not in mixedCase

flattened/LpFarmV1.sol#L1888

- [ ]  ID-95
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L1078) is not in mixedCase

flattened/LpFarmV1.sol#L1078

- [ ]  ID-96
Parameter [LpFarmV1.setInitialInfo(IERC20Upgradeable,IvxERC20,uint256,uint256)._sig](notion://www.notion.so/flattened/LpFarmV1.sol#L1443) is not in mixedCase

flattened/LpFarmV1.sol#L1443

- [ ]  ID-97
Parameter [LpFarmV1.deposited(uint256,address)._user](notion://www.notion.so/flattened/LpFarmV1.sol#L1963) is not in mixedCase

flattened/LpFarmV1.sol#L1963

- [ ]  ID-98
Parameter [LpFarmV1.setPool(uint256,uint256,uint256)._boostAllocPoint](notion://www.notion.so/flattened/LpFarmV1.sol#L1497) is not in mixedCase

flattened/LpFarmV1.sol#L1497

- [ ]  ID-99
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L1280-L1282) is not in mixedCase

flattened/LpFarmV1.sol#L1280-L1282

- [ ]  ID-100
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/LpFarmV1.sol#L592) is not in mixedCase

flattened/LpFarmV1.sol#L592

- [ ]  ID-101
Parameter [LpFarmV1.updatePool(uint256)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1691) is not in mixedCase

flattened/LpFarmV1.sol#L1691

- [ ]  ID-102
Parameter [LpFarmV1.fund(uint256)._amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1710) is not in mixedCase

flattened/LpFarmV1.sol#L1710

- [ ]  ID-103
Parameter [LpFarmV1.getUserBasePending(uint256,address)._pid](notion://www.notion.so/flattened/LpFarmV1.sol#L1888) is not in mixedCase

flattened/LpFarmV1.sol#L1888

- [ ]  ID-104
Parameter [LpFarmV1.deposit(uint256,uint256)._amount](notion://www.notion.so/flattened/LpFarmV1.sol#L1560) is not in mixedCase

flattened/LpFarmV1.sol#L1560

- [ ]  ID-105
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/LpFarmV1.sol#L1284-L1286) is not in mixedCase

flattened/LpFarmV1.sol#L1284-L1286

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-106
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/LpFarmV1.sol#L1348) is never used in [LpFarmV1](notion://www.notion.so/flattened/LpFarmV1.sol#L1367-L1971)

flattened/LpFarmV1.sol#L1348

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-107
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/LpFarmV1.sol#L673-L679)

flattened/LpFarmV1.sol#L673-L679

- [ ]  ID-108
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/LpFarmV1.sol#L665-L667)

flattened/LpFarmV1.sol#L665-L667