//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract xSIGFarm is Ownable {
    /* ========== STATE VARIABLES ========== */

    IERC20 public xSIG;
    uint256 public boostPerHour;
    uint256 public maxBoostPerSIG;

    uint256 constant HOUR = 3600;

    struct UserInfo {
        uint256 bondedXSIG; // bond 한 xSIG amount
        uint256 receivedVxSIG; // 현재 축적된 vxSIG
        uint256 lastUpdated; // last update
        uint256 startTime; // vxSIG를 축적하기 시작한 시간
    }

    mapping(address => UserInfo) public userInfoOf;

    event Bond(
        uint256 bondAmount,
        uint256 totalBondAmount,
        uint256 totalReceivedVxSIG
    );

    event Unbond(uint256 unbondAmount, uint256 totalBondAmount);

    /* ========== External Function  ========== */
    function bond(uint256 _amount) external {
        require(_amount > 0, "Bond amount should be bigger than 0");
        xSIG.transferFrom(msg.sender, address(this), _amount);

        UserInfo storage userInfo = userInfoOf[msg.sender];
        if (userInfo.bondedXSIG == 0) {
            userInfo.bondedXSIG = _amount;
            userInfo.receivedVxSIG = 0;
            userInfo.startTime = block.timestamp;
            userInfo.lastUpdated = block.timestamp;
        } else {
            _accumulateBoost(userInfo);
            userInfo.bondedXSIG += _amount;
        }

        emit Bond(_amount, userInfo.bondedXSIG, userInfo.receivedVxSIG);
    }

    function unbond(uint256 _amount) external {
        require(_amount > 0, "Unbond amount should be bigger than 0");
        UserInfo storage userInfo = userInfoOf[msg.sender];
        require(userInfo.bondedXSIG > 0, "There is no xSIG to unbond.");
        require(userInfo.bondedXSIG > _amount, "Insuffcient xSIG to unbond");

        //UserInfo set again.
        userInfo.bondedXSIG -= _amount;
        userInfo.receivedVxSIG = 0; //vxSIG resetted if any unbond happens;

        if (userInfo.bondedXSIG == 0) {
            //reset userInfo
            userInfo.startTime = 0;
            userInfo.lastUpdated = 0;
        } else {
            userInfo.startTime = block.timestamp;
            userInfo.lastUpdated = block.timestamp;
        }

        //TODO: If there has been a vote on SigmaVoter, it should be resetted.

        xSIG.transfer(msg.sender, _amount);

        emit Unbond(_amount, userInfo.bondedXSIG);
    }

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

    /**
        @notice Lazy update user info storage. It is called when user 'bond'
        @param userInfo userInfo
     */
    function _accumulateBoost(UserInfo storage userInfo) internal {
        if (userInfo.bondedXSIG > 0 && block.timestamp > userInfo.lastUpdated) {
            uint256 newBoost = userInfo.bondedXSIG *
                boostPerHour *
                (((block.timestamp - userInfo.lastUpdated) * 1e18) / HOUR);
            newBoost /= 1e18;
            uint256 maxBoost = userInfo.bondedXSIG * maxBoostPerSIG;

            if (newBoost + userInfo.receivedVxSIG > maxBoost) {
                userInfo.receivedVxSIG = maxBoost;
            } else {
                userInfo.receivedVxSIG = userInfo.receivedVxSIG + newBoost;
            }
            userInfo.lastUpdated = block.timestamp;
        }
    }

    /* ========== View Function  ========== */

    /**
        @notice Calculate user's current boost. This is not the same value with current storage 
        @param _user address of the user
        @return currentReceivableVxSIG current boost amount of the user
        @return bondedXSIG total bonded xSIG of the user
        @return startTime start time of the vxSIG farming.
     */
    function getUserCurrentInfo(address _user)
        external
        view
        returns (
            uint256 currentReceivableVxSIG,
            uint256 bondedXSIG,
            uint256 startTime
        )
    {
        UserInfo memory userInfo = userInfoOf[_user];
        if (userInfo.bondedXSIG > 0 && block.timestamp > userInfo.lastUpdated) {
            uint256 newBoost = userInfo.bondedXSIG *
                boostPerHour *
                (((block.timestamp - userInfo.lastUpdated) * 1e18) / HOUR);
            newBoost /= 1e18;
            uint256 maxBoost = userInfo.bondedXSIG * maxBoostPerSIG;

            if (newBoost + userInfo.receivedVxSIG > maxBoost) {
                return (maxBoost, userInfo.bondedXSIG, userInfo.startTime);
            } else {
                return (
                    userInfo.receivedVxSIG + newBoost,
                    userInfo.bondedXSIG,
                    userInfo.startTime
                );
            }
        } else {
            return (0, 0, 0);
        }
    }
}
