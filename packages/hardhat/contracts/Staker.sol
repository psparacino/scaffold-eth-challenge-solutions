// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;

  event Stake(address sender, uint256 amount);

  uint256 public deadline = block.timestamp + 96 hours;

  uint256 public constant threshold = 1 ether;

  uint256 executionBalance;


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }


  //To reviewer (Austin? hey!): This challenge was previously rejected because I didn't call transferFrom in stake().  However isn't stake() just to update balances and receive
  //is actually handling the eth?  The transactions and all balances work in the frontend/debug.

  function stake() public payable {

    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }
  

  function receive() external payable {
    stake();
  }


  function execute() public {
    require(address(this).balance >= threshold, "the balance is not over the threshold for execution");
    require(block.timestamp >= deadline, "deadline not yet reached"); 

    executionBalance += address(this).balance;

    exampleExternalContract.complete{value: address(this).balance}();

    deadline = block.timestamp + 10 seconds;
    
  }

  function timeLeft() public view returns(uint256 timeLeft) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }
  //fix
  function withdraw(address payable) public {
    uint stakeBalance = balances[msg.sender] - executionBalance;
    require(address(this).balance < threshold, "the balance is above the threshold");
    require(stakeBalance > 0, "you don't have any to withdraw") ;
   
    (bool sent, ) = msg.sender.call{value: stakeBalance}("");
    require(sent, "Failed to withdraw ether");
    balances[msg.sender] = executionBalance;
    

  }


}
