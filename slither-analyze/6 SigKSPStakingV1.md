# 6. SigKSPStakingV1.sol

If user stakes sigKSP to vault, they get SIG, KSP Reward that has been forwarded from fee distributor contract. It’s basic architecture follows snx staking contract. 

- It is UUPS proxy pattern.

# **✨ Resolved Issue ( 1 issue)**

## uninitialized-local

**comment: check if the token is not address(0)**

code : 

```solidity
function _claimReward(), claimReward(), updateRewardAmount() private updateReward(msg.sender) {
        for (uint256 i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            if (token != address(0)) { // this is added 
               // ...
								uint256 unseen = IERC20Upgradeable(token).balanceOf(
                        address(this)
                    ) - r.balance;
            }
        }
    }
```

Impact: Medium
Confidence: Medium

- [x]  ID-3
[SigKSPStakingV1._claimReward().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1562) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L1562

- [x]  ID-4
[SigKSPStakingV1.updateRewardAmount().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1471) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L1471

- [x]  ID-5
[SigKSPStakingV1.claimReward().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1537) is a local variable never initialized

 

---

# Summary

- [controlled-delegatecall](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#controlled-delegatecall) (1 results) (High)
- [reentrancy-eth](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#reentrancy-eth) (1 results) (High)
- [unprotected-upgrade](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#unprotected-upgrade) (1 results) (High)
- [uninitialized-local](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#uninitialized-local) (4 results) (Medium)
- [unused-return](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#unused-return) (1 results) (Medium)
- [events-access](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#events-access) (2 results) (Low)
- [events-maths](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#events-maths) (1 results) (Low)
- [missing-zero-check](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#missing-zero-check) (2 results) (Low)
- [calls-loop](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#calls-loop) (2 results) (Low)
- [variable-scope](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#variable-scope) (1 results) (Low)
- [reentrancy-events](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#reentrancy-events) (4 results) (Low)
- [timestamp](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#timestamp) (4 results) (Low)
- [assembly](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#assembly) (5 results) (Informational)
- [dead-code](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#dead-code) (24 results) (Informational)
- [solc-version](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#naming-convention) (30 results) (Informational)
- [similar-names](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#similar-names) (5 results) (Informational)
- [unused-state](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/6-SigKSPStakingV1-sol-ce0fdf4ca9ec47c788233d6406276f0f#external-function) (3 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-0
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1038-L1055) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1048)

flattened/SigKSPStakingV1.sol#L1038-L1055

## reentrancy-eth

comment : all functions below are protected using ReentrancyGuard.

Impact: High
Confidence: Medium

- [ ]  ID-1
Reentrancy in [SigKSPStakingV1.withdraw(uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1517-L1529):
External calls:
    - [_claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1524)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L425-L428)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L242-L244)
        - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1579)
        External calls sending eth:
    - [_claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1524)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L242-L244)
        State variables written after the call(s):
    - [balanceOf[msg.sender] -= amount](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1526)
    - [totalSupply -= amount](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1525)

flattened/SigKSPStakingV1.sol#L1517-L1529

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-2
[SigKSPStakingV1](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1359-L1677) is an upgradeable contract that does not protect its initiliaze functions: [SigKSPStakingV1.initialize()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1416-L1420). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1146-L1149)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1159-L1167)
flattened/SigKSPStakingV1.sol#L1359-L1677

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-3
[SigKSPStakingV1._claimReward().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1562) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L1562

- [ ]  ID-4
[SigKSPStakingV1.updateRewardAmount().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1471) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L1471

- [ ]  ID-5
[SigKSPStakingV1.claimReward().i](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1537) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L1537

- [ ]  ID-6
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L922) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L922

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-7
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L909-L932) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L920-L929)

flattened/SigKSPStakingV1.sol#L909-L932

## events-access

Impact: Low
Confidence: Medium

- [ ]  ID-8
[SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1449-L1459) should emit an event for:
    - [rewardsDistribution = _rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1458)

flattened/SigKSPStakingV1.sol#L1449-L1459

- [ ]  ID-9
[SigKSPStakingV1.setRewardsDistribution(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1495-L1500) should emit an event for:
    - [rewardsDistribution = _rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1499)

flattened/SigKSPStakingV1.sol#L1495-L1500

## events-maths

Impact: Low
Confidence: Medium

- [ ]  ID-10
[SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1449-L1459) should emit an event for:
    - [REWARDS_DURATION = _rewardDuration](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1457)

flattened/SigKSPStakingV1.sol#L1449-L1459

## missing-zero-check

comment : If the farm is going to be closed, reward distribution address should be 0. 

Impact: Low
Confidence: Medium

- [ ]  ID-11
[SigKSPStakingV1.setRewardsDistribution(address)._rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1495) lacks a zero-check on :
- [rewardsDistribution = _rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1499)

flattened/SigKSPStakingV1.sol#L1495

- [ ]  ID-12
[SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1453) lacks a zero-check on :
- [rewardsDistribution = _rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1458)

flattened/SigKSPStakingV1.sol#L1453

## calls-loop

Impact: Low
Confidence: Medium

- [ ]  ID-13
[SigKSPStakingV1.updateRewardAmount()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1465-L1481) has external calls inside a loop: [unseen = IERC20Upgradeable(token).balanceOf(address(this)) - r.balance](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1474-L1475)

flattened/SigKSPStakingV1.sol#L1465-L1481

- [ ]  ID-14
[SigKSPStakingV1.claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1531-L1558) has external calls inside a loop: [unseen = IERC20Upgradeable(token).balanceOf(address(this)) - r.balance](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1542-L1544)

flattened/SigKSPStakingV1.sol#L1531-L1558

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-15
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L922)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L909-L932) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L923-L926)

flattened/SigKSPStakingV1.sol#L922

## reentrancy-events

Impact: Low
Confidence: Medium

- [ ]  ID-16
Reentrancy in [SigKSPStakingV1.withdraw(uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1517-L1529):
External calls:
    - [_claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1524)
        - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L425-L428)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L242-L244)
        - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1579)
    - [stakingToken.safeTransfer(msg.sender,amount)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1527)
    External calls sending eth:
    - [_claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1524)
        - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L242-L244)
        Event emitted after the call(s):
    - [Withdrawn(msg.sender,amount)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1528)

flattened/SigKSPStakingV1.sol#L1517-L1529

- [ ]  ID-17
Reentrancy in [SigKSPStakingV1.stake(uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1504-L1515):
External calls:
    - [stakingToken.safeTransferFrom(msg.sender,address(this),amount)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1513)
    Event emitted after the call(s):
    - [Staked(msg.sender,amount)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1514)

flattened/SigKSPStakingV1.sol#L1504-L1515

- [ ]  ID-18
Reentrancy in [SigKSPStakingV1.claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1531-L1558):
External calls:
    - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1554)
    Event emitted after the call(s):
    - [RewardPaid(msg.sender,token,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1555)

flattened/SigKSPStakingV1.sol#L1531-L1558

- [ ]  ID-19
Reentrancy in [SigKSPStakingV1._claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1561-L1583):
External calls:
    - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1579)
    Event emitted after the call(s):
    - [RewardPaid(msg.sender,token,reward)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1580)

flattened/SigKSPStakingV1.sol#L1561-L1583

## timestamp

Impact: Low
Confidence: Medium

- [ ]  ID-20
[SigKSPStakingV1.lastTimeRewardApplicable(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1600-L1607) uses timestamp for comparisons
Dangerous comparisons:
    - [block.timestamp < periodFinish](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1606)

flattened/SigKSPStakingV1.sol#L1600-L1607

- [ ]  ID-21
[SigKSPStakingV1._notifyRewardAmount(SigKSPStakingV1.Reward,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1585-L1596) uses timestamp for comparisons
Dangerous comparisons:
    - [block.timestamp >= r.periodFinish](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1586)

flattened/SigKSPStakingV1.sol#L1585-L1596

- [ ]  ID-22
[SigKSPStakingV1._claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1561-L1583) uses timestamp for comparisons
Dangerous comparisons:
    - [block.timestamp + REWARDS_DURATION > r.periodFinish + 3600](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1566)

flattened/SigKSPStakingV1.sol#L1561-L1583

- [ ]  ID-23
[SigKSPStakingV1.claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1531-L1558) uses timestamp for comparisons
Dangerous comparisons:
    - [block.timestamp + REWARDS_DURATION > r.periodFinish + 3600](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1541)

flattened/SigKSPStakingV1.sol#L1531-L1558

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-24
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L777-L785) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L782-L784)

flattened/SigKSPStakingV1.sol#L777-L785

- [ ]  ID-25
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L290-L310) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L302-L305)

