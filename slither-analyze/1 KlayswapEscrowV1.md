# 1. KlayswapEscrowV1.sol

This is the one of the core contract which functions as a proxy that interacts with Klayswap contracts. This contract forwards votes, claim fees and foward fees to fee distributor. 

- It is UUPS proxy pattern.
- Most of the function is going to be called from sigma-admin-bot except depositKSP() function.

# ✨ Resolved Issue (2 issue)

## 1) reentrancy-benign

Impact: Low
Confidence: Medium

- [x]  ID-13
Reentrancy in [KlayswapEscrow.depositKSP(uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661):
External calls:
    - [kspToken.transferFrom(msg.sender,address(this),_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1656)
    - [votingKSP.lockKSP(_amount,MAX_LOCK_PERIOD)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1657)
    State variables written after the call(s):
    - [_mint(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1658)
        - [balanceOf[_user] += _amount](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1638)
    - [_mint(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1658)
        - [totalSupply += _amount](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1639)

flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661

**resolved : Changed the place that state variable written.**

before :

```solidity
function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Deposit KSP should be bigger than 0.");
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);
        _mint(msg.sender, _amount * 1 ether);

        emit DepositKSP(msg.sender, _amount * 1 ether);
    }
```

after : 

```solidity
function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Deposit KSP should be bigger than 0.");
        _mint(msg.sender, _amount * 1 ether);
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);

        emit DepositKSP(msg.sender, _amount * 1 ether);
    }
```

## 2) unchecked-transfer

Impact: High
Confidence: Medium

- [x]  ID-3
[KlayswapEscrow.depositKSP(uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661) ignores return value by [kspToken.transferFrom(msg.sender,address(this),_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1656)

flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661

**resolved : Using SafeERC20Upgradeable for IERC20Upgradeable and Changed transferFrom to safeTransferFrom**

**reference :** [https://forum.openzeppelin.com/t/safeerc20-tokentimelock-wrappers/396/2](https://forum.openzeppelin.com/t/safeerc20-tokentimelock-wrappers/396/2)

before : 

```solidity
contract UpgradeableKlayswapEscrowV1 is
    ...
{	
    function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
		   ...
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether); // added
	      ...
    }
}
```

after : 

```solidity
contract UpgradeableKlayswapEscrowV1 is
    ...
{
    using SafeERC20Upgradeable for IERC20Upgradeable; //added
	
    function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
		   ...
        kspToken.safeTransferFrom(msg.sender, address(this), _amount * 1 ether); // added
	      ...
    }
}
```

---

## Summary

- [arbitrary-send](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#arbitrary-send) (2 results) (High)
- [controlled-delegatecall](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#controlled-delegatecall) (1 results) (High)
- [unchecked-transfer](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#unchecked-transfer) (1 results) (High)
- [unprotected-upgrade](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#unprotected-upgrade) (1 results) (High)
- [uninitialized-local](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#uninitialized-local) (1 results) (Medium)
- [unused-return](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#unused-return) (5 results) (Medium)
- [calls-loop](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#calls-loop) (1 results) (Low)
- [variable-scope](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#variable-scope) (1 results) (Low)
- [reentrancy-benign](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#reentrancy-benign) (1 results) (Low)
- [reentrancy-events](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#reentrancy-events) (3 results) (Low)
- [assembly](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#assembly) (5 results) (Informational)
- [dead-code](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#dead-code) (29 results) (Informational)
- [solc-version](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#solc-version) (2 results) (Informational)
- [low-level-calls](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#low-level-calls) (4 results) (Informational)
- [naming-convention](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#naming-convention) (38 results) (Informational)
- [too-many-digits](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#too-many-digits) (1 results) (Informational)
- [unused-state](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#unused-state) (1 results) (Informational)
- [external-function](notion://www.notion.so/1-UpgradeableKlayswapEscrowV1-sol-4e561e2506534026b00ca1ae21bb349c#external-function) (2 results) (Optimization)

## arbitrary-send

Impact: High
Confidence: Medium

- [ ]  ID-0
[KlayswapEscrow.exchangeKlayPos(address,uint256,address[],uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1756-L1763) sends eth to arbitrary user
Dangerous calls:
    - [factory.exchangeKlayPos{value: klayAmount}(token,amount,path)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1762)

flattened/UpgradeableKlayswapEscrowV1.sol#L1756-L1763

- [ ]  ID-1
[KlayswapEscrow.exchangeKlayNeg(address,uint256,address[],uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1768-L1775) sends eth to arbitrary user
Dangerous calls:
    - [factory.exchangeKlayNeg{value: klayAmount}(token,amount,path)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1774)

flattened/UpgradeableKlayswapEscrowV1.sol#L1768-L1775

## controlled-delegatecall

Impact: High
Confidence: Medium

- [ ]  ID-2
[ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051) uses delegatecall to a input-controlled function id
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1044)

flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051

## unchecked-transfer

Impact: High
Confidence: Medium

- [x]  ID-3
[KlayswapEscrow.depositKSP(uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661) ignores return value by [kspToken.transferFrom(msg.sender,address(this),_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1656)

flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661

## unprotected-upgrade

Impact: High
Confidence: High

- [ ]  ID-4
[KlayswapEscrow](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1825) is an upgradeable contract that does not protect its initiliaze functions: [KlayswapEscrow.initialize()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1511-L1515). Anyone can delete the contract with: [UUPSUpgradeable.upgradeTo(address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1142-L1145)[UUPSUpgradeable.upgradeToAndCall(address,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1155-L1163)
flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1825

## uninitialized-local

Impact: Medium
Confidence: Medium

- [ ]  ID-5
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L918) is a local variable never initialized

flattened/UpgradeableKlayswapEscrowV1.sol#L918

## unused-return

Impact: Medium
Confidence: Medium

- [ ]  ID-6
[KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540) ignores return value by [kspToken.approve(address(feeDistributor),type()(uint256).max)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1539)

flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540

- [ ]  ID-7
[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928) ignores return value by [IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L916-L925)

flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928

- [ ]  ID-8
[KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540) ignores return value by [oUsdtToken.approve(address(feeDistributor),type()(uint256).max)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1538)

flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540

- [ ]  ID-9
[KlayswapEscrow.approveToken(address,address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1808-L1810) ignores return value by [IERC20Upgradeable(_token).approve(address(_to),type()(uint256).max)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1809)

flattened/UpgradeableKlayswapEscrowV1.sol#L1808-L1810

- [ ]  ID-10
[KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540) ignores return value by [kspToken.approve(address(votingKSP),type()(uint256).max)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1537)

flattened/UpgradeableKlayswapEscrowV1.sol#L1520-L1540

## calls-loop

Impact: Low
Confidence: Medium

- [ ]  ID-11
[KlayswapEscrow.addVoting(address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1678-L1681) has external calls inside a loop: [poolVoting.addVoting(exchange,amount)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1679)

flattened/UpgradeableKlayswapEscrowV1.sol#L1678-L1681

## variable-scope

Impact: Low
Confidence: High

- [ ]  ID-12
Variable '[ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L918)' in [ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L905-L928) potentially used before declaration: [require(bool,string)(slot == _IMPLEMENTATION_SLOT,ERC1967Upgrade: unsupported proxiableUUID)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L919-L922)

flattened/UpgradeableKlayswapEscrowV1.sol#L918

## reentrancy-benign

Impact: Low
Confidence: Medium

- [x]  ID-13
Reentrancy in [KlayswapEscrow.depositKSP(uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661):
External calls:
    - [kspToken.transferFrom(msg.sender,address(this),_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1656)
    - [votingKSP.lockKSP(_amount,MAX_LOCK_PERIOD)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1657)
    State variables written after the call(s):
    - [_mint(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1658)
        - [balanceOf[_user] += _amount](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1638)
    - [_mint(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1658)
        - [totalSupply += _amount](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1639)

flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661

**resolved : Changed the place that state variable written.**

before :

```solidity
function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Deposit KSP should be bigger than 0.");
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);
        _mint(msg.sender, _amount * 1 ether);

        emit DepositKSP(msg.sender, _amount * 1 ether);
    }
```

after : 

```solidity
function depositKSP(uint256 _amount) external whenNotPaused nonReentrant {
        require(_amount > 0, "Deposit KSP should be bigger than 0.");
        _mint(msg.sender, _amount * 1 ether);
        kspToken.transferFrom(msg.sender, address(this), _amount * 1 ether);
        votingKSP.lockKSP(_amount, MAX_LOCK_PERIOD);

        emit DepositKSP(msg.sender, _amount * 1 ether);
    }
```

## reentrancy-events

Impact: Low
Confidence: Medium

- [ ]  ~~ID-14~~
Reentrancy in [KlayswapEscrow.depositKSP(uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661):
External calls:
    - [kspToken.transferFrom(msg.sender,address(this),_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1656)
    - [votingKSP.lockKSP(_amount,MAX_LOCK_PERIOD)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1657)
    Event emitted after the call(s):
    - [DepositKSP(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1660)
    - [Transfer(address(0),_user,_amount)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1640)
        - [_mint(msg.sender,_amount * 1000000000000000000)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1658)

flattened/UpgradeableKlayswapEscrowV1.sol#L1654-L1661

- [ ]  ~~ID-15~~
Reentrancy in [KlayswapEscrow.addVoting(address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1678-L1681):
External calls:
    - [poolVoting.addVoting(exchange,amount)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1679)
    Event emitted after the call(s):
    - [Voted(exchange,amount)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1680)

flattened/UpgradeableKlayswapEscrowV1.sol#L1678-L1681

- [ ]  ~~ID-16~~
Reentrancy in [KlayswapEscrow.forwardFeeToFeeDistributor()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1569-L1587):
External calls:
    - [feeDistributor.depositERC20(address(kspToken),kspTokenBalance)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1579)
    - [feeDistributor.depositERC20(address(oUsdtToken),oUsdtTokenBalance)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1583)
    Event emitted after the call(s):
    - [ForwardedFee(kspTokenBalance,oUsdtTokenBalance)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1586)

flattened/UpgradeableKlayswapEscrowV1.sol#L1569-L1587

## assembly

Impact: Informational
Confidence: High

- [ ]  ID-17
[StorageSlotUpgradeable.getAddressSlot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L773-L781) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L778-L780)

flattened/UpgradeableKlayswapEscrowV1.sol#L773-L781

- [ ]  ID-18
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L817-L819)

flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820

- [ ]  ID-19
[AddressUpgradeable.verifyCallResult(bool,bytes,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L201-L221) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L213-L216)

flattened/UpgradeableKlayswapEscrowV1.sol#L201-L221

- [ ]  ID-20
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L804-L806)

flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807

- [ ]  ID-21
[StorageSlotUpgradeable.getBooleanSlot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L786-L794) uses assembly
    - [INLINE ASM](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L791-L793)

flattened/UpgradeableKlayswapEscrowV1.sol#L786-L794

## dead-code

Impact: Informational
Confidence: Medium

- [ ]  ID-22
[ContextUpgradeable._msgData()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L389-L391) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L389-L391

- [ ]  ID-23
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L121-L133) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L121-L133

- [ ]  ID-24
[SafeERC20Upgradeable.safeApprove(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L615-L631) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L615-L631

- [ ]  ID-25
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L834) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L834

- [ ]  ID-26
[SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L633-L647) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L633-L647

- [ ]  ID-27
[AddressUpgradeable.functionCall(address,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L89-L94) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L89-L94

- [ ]  ID-28
[ERC1967UpgradeUpgradeable._getBeacon()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L986-L988) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L986-L988

- [ ]  ID-29
[ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L383) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L383

- [ ]  ID-30
[SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable,address,address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L596-L606) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L596-L606

- [ ]  ID-31
[StorageSlotUpgradeable.getUint256Slot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L812-L820

- [ ]  ID-32
[AddressUpgradeable.functionCall(address,bytes,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L102-L108) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L102-L108

- [ ]  ID-33
[AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69

- [ ]  ID-34
[AddressUpgradeable.functionStaticCall(address,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L165-L176) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L165-L176

- [ ]  ID-35
[ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1013-L1026) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1013-L1026

- [ ]  ID-36
[SafeERC20Upgradeable.safeDecreaseAllowance(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L649-L670) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L649-L670

- [ ]  ID-37
[ERC1967UpgradeUpgradeable._setBeacon(address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L993-L1005) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L993-L1005

- [ ]  ID-38
[UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1078) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1078

- [ ]  ID-39
[ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L832) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L832

- [ ]  ID-40
[ERC1967UpgradeUpgradeable._setAdmin(address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L953-L959) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L953-L959

- [ ]  ID-41
[UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1080) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L1080

- [ ]  ID-42
[SafeERC20Upgradeable._callOptionalReturn(IERC20Upgradeable,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L678-L696) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L678-L696

- [ ]  ID-43
[StorageSlotUpgradeable.getBytes32Slot(bytes32)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L799-L807

- [ ]  ID-44
[ERC1967UpgradeUpgradeable._changeAdmin(address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L966-L969) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L966-L969

- [ ]  ID-45
[ERC1967UpgradeUpgradeable._getAdmin()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L946-L948) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L946-L948

- [ ]  ID-46
[AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193

- [ ]  ID-47
[Initializable._disableInitializers()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L345-L347) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L345-L347

- [ ]  ID-48
[SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable,address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L585-L594) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L585-L594

- [ ]  ID-49
[ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L381) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L381

- [ ]  ID-50
[AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157) is never used and should be removed

flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157

## solc-version

Impact: Informational
Confidence: High

- [ ]  ID-51
Pragma version[^0.8.0](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L2) allows old versions

flattened/UpgradeableKlayswapEscrowV1.sol#L2

- [ ]  ID-52
solc-0.8.9 is not recommended for deployment

## low-level-calls

Impact: Informational
Confidence: High

- [ ]  ID-53
Low level call in [AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157):
    - [(success,returndata) = target.call{value: value}(data)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L153-L155)

flattened/UpgradeableKlayswapEscrowV1.sol#L141-L157

- [ ]  ID-54
Low level call in [AddressUpgradeable.sendValue(address,uint256)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69):
    - [(success) = recipient.call{value: amount}()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L64)

flattened/UpgradeableKlayswapEscrowV1.sol#L58-L69

- [ ]  ID-55
Low level call in [AddressUpgradeable.functionStaticCall(address,bytes,string)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193):
    - [(success,returndata) = target.staticcall(data)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L191)

flattened/UpgradeableKlayswapEscrowV1.sol#L184-L193

- [ ]  ID-56
Low level call in [ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051):
    - [(success,returndata) = target.delegatecall(data)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1044)

flattened/UpgradeableKlayswapEscrowV1.sol#L1034-L1051

## naming-convention

Impact: Informational
Confidence: High

- [ ]  ID-57
Parameter [KlayswapEscrow.approve(address,uint256)._spender](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1591) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1591

- [ ]  ID-58
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._poolVoting](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1524) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1524

- [ ]  ID-59
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._votingKSP](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1523) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1523

- [ ]  ID-60
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._sigmaVoter](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1525) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1525

- [ ]  ID-61
Parameter [KlayswapEscrow.approveToken(address,address)._token](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1808) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1808

- [ ]  ID-62
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L834) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L834

- [ ]  ID-63
Parameter [KlayswapEscrow.revokeOperator(address)._operator](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1503) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1503

- [ ]  ID-64
Variable [ContextUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L398) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L398

- [ ]  ID-65
Parameter [KlayswapEscrow.transferFrom(address,address,uint256)._from](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1611) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1611

- [ ]  ID-66
Parameter [KlayswapEscrow.depositKSP(uint256)._amount](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1654) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1654

- [ ]  ID-67
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1222-L1224) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1222-L1224

- [ ]  ID-68
Parameter [KlayswapEscrow.approveToken(address,address)._to](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1808) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1808

- [ ]  ID-69
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._kspToken](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1521) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1521

- [ ]  ID-70
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._kusdtToken](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1522) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1522

- [ ]  ID-71
Function [OwnableUpgradeable.__Ownable_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L424-L426) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L424-L426

- [ ]  ID-72
Parameter [KlayswapEscrow.transfer(address,uint256)._to](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1601) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1601

- [ ]  ID-73
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._factory](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1526) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1526

- [ ]  ID-74
Variable [OwnableUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L485) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L485

- [ ]  ID-75
Variable [UUPSUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1182) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1182

- [ ]  ID-76
Variable [PausableUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1348) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1348

- [ ]  ID-77
Parameter [KlayswapEscrow.transfer(address,uint256)._value](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1601) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1601

- [ ]  ID-78
Variable [ERC1967UpgradeUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1058) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1058

- [ ]  ID-79
Parameter [KlayswapEscrow.setInitialInfo(IERC20Upgradeable,IERC20Upgradeable,IVotingKSP,IPoolVoting,ISigmaVoter,IFactory,IFeeDistributor)._feeDistributor](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1527) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1527

- [ ]  ID-80
Function [ReentrancyGuardUpgradeable.__ReentrancyGuard_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1218-L1220) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1218-L1220

- [ ]  ID-81
Function [ContextUpgradeable.__Context_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L383) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L383

- [ ]  ID-82
Function [UUPSUpgradeable.__UUPSUpgradeable_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1080) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1080

- [ ]  ID-83
Parameter [KlayswapEscrow.transferFrom(address,address,uint256)._value](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1613) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1613

- [ ]  ID-84
Variable [ReentrancyGuardUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1252) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1252

- [ ]  ID-85
Parameter [KlayswapEscrow.approve(address,uint256)._value](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1591) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1591

- [ ]  ID-86
Function [OwnableUpgradeable.__Ownable_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L428-L430) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L428-L430

- [ ]  ID-87
Variable [UUPSUpgradeable.__self](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1083) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1083

- [ ]  ID-88
Function [ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L832) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L832

- [ ]  ID-89
Function [UUPSUpgradeable.__UUPSUpgradeable_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1078) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1078

- [ ]  ID-90
Parameter [KlayswapEscrow.setOperator(address[])._operators](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1493) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1493

- [ ]  ID-91
Function [PausableUpgradeable.__Pausable_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1280-L1282) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1280-L1282

- [ ]  ID-92
Parameter [KlayswapEscrow.transferFrom(address,address,uint256)._to](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1612) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1612

- [ ]  ID-93
Function [ContextUpgradeable.__Context_init()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L381) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L381

- [ ]  ID-94
Function [PausableUpgradeable.__Pausable_init_unchained()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1284-L1286) is not in mixedCase

flattened/UpgradeableKlayswapEscrowV1.sol#L1284-L1286

## too-many-digits

Impact: Informational
Confidence: Medium

- [ ]  ID-95
[KlayswapEscrow.slitherConstructorConstantVariables()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1825) uses literals with too many digits:
    - [MAX_LOCK_PERIOD = 1555200000](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1474)

flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1825

## unused-state

Impact: Informational
Confidence: High

- [ ]  ID-96
[PausableUpgradeable.__gap](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1348) is never used in [KlayswapEscrow](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L1447-L1825)

flattened/UpgradeableKlayswapEscrowV1.sol#L1348

## external-function

Impact: Optimization
Confidence: High

- [ ]  ID-97
transferOwnership(address) should be declared external:
    - [OwnableUpgradeable.transferOwnership(address)](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L462-L468)

flattened/UpgradeableKlayswapEscrowV1.sol#L462-L468

- [ ]  ID-98
renounceOwnership() should be declared external:
    - [OwnableUpgradeable.renounceOwnership()](notion://www.notion.so/flattened/UpgradeableKlayswapEscrowV1.sol#L454-L456)

flattened/UpgradeableKlayswapEscrowV1.sol#L454-L456