// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
     constructor() public ERC20("LeprechaunGold", "LeGold") {
        _mint(msg.sender, 2000 * 10 ** 18);

        //change for reusesdfgs
    }
}