flattened/SigKSPStakingV1.sol#L290-L310

- [ ]  ID-26
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L816-L824) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L821-L823)

flattened/SigKSPStakingV1.sol#L816-L824

- [ ]  ID-27
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L790-L798) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L795-L797)

flattened/SigKSPStakingV1.sol#L790-L798

- [ ]  ID-28
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L803-L811) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L808-L810)

flattened/SigKSPStakingV1.sol#L803-L811

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-29
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L604-L606) is never used and should be removed

flattened/SigKSPStakingV1.sol#L604-L606

- [ ]  ID-30
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L210-L222) is never used and should be removed

flattened/SigKSPStakingV1.sol#L210-L222

- [ ]  ID-31
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L355-L371) is never used and should be removed

flattened/SigKSPStakingV1.sol#L355-L371

- [ ]  ID-32
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L838) is never used and should be removed

flattened/SigKSPStakingV1.sol#L838

- [ ]  ID-33
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L373-L387) is never used and should be removed

flattened/SigKSPStakingV1.sol#L373-L387

- [ ]  ID-34
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L178-L183) is never used and should be removed

flattened/SigKSPStakingV1.sol#L178-L183

- [ ]  ID-35
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L990-L992) is never used and should be removed

flattened/SigKSPStakingV1.sol#L990-L992

