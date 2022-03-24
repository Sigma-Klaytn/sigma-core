//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IVault.sol";
import "./MockERC20.sol";


contract DepositingVault is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

   
    constructor() {
    
    }

    event MINT_TOKEN(uint amount);
    event LOCKED_TOKEN(uint id, uint amount, uint256 unlockTimestamp);
    event Withdraw(uint256 id);



    function mintERC20Token(address _token,uint _amount)  external returns (uint256) {
        MockERC20(_token).mint(_amount);
        emit MINT_TOKEN(_amount);
        return MockERC20(_token).balanceOf(address(this));
    }

    function lockTokens(address _vault, address _token, address _withdrawer, uint256 _amount,uint256 _unlockTimestamp) external{
       uint256 id = IVault(_vault).lockTokens(IERC20(_token), _withdrawer, _amount, _unlockTimestamp);
       emit LOCKED_TOKEN(id, _amount, _unlockTimestamp);
     }
     
    function approveToken(address _token, address to, uint _amount) external {
        IERC20(_token).approve(to, _amount);
    }



    function getVaultsByWithdrawer(address _vault,address _withdrawer) view external returns (uint256[] memory){
       uint256[] memory ids = IVault(_vault).getVaultsByWithdrawer(_withdrawer);
       return ids;
    }

    function withdrawTokens(address _vault,uint256 _id) external{
            IVault(_vault).withdrawTokens(_id);
            emit Withdraw(_id);
            
    }
}


