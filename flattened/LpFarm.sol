// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    // function approve(address spender, uint256 amount) external returns (bool);
}

// Farm distributes the sig rewards based on staked LP to each user.
//
// Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by LTO Network to work for non-mintable sig.
// Modified by Sigma to work for boosted rewards with vxSIG.
contract LpFarm is Ownable {
    using SafeERC20 for IERC20;

    IvxERC20 public vxSIG;

    /// @notice variable name with prefix "boost" means that's related to boost reward. Others are related to base reward.

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 boostRewardDebt; // Boosted Reward debt
        uint256 boostWeight;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 lastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 boostAllocPoint; // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 boostLastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 boostAccERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        uint256 totalBoostWeight; // Total boost weight of the pool
    }

    // Address of the sig Token contract.
    IERC20 public sig;
    // The total amount of SIG that's paid out as base reward.
    uint256 public paidOut = 0;
    // sig tokens rewarded per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    /// @notice Reward per block will be divided by totalAllocPoint
    uint256 public totalAllocPoint = 0; // boostTotalAllocPoint + baseTotalAllocPoint

    uint256 public boostTotalAllocPoint = 0;
    uint256 public baseTotalAllocPoint = 0;

    // The block number when farming starts.
    uint256 public startBlock;
    // The block number when farming ends.
    uint256 public endBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(address indexed lpToken, uint256 indexed pid);
    event Funded(address indexed from, uint256 amount, uint256 newEndBlock);

    /* ========== External & Public Function  ========== */

    /**
      @notice deposit lp token in the pool
      @param _pid pool Id
      @param _amount amount of the lp token to deposit
     */
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) /
                1e36) - user.rewardDebt;
            erc20Transfer(msg.sender, pendingAmount);

            //if user has boost,
            if (user.boostWeight > 0) {
                uint256 boostPendingaAmount = (user.boostWeight *
                    pool.boostAccERC20PerShare) /
                    1e36 -
                    user.boostRewardDebt;
                erc20Transfer(msg.sender, boostPendingaAmount);
            }
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount += _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;
        }

        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
      @notice withdraw lp token and gets pending token.
      @param _pid pool Id
      @param _amount amount of the lp token to withdraw
     */
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            user.amount >= _amount,
            "withdraw: can't withdraw more than deposit"
        );
        updatePool(_pid);

        uint256 pendingAmount = ((user.amount * pool.accERC20PerShare) / 1e36) -
            user.rewardDebt;

        //if user has boost,
        if (user.boostWeight > 0) {
            uint256 boostPendingAmount = (user.boostWeight *
                pool.boostAccERC20PerShare) /
                1e36 -
                user.boostRewardDebt;
            pendingAmount += boostPendingAmount;
        }

        erc20Transfer(msg.sender, pendingAmount);

        user.amount -= _amount;
        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;

            updateBoostWeightToPool(_pid);
        }

        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /**
      @notice claim pending rewards on the pool
      @param _pid pool id 
     */
    function claim(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "User didn't deposit in this pool.");
        uint256 pendingAmount = basePending(_pid, msg.sender);
        if (user.boostWeight > 0) {
            pendingAmount += boostPending(_pid, msg.sender);
        }
        require(pendingAmount > 0, "claim: no rewards to claim");
        updatePool(_pid);
        erc20Transfer(msg.sender, pendingAmount);

        user.rewardDebt = (user.amount * pool.accERC20PerShare) / 1e36;
        if (user.boostWeight > 0) {
            user.boostRewardDebt =
                (user.boostWeight * pool.boostAccERC20PerShare) /
                1e36;
        }
        emit Claim(msg.sender, _pid, pendingAmount);
    }

    /**
      @notice update boost weight of the user. 
      @notice This will be called from xSIGFarm if user activate boost.
     */
    function updateBoostWeight() external {
        for (uint256 i = 0; i < poolInfo.length; i++) {
            UserInfo storage user = userInfo[i][msg.sender];
            //0. if user has amount
            if (user.amount > 0) {
                _updateBoostWeight(msg.sender, i);
            }
        }
    }

    function updateBoostWeightToPool(uint256 _pid) public {
        // user's amount can be zero
        _updateBoostWeight(msg.sender, _pid);
    }

    /**
      @notice update pool both with base,boost
     */
    function updatePool(uint256 _pid) public {
        _updatePoolWithBaseReward(_pid);
        _updatePoolWithBoostReward(_pid);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
      @notice Fund the farm, anyone call fund sig token.
      @param _amount amount of the token to fund.
     */
    function fund(uint256 _amount) public {
        require(block.number < endBlock, "fund: too late, the farm is closed");
        require(_amount > 0, "Funding amount should be bigger than 0");

        sig.safeTransferFrom(address(msg.sender), address(this), _amount);
        endBlock += _amount / rewardPerBlock;

        emit Funded(msg.sender, _amount, endBlock);
    }

    /* ========== Restricted Function  ========== */
    /**
     @notice sets initialInfo of the contract.
     */
    function setInitialInfo(
        IERC20 _sig,
        IvxERC20 _vxSIG,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) external onlyOwner {
        require(
            _startBlock > block.number,
            "Start block should be in the future"
        );
        sig = _sig;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock;
        vxSIG = _vxSIG;
    }

    /**
      @notice Add a new lp to the pool. Can only be called by the owner.
      @notice DO NOT add the same LP token more than once. Rewards will be messed up if you do.
      @param _allocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function addPool(
        uint256 _allocPoint,
        uint256 _boostAllocPoint,
        IERC20 _lpToken
    ) public onlyOwner {
        massUpdatePools();

        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        baseTotalAllocPoint += _allocPoint;
        boostTotalAllocPoint += _boostAllocPoint;
        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accERC20PerShare: 0,
                boostAllocPoint: _boostAllocPoint,
                boostLastRewardBlock: lastRewardBlock,
                boostAccERC20PerShare: 0,
                totalBoostWeight: 0
            })
        );

        emit PoolAdded(address(_lpToken), poolInfo.length - 1);
    }

    /**
      @notice Update the given pool's sig allocation point. Can only be called by the owner.
      @param _pid pool Id
      @param _allocPoint base reward allocation of the pool
      @param _boostAllocPoint boost reward allocation of the pool
     */
    function setPool(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _boostAllocPoint
    ) public onlyOwner {
        massUpdatePools();
        baseTotalAllocPoint =
            baseTotalAllocPoint -
            poolInfo[_pid].allocPoint +
            _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        boostTotalAllocPoint =
            boostTotalAllocPoint -
            poolInfo[_pid].boostAllocPoint +
            _boostAllocPoint;
        poolInfo[_pid].boostAllocPoint = _boostAllocPoint;

        totalAllocPoint = baseTotalAllocPoint + boostTotalAllocPoint;
    }

    /**
     @notice set rewardPerBlock. It will change endblock as well.
     */
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(
            _rewardPerBlock > 0,
            "reward per block should be bigger than 0"
        );
        rewardPerBlock = _rewardPerBlock;
        uint256 sigBalance = sig.balanceOf(address(this));
        endBlock = sigBalance / rewardPerBlock;
    }

    /* ========== Internal & Private Function  ========== */

    /**
      @notice update boost weight of all existing pool
      @param _addr address of the user
      @param _pid pool id 
     */
    function _updateBoostWeight(address _addr, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _updatePoolWithBoostReward(_pid);

        uint256 vxAmount = vxSIG.balanceOf(_addr);
        uint256 oldBoostWeight = user.boostWeight;

        uint256 newBoostWeight = _sqrt(user.amount * vxAmount);
        user.boostWeight = newBoostWeight;
        pool.totalBoostWeight =
            pool.totalBoostWeight -
            oldBoostWeight +
            newBoostWeight;
    }

    /**
      @notice send _amount amount of sig to _to & add up paidOut
      @param _to receiver of the token
      @param _amount amount of the sig token to send 
     */
    function erc20Transfer(address _to, uint256 _amount) internal {
        sig.transfer(_to, _amount);
        paidOut += _amount;
    }

    /**
      @notice update base reward variable of the pool
      @param _pid pool Id
     */
    function _updatePoolWithBaseReward(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock - (pool.lastRewardBlock);

        uint256 erc20Reward = (nrOfBlocks *
            (rewardPerBlock) *
            (pool.allocPoint)) / (totalAllocPoint);

        pool.accERC20PerShare =
            pool.accERC20PerShare +
            (erc20Reward * 1e36) /
            lpSupply;
        pool.lastRewardBlock = block.number;
    }

    /**
      @notice update boost reward variable of the pool
      @param _pid pool Id
     */
    function _updatePoolWithBoostReward(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (lastBlock <= pool.boostLastRewardBlock) {
            return;
        }
        uint256 totalBoostWeight = pool.totalBoostWeight;
        if (totalBoostWeight == 0) {
            pool.boostLastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock - (pool.boostLastRewardBlock);

        uint256 erc20Reward = (nrOfBlocks *
            rewardPerBlock *
            pool.boostAllocPoint) / (totalAllocPoint);

        pool.boostAccERC20PerShare =
            pool.boostAccERC20PerShare +
            ((erc20Reward * 1e36) / totalBoostWeight);
        pool.boostLastRewardBlock = block.number;
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /* ========== View Function  ========== */

    /**
     @notice total pending amount on protocol.
     */
    function totalPending() external view returns (uint256) {
        if (block.number <= startBlock) {
            return 0;
        }

        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
        return (rewardPerBlock * (lastBlock - startBlock)) - paidOut;
    }

    /**
     @notice get pool length
     */
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /**
     @notice pending amount with base reward.
     */
    function basePending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return 0;
        }
        uint256 accERC20PerShare = pool.accERC20PerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (
            lastBlock > pool.lastRewardBlock &&
            block.number > pool.lastRewardBlock &&
            lpSupply != 0
        ) {
            uint256 nrOfBlocks = lastBlock - pool.lastRewardBlock;
            uint256 erc20Reward = (nrOfBlocks *
                (rewardPerBlock) *
                (pool.allocPoint)) / (totalAllocPoint);
            accERC20PerShare =
                accERC20PerShare +
                ((erc20Reward * 1e36) / lpSupply);
        }

        return ((user.amount * accERC20PerShare) / 1e36) - user.rewardDebt;
    }

    /**
     @notice pending amount with boost reward.
     */
    function boostPending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];

        if (user.boostWeight == 0) {
            return 0;
        }
        uint256 boostAccERC20PerShare = pool.boostAccERC20PerShare;
        uint256 totalBoostWeight = pool.totalBoostWeight;
        uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

        if (
            lastBlock > pool.boostLastRewardBlock &&
            block.number > pool.boostLastRewardBlock &&
            totalBoostWeight != 0
        ) {
            uint256 nrOfBlocks = lastBlock - (pool.boostLastRewardBlock);

            uint256 erc20Reward = (nrOfBlocks *
                rewardPerBlock *
                pool.boostAllocPoint) / (totalAllocPoint);

            boostAccERC20PerShare =
                boostAccERC20PerShare +
                (erc20Reward * 1e36) /
                totalBoostWeight;
        }

        return
            (user.boostWeight * boostAccERC20PerShare) /
            1e36 -
            user.boostRewardDebt;
    }

    /**
     @notice deposited amount of the lp.
     */
    function deposited(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_pid][_user];
        return user.amount;
    }
}
