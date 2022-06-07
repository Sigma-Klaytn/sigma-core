Summary

-   [controlled-delegatecall](#controlled-delegatecall) (1 results) (High)
-   [reentrancy-eth](#reentrancy-eth) (1 results) (High)
-   [unprotected-upgrade](#unprotected-upgrade) (1 results) (High)
-   [uninitialized-local](#uninitialized-local) (1 results) (Medium)
-   [unused-return](#unused-return) (1 results) (Medium)
-   [events-access](#events-access) (2 results) (Low)
-   [events-maths](#events-maths) (1 results) (Low)
-   [missing-zero-check](#missing-zero-check) (2 results) (Low)
-   [calls-loop](#calls-loop) (2 results) (Low)
-   [variable-scope](#variable-scope) (1 results) (Low)
-   [reentrancy-events](#reentrancy-events) (4 results) (Low)
-   [timestamp](#timestamp) (4 results) (Low)
-   [assembly](#assembly) (5 results) (Informational)
-   [dead-code](#dead-code) (24 results) (Informational)
-   [solc-version](#solc-version) (2 results) (Informational)
-   [low-level-calls](#low-level-calls) (4 results) (Informational)
-   [naming-convention](#naming-convention) (30 results) (Informational)
-   [similar-names](#similar-names) (5 results) (Informational)
-   [unused-state](#unused-state) (1 results) (Informational)
-   [external-function](#external-function) (3 results) (Optimization)

## controlled-delegatecall

Impact: High
Confidence: Medium

-   [ ] ID-0
        [ERC1967UpgradeUpgradeable.\_functionDelegateCall(address,bytes)](flattened/SigKSPStakingV1.sol#L1038-L1055) uses delegatecall to a input-controlled function id - [(success,returndata) = target.delegatecall(data)](flattened/SigKSPStakingV1.sol#L1048)

flattened/SigKSPStakingV1.sol#L1038-L1055

## reentrancy-eth

Impact: High
Confidence: Medium

-   [ ] ID-1
        Reentrancy in [SigKSPStakingV1.withdraw(uint256)](flattened/SigKSPStakingV1.sol#L1520-L1532):
        External calls: - [\_claimReward()](flattened/SigKSPStakingV1.sol#L1527) - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/SigKSPStakingV1.sol#L425-L428) - [(success,returndata) = target.call{value: value}(data)](flattened/SigKSPStakingV1.sol#L242-L244) - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](flattened/SigKSPStakingV1.sol#L1589)
        External calls sending eth: - [\_claimReward()](flattened/SigKSPStakingV1.sol#L1527) - [(success,returndata) = target.call{value: value}(data)](flattened/SigKSPStakingV1.sol#L242-L244)
        State variables written after the call(s): - [balanceOf[msg.sender] -= amount](flattened/SigKSPStakingV1.sol#L1529) - [totalSupply -= amount](flattened/SigKSPStakingV1.sol#L1528)

flattened/SigKSPStakingV1.sol#L1520-L1532

## unprotected-upgrade

Impact: High
Confidence: High

-   [ ] ID-2
        [SigKSPStakingV1](flattened/SigKSPStakingV1.sol#L1359-L1688) is an upgradeable contract that does not protect its initiliaze functions: [SigKSPStakingV1.initialize()](flattened/SigKSPStakingV1.sol#L1416-L1420). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](flattened/SigKSPStakingV1.sol#L1146-L1149)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](flattened/SigKSPStakingV1.sol#L1159-L1167)
        flattened/SigKSPStakingV1.sol#L1359-L1688

## uninitialized-local

Impact: Medium
Confidence: Medium

-   [ ] ID-3
        [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigKSPStakingV1.sol#L922) is a local variable never initialized

flattened/SigKSPStakingV1.sol#L922

## unused-return

Impact: Medium
Confidence: Medium

-   [ ] ID-4
        [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigKSPStakingV1.sol#L909-L932) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](flattened/SigKSPStakingV1.sol#L920-L929)

flattened/SigKSPStakingV1.sol#L909-L932

## events-access

Impact: Low
Confidence: Medium

-   [ ] ID-5
        [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)](flattened/SigKSPStakingV1.sol#L1449-L1459) should emit an event for: - [rewardsDistribution = \_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1458)

flattened/SigKSPStakingV1.sol#L1449-L1459

-   [ ] ID-6
        [SigKSPStakingV1.setRewardsDistribution(address)](flattened/SigKSPStakingV1.sol#L1498-L1503) should emit an event for: - [rewardsDistribution = \_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1502)

flattened/SigKSPStakingV1.sol#L1498-L1503

## events-maths

Impact: Low
Confidence: Medium

-   [ ] ID-7
        [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address)](flattened/SigKSPStakingV1.sol#L1449-L1459) should emit an event for: - [REWARDS_DURATION = \_rewardDuration](flattened/SigKSPStakingV1.sol#L1457)

flattened/SigKSPStakingV1.sol#L1449-L1459

## missing-zero-check

Impact: Low
Confidence: Medium

-   [ ] ID-8
        [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1453) lacks a zero-check on : - [rewardsDistribution = \_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1458)

flattened/SigKSPStakingV1.sol#L1453

-   [ ] ID-9
        [SigKSPStakingV1.setRewardsDistribution(address).\_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1498) lacks a zero-check on : - [rewardsDistribution = \_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1502)

flattened/SigKSPStakingV1.sol#L1498

## calls-loop

Impact: Low
Confidence: Medium

-   [ ] ID-10
        [SigKSPStakingV1.claimReward()](flattened/SigKSPStakingV1.sol#L1534-L1565) has external calls inside a loop: [unseen = IERC20Upgradeable(token).balanceOf(address(this)) - r.balance](flattened/SigKSPStakingV1.sol#L1548-L1550)

flattened/SigKSPStakingV1.sol#L1534-L1565

-   [ ] ID-11
        [SigKSPStakingV1.updateRewardAmount()](flattened/SigKSPStakingV1.sol#L1465-L1484) has external calls inside a loop: [unseen = IERC20Upgradeable(token).balanceOf(address(this)) - r.balance](flattened/SigKSPStakingV1.sol#L1475-L1477)

flattened/SigKSPStakingV1.sol#L1465-L1484

## variable-scope

Impact: Low
Confidence: High

-   [ ] ID-12
        Variable '[ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool).slot](flattened/SigKSPStakingV1.sol#L922)' in [ERC1967UpgradeUpgradeable.\_upgradeToAndCallUUPS(address,bytes,bool)](flattened/SigKSPStakingV1.sol#L909-L932) potentially used before declaration: [require(bool,string)(slot == \_IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](flattened/SigKSPStakingV1.sol#L923-L926)

flattened/SigKSPStakingV1.sol#L922

## reentrancy-events

Impact: Low
Confidence: Medium

-   [ ] ID-13
        Reentrancy in [SigKSPStakingV1.\_claimReward()](flattened/SigKSPStakingV1.sol#L1568-L1594):
        External calls: - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](flattened/SigKSPStakingV1.sol#L1589)
        Event emitted after the call(s): - [RewardPaid(msg.sender,token,reward)](flattened/SigKSPStakingV1.sol#L1590)

flattened/SigKSPStakingV1.sol#L1568-L1594

-   [ ] ID-14
        Reentrancy in [SigKSPStakingV1.withdraw(uint256)](flattened/SigKSPStakingV1.sol#L1520-L1532):
        External calls: - [\_claimReward()](flattened/SigKSPStakingV1.sol#L1527) - [returndata = address(token).functionCall(data,SafeERC20: low-level call failed)](flattened/SigKSPStakingV1.sol#L425-L428) - [(success,returndata) = target.call{value: value}(data)](flattened/SigKSPStakingV1.sol#L242-L244) - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](flattened/SigKSPStakingV1.sol#L1589) - [stakingToken.safeTransfer(msg.sender,amount)](flattened/SigKSPStakingV1.sol#L1530)
        External calls sending eth: - [\_claimReward()](flattened/SigKSPStakingV1.sol#L1527) - [(success,returndata) = target.call{value: value}(data)](flattened/SigKSPStakingV1.sol#L242-L244)
        Event emitted after the call(s): - [Withdrawn(msg.sender,amount)](flattened/SigKSPStakingV1.sol#L1531)

flattened/SigKSPStakingV1.sol#L1520-L1532

-   [ ] ID-15
        Reentrancy in [SigKSPStakingV1.stake(uint256)](flattened/SigKSPStakingV1.sol#L1507-L1518):
        External calls: - [stakingToken.safeTransferFrom(msg.sender,address(this),amount)](flattened/SigKSPStakingV1.sol#L1516)
        Event emitted after the call(s): - [Staked(msg.sender,amount)](flattened/SigKSPStakingV1.sol#L1517)

flattened/SigKSPStakingV1.sol#L1507-L1518

-   [ ] ID-16
        Reentrancy in [SigKSPStakingV1.claimReward()](flattened/SigKSPStakingV1.sol#L1534-L1565):
        External calls: - [IERC20Upgradeable(token).safeTransfer(msg.sender,reward)](flattened/SigKSPStakingV1.sol#L1560)
        Event emitted after the call(s): - [RewardPaid(msg.sender,token,reward)](flattened/SigKSPStakingV1.sol#L1561)

flattened/SigKSPStakingV1.sol#L1534-L1565

## timestamp

Impact: Low
Confidence: Medium

-   [ ] ID-17
        [SigKSPStakingV1.\_claimReward()](flattened/SigKSPStakingV1.sol#L1568-L1594) uses timestamp for comparisons
        Dangerous comparisons: - [block.timestamp + REWARDS_DURATION > r.periodFinish + 3600](flattened/SigKSPStakingV1.sol#L1575)

flattened/SigKSPStakingV1.sol#L1568-L1594

-   [ ] ID-18
        [SigKSPStakingV1.claimReward()](flattened/SigKSPStakingV1.sol#L1534-L1565) uses timestamp for comparisons
        Dangerous comparisons: - [block.timestamp + REWARDS_DURATION > r.periodFinish + 3600](flattened/SigKSPStakingV1.sol#L1546)

flattened/SigKSPStakingV1.sol#L1534-L1565

-   [ ] ID-19
        [SigKSPStakingV1.lastTimeRewardApplicable(address)](flattened/SigKSPStakingV1.sol#L1611-L1618) uses timestamp for comparisons
        Dangerous comparisons: - [block.timestamp < periodFinish](flattened/SigKSPStakingV1.sol#L1617)

flattened/SigKSPStakingV1.sol#L1611-L1618

-   [ ] ID-20
        [SigKSPStakingV1.\_notifyRewardAmount(SigKSPStakingV1.Reward,uint256)](flattened/SigKSPStakingV1.sol#L1596-L1607) uses timestamp for comparisons
        Dangerous comparisons: - [block.timestamp >= r.periodFinish](flattened/SigKSPStakingV1.sol#L1597)

flattened/SigKSPStakingV1.sol#L1596-L1607

## assembly

Impact: Informational
Confidence: High

-   [ ] ID-21
        [StorageSlotUpgradeable.getAddressSlot(bytes32)](flattened/SigKSPStakingV1.sol#L777-L785) uses assembly - [INLINE ASM](flattened/SigKSPStakingV1.sol#L782-L784)

flattened/SigKSPStakingV1.sol#L777-L785

-   [ ] ID-22
        [AddressUpgradeable.verifyCallResult(bool,bytes,string)](flattened/SigKSPStakingV1.sol#L290-L310) uses assembly - [INLINE ASM](flattened/SigKSPStakingV1.sol#L302-L305)

flattened/SigKSPStakingV1.sol#L290-L310

-   [ ] ID-23
        [StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigKSPStakingV1.sol#L816-L824) uses assembly - [INLINE ASM](flattened/SigKSPStakingV1.sol#L821-L823)

flattened/SigKSPStakingV1.sol#L816-L824

-   [ ] ID-24
        [StorageSlotUpgradeable.getBooleanSlot(bytes32)](flattened/SigKSPStakingV1.sol#L790-L798) uses assembly - [INLINE ASM](flattened/SigKSPStakingV1.sol#L795-L797)

flattened/SigKSPStakingV1.sol#L790-L798

-   [ ] ID-25
        [StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigKSPStakingV1.sol#L803-L811) uses assembly - [INLINE ASM](flattened/SigKSPStakingV1.sol#L808-L810)

flattened/SigKSPStakingV1.sol#L803-L811

## dead-code

Impact: Informational
Confidence: Medium

-   [ ] ID-26
        [ContextUpgradeable.\_msgData()](flattened/SigKSPStakingV1.sol#L604-L606) is never used and should be removed

flattened/SigKSPStakingV1.sol#L604-L606

-   [ ] ID-27
        [AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](flattened/SigKSPStakingV1.sol#L210-L222) is never used and should be removed

flattened/SigKSPStakingV1.sol#L210-L222

-   [ ] ID-28
        [SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](flattened/SigKSPStakingV1.sol#L355-L371) is never used and should be removed

flattened/SigKSPStakingV1.sol#L355-L371

-   [ ] ID-29
        [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init_unchained()](flattened/SigKSPStakingV1.sol#L838) is never used and should be removed

flattened/SigKSPStakingV1.sol#L838

-   [ ] ID-30
        [SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/SigKSPStakingV1.sol#L373-L387) is never used and should be removed

flattened/SigKSPStakingV1.sol#L373-L387

-   [ ] ID-31
        [AddressUpgradeable.functionCall(address,bytes)](flattened/SigKSPStakingV1.sol#L178-L183) is never used and should be removed

flattened/SigKSPStakingV1.sol#L178-L183

-   [ ] ID-32
        [ERC1967UpgradeUpgradeable.\_getBeacon()](flattened/SigKSPStakingV1.sol#L990-L992) is never used and should be removed

flattened/SigKSPStakingV1.sol#L990-L992

-   [ ] ID-33
        [ContextUpgradeable.\_\_Context_init_unchained()](flattened/SigKSPStakingV1.sol#L598) is never used and should be removed

flattened/SigKSPStakingV1.sol#L598

-   [ ] ID-34
        [StorageSlotUpgradeable.getUint256Slot(bytes32)](flattened/SigKSPStakingV1.sol#L816-L824) is never used and should be removed

flattened/SigKSPStakingV1.sol#L816-L824

-   [ ] ID-35
        [AddressUpgradeable.sendValue(address,uint256)](flattened/SigKSPStakingV1.sol#L147-L158) is never used and should be removed

flattened/SigKSPStakingV1.sol#L147-L158

-   [ ] ID-36
        [AddressUpgradeable.functionStaticCall(address,bytes)](flattened/SigKSPStakingV1.sol#L254-L265) is never used and should be removed

flattened/SigKSPStakingV1.sol#L254-L265

-   [ ] ID-37
        [ERC1967UpgradeUpgradeable.\_upgradeBeaconToAndCall(address,bytes,bool)](flattened/SigKSPStakingV1.sol#L1017-L1030) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1017-L1030

-   [ ] ID-38
        [SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](flattened/SigKSPStakingV1.sol#L389-L410) is never used and should be removed

flattened/SigKSPStakingV1.sol#L389-L410

-   [ ] ID-39
        [ERC1967UpgradeUpgradeable.\_setBeacon(address)](flattened/SigKSPStakingV1.sol#L997-L1009) is never used and should be removed

flattened/SigKSPStakingV1.sol#L997-L1009

-   [ ] ID-40
        [UUPSUpgradeable.\_\_UUPSUpgradeable_init()](flattened/SigKSPStakingV1.sol#L1082) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1082

-   [ ] ID-41
        [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init()](flattened/SigKSPStakingV1.sol#L836) is never used and should be removed

flattened/SigKSPStakingV1.sol#L836

-   [ ] ID-42
        [ERC1967UpgradeUpgradeable.\_setAdmin(address)](flattened/SigKSPStakingV1.sol#L957-L963) is never used and should be removed

flattened/SigKSPStakingV1.sol#L957-L963

-   [ ] ID-43
        [UUPSUpgradeable.\_\_UUPSUpgradeable_init_unchained()](flattened/SigKSPStakingV1.sol#L1084) is never used and should be removed

flattened/SigKSPStakingV1.sol#L1084

-   [ ] ID-44
        [StorageSlotUpgradeable.getBytes32Slot(bytes32)](flattened/SigKSPStakingV1.sol#L803-L811) is never used and should be removed

flattened/SigKSPStakingV1.sol#L803-L811

-   [ ] ID-45
        [ERC1967UpgradeUpgradeable.\_changeAdmin(address)](flattened/SigKSPStakingV1.sol#L970-L973) is never used and should be removed

flattened/SigKSPStakingV1.sol#L970-L973

-   [ ] ID-46
        [ERC1967UpgradeUpgradeable.\_getAdmin()](flattened/SigKSPStakingV1.sol#L950-L952) is never used and should be removed

flattened/SigKSPStakingV1.sol#L950-L952

-   [ ] ID-47
        [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigKSPStakingV1.sol#L273-L282) is never used and should be removed

flattened/SigKSPStakingV1.sol#L273-L282

-   [ ] ID-48
        [Initializable.\_disableInitializers()](flattened/SigKSPStakingV1.sol#L560-L562) is never used and should be removed

flattened/SigKSPStakingV1.sol#L560-L562

-   [ ] ID-49
        [ContextUpgradeable.\_\_Context_init()](flattened/SigKSPStakingV1.sol#L596) is never used and should be removed

flattened/SigKSPStakingV1.sol#L596

## solc-version

Impact: Informational
Confidence: High

-   [ ] ID-50
        Pragma version[^0.8.0](flattened/SigKSPStakingV1.sol#L6) allows old versions

flattened/SigKSPStakingV1.sol#L6

-   [ ] ID-51
        solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

-   [ ] ID-52
        Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](flattened/SigKSPStakingV1.sol#L273-L282): - [(success,returndata) = target.staticcall(data)](flattened/SigKSPStakingV1.sol#L280)

flattened/SigKSPStakingV1.sol#L273-L282

-   [ ] ID-53
        Low level call in [ERC1967UpgradeUpgradeable.\_functionDelegateCall(address,bytes)](flattened/SigKSPStakingV1.sol#L1038-L1055): - [(success,returndata) = target.delegatecall(data)](flattened/SigKSPStakingV1.sol#L1048)

flattened/SigKSPStakingV1.sol#L1038-L1055

-   [ ] ID-54
        Low level call in [AddressUpgradeable.sendValue(address,uint256)](flattened/SigKSPStakingV1.sol#L147-L158): - [(success) = recipient.call{value: amount}()](flattened/SigKSPStakingV1.sol#L153)

flattened/SigKSPStakingV1.sol#L147-L158

-   [ ] ID-55
        Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](flattened/SigKSPStakingV1.sol#L230-L246): - [(success,returndata) = target.call{value: value}(data)](flattened/SigKSPStakingV1.sol#L242-L244)

flattened/SigKSPStakingV1.sol#L230-L246

## naming-convention

Impact: Informational
Confidence: High

-   [ ] ID-56
        Parameter [SigKSPStakingV1.setRewardsDuration(uint256).\_rewardsDuration](flattened/SigKSPStakingV1.sol#L1489) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1489

-   [ ] ID-57
        Function [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init_unchained()](flattened/SigKSPStakingV1.sol#L838) is not in mixedCase

flattened/SigKSPStakingV1.sol#L838

-   [ ] ID-58
        Variable [ContextUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L613) is not in mixedCase

flattened/SigKSPStakingV1.sol#L613

-   [ ] ID-59
        Function [ReentrancyGuardUpgradeable.\_\_ReentrancyGuard_init_unchained()](flattened/SigKSPStakingV1.sol#L1226-L1228) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1226-L1228

-   [ ] ID-60
        Parameter [SigKSPStakingV1.getRewardForDuration(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1651) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1651

-   [ ] ID-61
        Function [OwnableUpgradeable.\_\_Ownable_init()](flattened/SigKSPStakingV1.sol#L639-L641) is not in mixedCase

flattened/SigKSPStakingV1.sol#L639-L641

-   [ ] ID-62
        Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_stakingToken](flattened/SigKSPStakingV1.sol#L1450) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1450

-   [ ] ID-63
        Variable [OwnableUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L700) is not in mixedCase

flattened/SigKSPStakingV1.sol#L700

-   [ ] ID-64
        Variable [UUPSUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L1186) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1186

-   [ ] ID-65
        Variable [PausableUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L1352) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1352

-   [ ] ID-66
        Parameter [SigKSPStakingV1.earned(address,address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1640) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1640

-   [ ] ID-67
        Variable [ERC1967UpgradeUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L1062) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1062

-   [ ] ID-68
        Function [ReentrancyGuardUpgradeable.\_\_ReentrancyGuard_init()](flattened/SigKSPStakingV1.sol#L1222-L1224) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1222-L1224

-   [ ] ID-69
        Function [ContextUpgradeable.\_\_Context_init_unchained()](flattened/SigKSPStakingV1.sol#L598) is not in mixedCase

flattened/SigKSPStakingV1.sol#L598

-   [ ] ID-70
        Function [UUPSUpgradeable.\_\_UUPSUpgradeable_init_unchained()](flattened/SigKSPStakingV1.sol#L1084) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1084

-   [ ] ID-71
        Variable [ReentrancyGuardUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L1256) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1256

-   [ ] ID-72
        Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardTokens](flattened/SigKSPStakingV1.sol#L1451) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1451

-   [ ] ID-73
        Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardDuration](flattened/SigKSPStakingV1.sol#L1452) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1452

-   [ ] ID-74
        Function [OwnableUpgradeable.\_\_Ownable_init_unchained()](flattened/SigKSPStakingV1.sol#L643-L645) is not in mixedCase

flattened/SigKSPStakingV1.sol#L643-L645

-   [ ] ID-75
        Variable [UUPSUpgradeable.\_\_self](flattened/SigKSPStakingV1.sol#L1087) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1087

-   [ ] ID-76
        Function [ERC1967UpgradeUpgradeable.\_\_ERC1967Upgrade_init()](flattened/SigKSPStakingV1.sol#L836) is not in mixedCase

flattened/SigKSPStakingV1.sol#L836

-   [ ] ID-77
        Parameter [SigKSPStakingV1.lastTimeRewardApplicable(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1611) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1611

-   [ ] ID-78
        Function [UUPSUpgradeable.\_\_UUPSUpgradeable_init()](flattened/SigKSPStakingV1.sol#L1082) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1082

-   [ ] ID-79
        Parameter [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1453) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1453

-   [ ] ID-80
        Variable [SigKSPStakingV1.REWARDS_DURATION](flattened/SigKSPStakingV1.sol#L1392) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1392

-   [ ] ID-81
        Function [PausableUpgradeable.\_\_Pausable_init()](flattened/SigKSPStakingV1.sol#L1284-L1286) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1284-L1286

-   [ ] ID-82
        Function [ContextUpgradeable.\_\_Context_init()](flattened/SigKSPStakingV1.sol#L596) is not in mixedCase

flattened/SigKSPStakingV1.sol#L596

-   [ ] ID-83
        Parameter [SigKSPStakingV1.setRewardsDistribution(address).\_rewardsDistribution](flattened/SigKSPStakingV1.sol#L1498) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1498

-   [ ] ID-84
        Parameter [SigKSPStakingV1.rewardPerToken(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1624) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1624

-   [ ] ID-85
        Function [PausableUpgradeable.\_\_Pausable_init_unchained()](flattened/SigKSPStakingV1.sol#L1288-L1290) is not in mixedCase

flattened/SigKSPStakingV1.sol#L1288-L1290

## similar-names

Impact: Informational
Confidence: Medium

-   [ ] ID-86
        Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardTokens](flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.rewardPerToken(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1624)

flattened/SigKSPStakingV1.sol#L1451

-   [ ] ID-87
        Variable [SigKSPStakingV1.REWARDS_DURATION](flattened/SigKSPStakingV1.sol#L1392) is too similar to [SigKSPStakingV1.setRewardsDuration(uint256).\_rewardsDuration](flattened/SigKSPStakingV1.sol#L1489)

flattened/SigKSPStakingV1.sol#L1392

-   [ ] ID-88
        Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardTokens](flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.getRewardForDuration(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1651)

flattened/SigKSPStakingV1.sol#L1451

-   [ ] ID-89
        Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardTokens](flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.lastTimeRewardApplicable(address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1611)

flattened/SigKSPStakingV1.sol#L1451

-   [ ] ID-90
        Variable [SigKSPStakingV1.setInitialInfo(address,address[2],uint256,address).\_rewardTokens](flattened/SigKSPStakingV1.sol#L1451) is too similar to [SigKSPStakingV1.earned(address,address).\_rewardsToken](flattened/SigKSPStakingV1.sol#L1640)

flattened/SigKSPStakingV1.sol#L1451

## unused-state

Impact: Informational
Confidence: High

-   [ ] ID-91
        [PausableUpgradeable.\_\_gap](flattened/SigKSPStakingV1.sol#L1352) is never used in [SigKSPStakingV1](flattened/SigKSPStakingV1.sol#L1359-L1688)

flattened/SigKSPStakingV1.sol#L1352

## external-function

Impact: Optimization
Confidence: High

-   [ ] ID-92
        transferOwnership(address) should be declared external: - [OwnableUpgradeable.transferOwnership(address)](flattened/SigKSPStakingV1.sol#L677-L683)

flattened/SigKSPStakingV1.sol#L677-L683

-   [ ] ID-93
        claimReward() should be declared external: - [SigKSPStakingV1.claimReward()](flattened/SigKSPStakingV1.sol#L1534-L1565)

flattened/SigKSPStakingV1.sol#L1534-L1565

-   [ ] ID-94
        renounceOwnership() should be declared external: - [OwnableUpgradeable.renounceOwnership()](flattened/SigKSPStakingV1.sol#L669-L671)

flattened/SigKSPStakingV1.sol#L669-L671
