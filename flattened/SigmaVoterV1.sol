// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(
                _initialized < version,
                "Initializable: contract is already initialized"
            );
            _initialized = version;
            return true;
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage r)
    {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot)
        internal
        pure
        returns (BooleanSlot storage r)
    {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot)
        internal
        pure
        returns (Bytes32Slot storage r)
    {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot)
        internal
        pure
        returns (Uint256Slot storage r)
    {
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {}

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {}

    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT =
        0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return
            StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(
            AddressUpgradeable.isContract(newImplementation),
            "ERC1967: new implementation is not a contract"
        );
        StorageSlotUpgradeable
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try
                IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID()
            returns (bytes32 slot) {
                require(
                    slot == _IMPLEMENTATION_SLOT,
                    "ERC1967Upgrade: unsupported proxiableUUID"
                );
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(
            newAdmin != address(0),
            "ERC1967: new admin is the zero address"
        );
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(
            AddressUpgradeable.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            AddressUpgradeable.isContract(
                IBeaconUpgradeable(newBeacon).implementation()
            ),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(
                IBeaconUpgradeable(newBeacon).implementation(),
                data
            );
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data)
        private
        returns (bytes memory)
    {
        require(
            AddressUpgradeable.isContract(target),
            "Address: delegate call to non-contract"
        );

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            AddressUpgradeable.verifyCallResult(
                success,
                returndata,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is
    Initializable,
    IERC1822ProxiableUpgradeable,
    ERC1967UpgradeUpgradeable
{
    function __UUPSUpgradeable_init() internal onlyInitializing {}

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {}

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(
            address(this) != __self,
            "Function must be called through delegatecall"
        );
        require(
            _getImplementation() == __self,
            "Function must be called through active proxy"
        );
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(
            address(this) == __self,
            "UUPSUpgradeable: must not be called through delegatecall"
        );
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID()
        external
        view
        virtual
        override
        notDelegated
        returns (bytes32)
    {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable
        virtual
        onlyProxy
    {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface IvxERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// File: contracts/interfaces/sigma/ISigmaVoter.sol

interface ISigmaVoter {
    function getCurrentVotes()
        external
        view
        returns (
            uint256 weightsTotal,
            address[] memory pools,
            uint256[] memory weights
        );

    function getUserVotesCount(address _user) external view returns (uint256);

    function deleteAllPoolVote() external;
}

// File: contracts/Upgradeable/SigmaVoterV1.sol

contract SigmaVoterV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ISigmaVoter
{
    IvxERC20 public vxSIG;

    /// @notice Total pool count submitting to klayswap
    uint256 public constant MAX_SUBMIT_POOL = 10;
    /// @notice pools that is determined by Sigma Vote among the MAX_SUBMIT_POOL
    uint256 public constant TOP_VOTES_POOL_COUNT = 7;
    /// @notice pools that is expected to have top yield. this is will be used for abstentions or votes that was not made it to TOP_VOTE.
    uint256 public constant TOP_YIELD_POOL_COUNT = 3;

    /// @notice save more vote pool for buffer. This is for when user withdraw votes from the pool.
    uint256 public constant MAX_VOTES_WITH_BUFFER =
        TOP_VOTES_POOL_COUNT + 5 + 1;

    uint256 public USER_MAX_VOTE_POOL;

    /// @notice total used vxSIG for vote
    uint256 public totalUsedVxSIG;

    /// @notice pool -> total vxSIG allocated
    mapping(address => PoolInfo) public poolInfos;
    address[] public poolAddresses;

    /// @notice user -> total voted vxSIG
    mapping(address => uint256) public userTotalUsedVxSIG;
    /// @notice user -> PoolData vxSIG for a pool
    mapping(address => PoolVote[]) public userPoolVotes;
    /// @notice user -> pool -> isVoted
    mapping(address => mapping(address => UserPoolInfo)) public userPoolInfos;

    address[] public topYieldPools;
    /// always first one is 0;
    uint64[MAX_VOTES_WITH_BUFFER] public topVotes;

    uint256 public topVotesLength; // actual number of items stored in `topVotes`
    uint256 public minTopVote; // smallest vote-weight for pools included in `topVotes`
    uint256 public minTopVoteIndex; // `topVotes` index where the smallest vote is stored (always +1 cause it has 0 at first)

    struct PoolVote {
        address pool;
        uint256 vxSIGAmount;
    }

    struct UserPoolInfo {
        uint256 poolVoteIndex;
        bool isVoted;
    }

    struct PoolInfo {
        uint256 vxSIGAmount;
        bool isInitiated;
        uint256 listPointer;
        uint8 topVotesIndex;
    }

    event PoolAdded(address indexed poolAddress, uint256 totalPoolLength);
    event VoteWithdrawn(
        address indexed user,
        address indexed poolAddress,
        uint256 withdrawnAmount,
        uint256 newPoolVxSIGAmount
    );
    event AllVoteWithdrawn(address indexed user);

    /* ========== Restricted Function  ========== */

    /**
        @notice Initialize UUPS upgradeable smart contract.
     */
    function initialize() external initializer {
        __Ownable_init();
        __Pausable_init();

        // poolAddress[0] is always empty. So if (poolInfo[x].listPointer == 0) means no pool set yet.
        poolAddresses.push(address(0));
    }

    /**
        @notice restrict upgrade to only owner.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}

    /**
        @notice pause contract functions.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
        @notice unpause contract functions.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function setInitialInfo(
        address[] calldata _lpPools,
        address[] calldata _topYieldPools,
        IvxERC20 _vxSIG,
        uint256 _userMaxVote
    ) external onlyOwner {
        require(
            _topYieldPools.length == TOP_YIELD_POOL_COUNT,
            "Top yield pool length doesn't match with TOP_YIELD_POOL_COUNT"
        );
        vxSIG = _vxSIG;
        topYieldPools = _topYieldPools;
        USER_MAX_VOTE_POOL = _userMaxVote;

        // Add pools
        for (uint256 i = 0; i < _lpPools.length; i++) {
            addPool(_lpPools[i]);
        }
    }

    /**
     @notice sets pools that is going to take abstentions. Set all pool at once.
    */
    function setTopYieldPools(address[] calldata _pools) external onlyOwner {
        topYieldPools = _pools;
    }

    /**
     @notice set USER_MAX_VOTE_POOL
     */
    function setUserMaxVotePool(uint256 _value) external onlyOwner {
        USER_MAX_VOTE_POOL = _value;
    }

    /**
        @notice add pool and initiate.
     */
    function addPool(address _pool) public onlyOwner {
        require(!isPool(_pool), "This pool already has been added.");

        poolInfos[_pool] = PoolInfo({
            vxSIGAmount: 0,
            isInitiated: true,
            listPointer: poolAddresses.length,
            topVotesIndex: 0
        });
        poolAddresses.push(_pool);
        uint256 length = poolAddresses.length - 1;
        emit PoolAdded(_pool, length);
    }

    /* ========== External / Public Function  ========== */

    /**
     @notice withdraws staked xSIG
     @notice You should be aware that amount unit is ETH not wei.
     @param _pools array of pools to vote.
     @param _vxSIGAmounts array of the amount of vxSIG to vote. IT SHOULD BE ETH. 
     */
    function addAllPoolVote(
        address[] calldata _pools,
        uint256[] calldata _vxSIGAmounts
    ) external whenNotPaused {
        require(
            _pools.length == _vxSIGAmounts.length,
            "Pool length doesn't match with vxSIGAmounts length."
        );
        require(_pools.length > 0, "Must vote for at least one pool");

        uint256 _totalVxSIGUsed;

        // copy values to minimize gas fee.
        uint256 _topVotesLengthMem = topVotesLength;
        uint256 _minTopVoteMem = minTopVote;
        uint256 _minTopVoteIndexMem = minTopVoteIndex;
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes;

        for (uint256 i = 0; i < _pools.length; i++) {
            address _pool = _pools[i];
            uint256 _vxSIG = _vxSIGAmounts[i];
            require(_vxSIG > 0, "Vote vxSIG should be bigger than 0");
            _updatePoolVote(_pool, _vxSIG);
            _totalVxSIGUsed += _vxSIG;
            userTotalUsedVxSIG[msg.sender] += _vxSIG;

            //Update top vote logic.
            uint256 newPoolVxSIGAmount = poolInfos[_pool].vxSIGAmount;
            uint256 poolAddressIndex = poolInfos[_pool].listPointer;
            if (poolInfos[_pool].topVotesIndex > 0) {
                uint256 poolTopVoteIndex = poolInfos[_pool].topVotesIndex;

                t[poolTopVoteIndex] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );

                if (poolTopVoteIndex == _minTopVoteIndexMem) {
                    // if this pool was the minTopVoteIndex, as there is newly added votes, findMinTopVote again.
                    (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                        t,
                        _topVotesLengthMem + 1
                    );
                }
            } else if (_topVotesLengthMem < MAX_VOTES_WITH_BUFFER - 1) {
                _topVotesLengthMem += 1;

                t[_topVotesLengthMem] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                poolInfos[_pool].topVotesIndex = uint8(_topVotesLengthMem);

                if (
                    newPoolVxSIGAmount < _minTopVoteMem ||
                    _topVotesLengthMem == 1 // If this is first top vote added,
                ) {
                    _minTopVoteMem = newPoolVxSIGAmount;
                    _minTopVoteIndexMem = _topVotesLengthMem;
                }
            } else if (newPoolVxSIGAmount > _minTopVoteMem) {
                uint256 addressIndex = t[_minTopVoteIndexMem] >> 40;
                poolInfos[poolAddresses[addressIndex]].topVotesIndex = 0;
                t[_minTopVoteIndexMem] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                poolInfos[_pool].topVotesIndex = uint8(_minTopVoteIndexMem);

                // // iterate to find the new _minTopVoteMem and _minTopVoteIndexMem
                (_minTopVoteMem, _minTopVoteIndexMem) = _findMinTopVote(
                    t,
                    MAX_VOTES_WITH_BUFFER
                );
            }
        }

        totalUsedVxSIG += _totalVxSIGUsed;

        topVotes = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;
    }

    /**
        @notice withdraw certain amount of vxSIGVote from the pool
        @param _pool pool address to add. 
        @param _vxSIGAmount vxSIG Amount to withdraw in ETH not wei. 
     */
    function deletePoolVote(address _pool, uint256 _vxSIGAmount)
        public
        whenNotPaused
    {
        require(isPool(_pool), "This pool is not registred by the admin.");
        require(
            userPoolInfos[msg.sender][_pool].isVoted,
            "User never voted to this pool."
        );

        totalUsedVxSIG -= _vxSIGAmount;
        userTotalUsedVxSIG[msg.sender] -= _vxSIGAmount;
        uint256 newPoolVxSIGAmount = poolInfos[_pool].vxSIGAmount -
            _vxSIGAmount;

        // copy values to minimize gas fee.
        uint256 _topVotesLengthMem = topVotesLength;
        uint256 _minTopVoteMem = minTopVote;
        uint256 _minTopVoteIndexMem = minTopVoteIndex;
        uint64[MAX_VOTES_WITH_BUFFER] memory t = topVotes;

        uint256 poolAddressIndex = poolInfos[_pool].listPointer;
        uint256 poolTopVotesIndex = poolInfos[_pool].topVotesIndex;

        if (newPoolVxSIGAmount == 0) {
            if (poolTopVotesIndex > 0) {
                // If this pool was in topVotes
                if (poolTopVotesIndex == _topVotesLengthMem) {
                    // If this pool was at the end of the topVotes
                    delete t[_topVotesLengthMem];
                } else {
                    t[poolTopVotesIndex] = t[_topVotesLengthMem];
                    uint256 addressIndex = t[poolTopVotesIndex] >> 40;
                    poolInfos[poolAddresses[addressIndex]]
                        .topVotesIndex = uint8(poolTopVotesIndex);
                    delete t[_topVotesLengthMem];
                    if (_minTopVoteIndexMem == _topVotesLengthMem) {
                        //if minTopVoteIndexMem was the one moved, change the minTopvoteIndex to moved index.
                        _minTopVoteIndexMem = poolTopVotesIndex;
                    }
                }
                _topVotesLengthMem -= 1;
                if (_topVotesLengthMem == 0) {
                    _minTopVoteMem = 0;
                    _minTopVoteIndexMem = 0;
                }
                poolInfos[_pool].topVotesIndex = 0;
            }
            _updatePoolVxSIGAmount(_pool, 0);
        } else {
            if (poolTopVotesIndex > 0) {
                t[poolTopVotesIndex] = pack(
                    poolAddressIndex,
                    newPoolVxSIGAmount
                );
                if (newPoolVxSIGAmount < _minTopVoteMem) {
                    _minTopVoteMem = newPoolVxSIGAmount;
                    _minTopVoteIndexMem = poolTopVotesIndex;
                }
            }
            _updatePoolVxSIGAmount(_pool, newPoolVxSIGAmount);
        }

        topVotes = t;
        topVotesLength = _topVotesLengthMem;
        minTopVote = _minTopVoteMem;
        minTopVoteIndex = _minTopVoteIndexMem;

        uint256 poolVoteIndex = userPoolInfos[msg.sender][_pool].poolVoteIndex;
        PoolVote storage userPoolVote = userPoolVotes[msg.sender][
            poolVoteIndex
        ];
        require(
            userPoolVote.vxSIGAmount >= _vxSIGAmount,
            "User didn't vote _vxSIGAmount in this pool"
        );
        userPoolVote.vxSIGAmount -= _vxSIGAmount;

        if (userPoolVote.vxSIGAmount == 0) {
            //delete from userPoolInfos
            userPoolInfos[msg.sender][_pool].isVoted = false;
            userPoolInfos[msg.sender][_pool].poolVoteIndex = 0;

            PoolVote[] storage poolVotes = userPoolVotes[msg.sender];
            if (poolVotes.length != 2) {
                PoolVote memory poolVoteToMove = poolVotes[
                    poolVotes.length - 1
                ];
                poolVotes[poolVoteIndex] = poolVoteToMove;
                userPoolInfos[msg.sender][poolVoteToMove.pool]
                    .poolVoteIndex = poolVoteIndex;
                poolVotes.pop();
            } else {
                delete userPoolVotes[msg.sender];
            }
        }

        emit VoteWithdrawn(msg.sender, _pool, _vxSIGAmount, newPoolVxSIGAmount);
    }

    /**
        @notice withdraw user's all of vxSIG vote.
     */
    function deleteAllPoolVote() external override whenNotPaused {
        PoolVote[] memory userVotes = userPoolVotes[msg.sender];
        require(userVotes.length > 0, "User didn't vote yet");

        for (uint256 i = 1; i < userVotes.length; i++) {
            deletePoolVote(userVotes[i].pool, userVotes[i].vxSIGAmount);
        }

        emit AllVoteWithdrawn(msg.sender);
    }

    /* ========== Internal & Private Function  ========== */

    function _updatePoolVxSIGAmount(address _pool, uint256 newVxSIGAmount)
        internal
    {
        require(isPool(_pool), "This pool is not registred by the admin.");
        poolInfos[_pool].vxSIGAmount = newVxSIGAmount;
    }

    function _findMinTopVote(
        uint64[MAX_VOTES_WITH_BUFFER] memory t,
        uint256 length
    ) internal pure returns (uint256, uint256) {
        uint256 _minTopVoteMem = type(uint256).max;
        uint256 _minTopVoteIndexMem = 0;
        for (uint256 i = 1; i < length; i++) {
            uint256 value = t[i] % 2**39;
            if (value < _minTopVoteMem) {
                _minTopVoteMem = value;
                _minTopVoteIndexMem = i;
            }
        }
        return (_minTopVoteMem, _minTopVoteIndexMem);
    }

    /**
        @notice update PoolInfo and userPoolInfo,userVotes. 
        @param _pool pool address to add. 
        @param _vxSIGAmount vxSIG Amount in ETH not wei. 
     */
    function _updatePoolVote(address _pool, uint256 _vxSIGAmount) internal {
        require(isPool(_pool), "This pool is not registred by the admin.");
        require(
            availableVotes(msg.sender) >= _vxSIGAmount,
            "insufficient vxSIG to vote"
        );

        uint256 newVxSIGAmount = poolInfos[_pool].vxSIGAmount + _vxSIGAmount;

        _updatePoolVxSIGAmount(_pool, newVxSIGAmount);

        PoolVote[] storage userVotes = userPoolVotes[msg.sender];

        //if userVotes.length ==0 add empty userPoolInfo.
        if (userVotes.length == 0) {
            userVotes.push(PoolVote({pool: address(0), vxSIGAmount: 0}));
        }

        if (userPoolInfos[msg.sender][_pool].isVoted) {
            // If already voted to this pool
            userVotes[userPoolInfos[msg.sender][_pool].poolVoteIndex]
                .vxSIGAmount += _vxSIGAmount;
        } else {
            require(
                userVotes.length < USER_MAX_VOTE_POOL + 1,
                "User exceeded max vote pool count."
            );
            // If never been voted to this pool

            userVotes.push(PoolVote({pool: _pool, vxSIGAmount: _vxSIGAmount}));
            uint256 index = userVotes.length - 1;

            userPoolInfos[msg.sender][_pool] = UserPoolInfo({
                poolVoteIndex: index,
                isVoted: true
            });
        }
    }

    function pack(uint256 id, uint256 vxSIGAmount)
        internal
        pure
        returns (uint64)
    {
        uint64 value = uint64((id << 40) + vxSIGAmount);
        return value;
    }

    function unpack(uint256 value)
        internal
        pure
        returns (uint256 id, uint256 vxSIGAmount)
    {
        id = (value >> 40);
        vxSIGAmount = uint256(value % 2**40);
        return (id, vxSIGAmount);
    }

    /* ========== View Function  ========== */
    /**
     @notice get current top votes.
     */
    function getCurrentTopVotes()
        external
        view
        returns (
            address[MAX_VOTES_WITH_BUFFER] memory,
            uint256[MAX_VOTES_WITH_BUFFER] memory
        )
    {
        uint256[MAX_VOTES_WITH_BUFFER] memory weights;
        address[MAX_VOTES_WITH_BUFFER] memory addresses;

        for (uint256 i = 1; i < topVotesLength + 1; i++) {
            (uint256 addressIndex, uint256 weight) = unpack(topVotes[i]);
            weights[i - 1] = uint256(weight);
            addresses[i - 1] = poolAddresses[addressIndex];
        }
        return (addresses, weights);
    }

    /**
        @notice getCurrentVotes for submit to Klayswap. It contains pre-setted TOP_YIELD_POOLS.
     */
    function getCurrentVotes()
        external
        view
        override
        returns (
            uint256 _vxSIGTotalSupply,
            address[] memory pools,
            uint256[] memory weights
        )
    {
        uint256 length = TOP_YIELD_POOL_COUNT;
        length += topVotesLength;

        pools = new address[](length);
        weights = new uint256[](length);

        for (uint256 i = 1; i < length - TOP_YIELD_POOL_COUNT + 1; i++) {
            (uint256 addressIndex, uint256 weight) = unpack(topVotes[i]);
            pools[i - 1] = poolAddresses[addressIndex];
            weights[i - 1] = weight;
        }
        if (length > MAX_SUBMIT_POOL) {
            while (length > MAX_SUBMIT_POOL) {
                uint256 minValue = type(uint256).max;
                uint256 minIndex = 0;
                for (uint256 i = 0; i < length - TOP_YIELD_POOL_COUNT; i++) {
                    uint256 weight = weights[i];
                    if (weight < minValue) {
                        minValue = weight;
                        minIndex = i;
                    }
                }
                uint256 idx = length - TOP_YIELD_POOL_COUNT - 1;
                weights[minIndex] = weights[idx];
                pools[minIndex] = pools[idx];
                delete weights[idx];
                delete pools[idx];
                length -= 1;
            }

            assembly {
                mstore(pools, length)
                mstore(weights, length)
            }
        }

        // Valid VxSIG which is actually vote to klayswap.
        uint256 totalValidVxSIG = 0;
        for (uint256 i = 0; i < length - TOP_YIELD_POOL_COUNT; i++) {
            totalValidVxSIG += weights[i];
        }

        uint256 vxSIGTotalSupply = vxSIG.totalSupply() / 1e18;
        uint256 vxSIGNotUsedOrNotValid = vxSIGTotalSupply - totalValidVxSIG;

        uint256 eachDisributedVxSIG = vxSIGNotUsedOrNotValid /
            TOP_YIELD_POOL_COUNT;

        length -= TOP_YIELD_POOL_COUNT;

        for (uint256 i = 0; i < TOP_YIELD_POOL_COUNT; i++) {
            pools[length + i] = topYieldPools[i];
            weights[length + i] = eachDisributedVxSIG;
        }

        return (vxSIGTotalSupply, pools, weights);
    }

    /**
        @notice check if the given address is registered pool.
     */
    function isPool(address _pool) public view returns (bool) {
        return poolInfos[_pool].isInitiated;
    }

    /**
        @notice return pool count in sigma vote. -1 because index 0 is empty.
     */
    function getPoolCount() public view returns (uint256) {
        return poolAddresses.length - 1;
    }

    /**
        @notice Get an account's unused vote weight for for the current week
        @param _user Address to query
        @return uint Amount of unused weight
     */
    function availableVotes(address _user) public view returns (uint256) {
        uint256 userUsedVxSIG = userTotalUsedVxSIG[_user];
        uint256 totalWeight = vxSIG.balanceOf(_user) / 1e18;
        return totalWeight - userUsedVxSIG;
    }

    /**
        @notice get user total pool vote count.
     */
    function getUserVotesCount(address _user)
        external
        view
        override
        returns (uint256)
    {
        if (userPoolVotes[_user].length == 0) {
            return 0;
        } else {
            return userPoolVotes[_user].length - 1;
        }
    }
}