- [ ]  ID-36
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L598) is never used and should be removed

flattened/SigKSPStakingV1.sol#L598

- [ ]  ID-37
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L816-L824) is never used and should be removed

flattened/SigKSPStakingV1.sol#L816-L824

- [ ]  ID-38
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L147-L158) is never used and should be removed

flattened/SigKSPStakingV1.sol#L147-L158

- [ ]  ID-39
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L254-L265) is never used and should be removed

flattened/SigKSPStakingV1.sol#L254-L265

- [ ]  ID-40
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1017-L1030) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1017-L1030

- [ ]  ID-41
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L389-L410) is never used and should be removed

flattened/SigKSPStakingV1.sol#L389-L410

- [ ]  ID-42
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L997-L1009) is never used and should be removed

flattened/SigKSPStakingV1.sol#L997-L1009

- [ ]  ID-43
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1082) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1082

- [ ]  ID-44
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L836) is never used and should be removed

flattened/SigKSPStakingV1.sol#L836

- [ ]  ID-45
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L957-L963) is never used and should be removed

flattened/SigKSPStakingV1.sol#L957-L963

- [ ]  ID-46
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1084) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1084

- [ ]  ID-47
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L803-L811) is never used and should be removed

flattened/SigKSPStakingV1.sol#L803-L811

- [ ]  ID-48
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L970-L973) is never used and should be removed

flattened/SigKSPStakingV1.sol#L970-L973

- [ ]  ID-49
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L950-L952) is never used and should be removed

flattened/SigKSPStakingV1.sol#L950-L952

- [ ]  ID-50
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L273-L282) is never used and should be removed

flattened/SigKSPStakingV1.sol#L273-L282

- [ ]  ID-51
[Initializable._disableInitializers()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L560-L562) is never used and should be removed

flattened/SigKSPStakingV1.sol#L560-L562

- [ ]  ID-52
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L596) is never used and should be removed

flattened/SigKSPStakingV1.sol#L596

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-53
Pragma version[^0.8.0](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L6) allows old versions

flattened/SigKSPStakingV1.sol#L6

- [ ]  ID-54
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-55
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L273-L282):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L280)

flattened/SigKSPStakingV1.sol#L273-L282

- [ ]  ID-56
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1038-L1055):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1048)

flattened/SigKSPStakingV1.sol#L1038-L1055

- [ ]  ID-57
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L147-L158):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L153)

flattened/SigKSPStakingV1.sol#L147-L158

- [ ]  ID-58
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L230-L246):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L242-L244)

