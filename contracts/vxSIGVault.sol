//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./dependencies/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract vxSIGVault is Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public xSIG;
    uint256 boostPerHour;
    uint256 maxBoostPerSIG;

    uint256 totalvxSIGWeight;

    struct UserInfo {
        uint256 xSIGAmount;
        uint256 totalBoost;
        uint256 lastUpdated;
        uint256 startTime;
    }

    mapping(address => UserInfo) public userInfoOf;

    /* ========== External Function  ========== */
    function bond(uint256 _amount) external {}

    function unbond(uint256 _amount) external {}

    /* ========== Restricted Function  ========== */

    function setInitialInfo(
        address _SIG,
        uint256 _boostPerHour,
        uint256 _maxBoostPerSIG
    ) external onlyOwner {
        xSIG = IERC20(_SIG);
        boostPerHour = _boostPerHour;
        maxBoostPerSIG = _maxBoostPerSIG;
    }

    function setBoostPerHour(uint256 _boostPerHour) external onlyOwner {
        boostPerHour = _boostPerHour;
    }

    function setMaxBoosterPerSIG(uint256 _maxBoostPerSIG) external onlyOwner {
        maxBoostPerSIG = _maxBoostPerSIG;
    }

    /* ========== Internal Function  ========== */

    function _accumulateBoost(address user) internal {}
    /* ========== View Function  ========== */
}
