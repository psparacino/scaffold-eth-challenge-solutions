// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


import '@openzeppelin/contracts/access/Ownable.sol' ;
import "./YourToken.sol";

contract Vendor is Ownable {
  // token contract
  YourToken yourToken;

  // token price
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }


  function buyTokens() public payable returns(uint tokensBought) {
    require(msg.value > 0, "send actual eth to buy actual tokens ya big mug");

    uint amount = msg.value * tokensPerEth;
    uint tokenBankBalance = yourToken.balanceOf(address(this));
    
    require(tokenBankBalance > 0, "not enough tokens to buy");
    (bool sent) = yourToken.transfer(msg.sender, amount);

    require(sent, "failed to send ether");

    emit BuyTokens(msg.sender, msg.value, amount);
    
    return tokensBought;
  }


    function withdraw(uint amountInWei) public onlyOwner {
      uint tokenBalance = address(this).balance;
      require(address(this).balance > 0, "no balance to withdraw"); 
      (bool sent, ) = msg.sender.call{value: amountInWei}("");
      require(sent, "Failed to send Ether");
  }


    function sellTokens(uint tokensToSell) public onlyOwner returns(uint tokensRemaining) {
      require( tokensToSell > 0, "enter an amount of tokens greater than zero");

      //verify user token balance
      uint userBalance = yourToken.balanceOf(msg.sender);
      require(userBalance >= tokensToSell, "you don't have that many tokens to sell");


      //approve transfer. taken care of in frontend
      //(bool approved) = yourToken.approve(msg.sender, tokensToSell); 
      //require(approved, "approval failed"); 
      //frontend required an extra useEffect to get the approve to update to sell after the approval passed

      uint ethToTransfer = tokensToSell / tokensPerEth;
      uint vendorBalance = address(this).balance;
      require(vendorBalance >= ethToTransfer, "vendor doesn't have enough Eth to purchase tokens");

      (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokensToSell);
      require(sent, "token transfer failed");
      
      (bool success, ) = msg.sender.call{value: ethToTransfer}("");
      require(success, "Sell function failed");

      emit SellTokens(msg.sender, ethToTransfer, tokensToSell);
      
    }

  //change here for reus
}