flattened/SigKSPStakingV1.sol#L230-L246

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-59
Parameter [SigKSPStakingV1.setRewardsDuration(uint256)._rewardsDuration](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1486) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1486

- [ ]  ID-60
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L838) is not in mixedCase

flattened/SigKSPStakingV1.sol#L838

- [ ]  ID-61
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L613) is not in mixedCase

flattened/SigKSPStakingV1.sol#L613

- [ ]  ID-62
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1226-L1228) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1226-L1228

- [ ]  ID-63
Parameter [SigKSPStakingV1.getRewardForDuration(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1640) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1640

- [ ]  ID-64
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L639-L641) is not in mixedCase

flattened/SigKSPStakingV1.sol#L639-L641

- [ ]  ID-65
Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._stakingToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1450) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1450

- [ ]  ID-66
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L700) is not in mixedCase

flattened/SigKSPStakingV1.sol#L700

- [ ]  ID-67
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1186) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1186

- [ ]  ID-68
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1352) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1352

- [ ]  ID-69
Parameter [SigKSPStakingV1.earned(address,address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1629) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1629

- [ ]  ID-70
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1062) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1062

- [ ]  ID-71
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1222-L1224) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1222-L1224

- [ ]  ID-72
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L598) is not in mixedCase

flattened/SigKSPStakingV1.sol#L598

- [ ]  ID-73
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1084) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1084

- [ ]  ID-74
Variable [ReentrancyGuardUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1256) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1256

- [ ]  ID-75
Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardTokens](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1451) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1451

- [ ]  ID-76
Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardDuration](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1452) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1452

- [ ]  ID-77
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L643-L645) is not in mixedCase

flattened/SigKSPStakingV1.sol#L643-L645

- [ ]  ID-78
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1087) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1087

- [ ]  ID-79
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L836) is not in mixedCase

flattened/SigKSPStakingV1.sol#L836

- [ ]  ID-80
Parameter [SigKSPStakingV1.lastTimeRewardApplicable(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1600) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1600

- [ ]  ID-81
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1082) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1082

- [ ]  ID-82
Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1453) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1453

- [ ]  ID-83
Variable [SigKSPStakingV1.REWARDS_DURATION](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1392) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1392

- [ ]  ID-84
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1284-L1286) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1284-L1286

- [ ]  ID-85
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L596) is not in mixedCase

flattened/SigKSPStakingV1.sol#L596

- [ ]  ID-86
Parameter [SigKSPStakingV1.setRewardsDistribution(address)._rewardsDistribution](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1495) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1495

- [ ]  ID-87
Parameter [SigKSPStakingV1.rewardPerToken(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1613) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1613

- [ ]  ID-88
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1288-L1290) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1288-L1290

## similar-names

Impact: Informational
Confidence: Medium

- [ ]  ID-89
Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardTokens](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.rewardPerToken(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1613)

flattened/SigKSPStakingV1.sol#L1451

- [ ]  ID-90
Variable [SigKSPStakingV1.REWARDS_DURATION](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1392) is too similar to [SigKSPStakingV1.setRewardsDuration(uint256)._rewardsDuration](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1486)

flattened/SigKSPStakingV1.sol#L1392

- [ ]  ID-91
Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardTokens](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.getRewardForDuration(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1640)

flattened/SigKSPStakingV1.sol#L1451

- [ ]  ID-92
Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardTokens](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.lastTimeRewardApplicable(address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1600)

flattened/SigKSPStakingV1.sol#L1451

- [ ]  ID-93
Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)._rewardTokens](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.earned(address,address)._rewardsToken](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1629)

flattened/SigKSPStakingV1.sol#L1451

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-94
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1352) is never used in [SigKSPStakingV1](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1359-L1677)

flattened/SigKSPStakingV1.sol#L1352

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-95
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L677-L683)

flattened/SigKSPStakingV1.sol#L677-L683

- [ ]  ID-96
claimReward() should be declared external:
    - [SigKSPStakingV1.claimReward()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L1531-L1558)

flattened/SigKSPStakingV1.sol#L1531-L1558

- [ ]  ID-97
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/SigKSPStakingV1.sol#L669-L671)

flattened/SigKSPStakingV1.sol#L669-L671