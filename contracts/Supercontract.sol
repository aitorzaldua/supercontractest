// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";


contract SuperContract {

    address public owner;
    uint256 public counter;

    constructor() {
        owner = msg.sender;
        counter = 0;
        console.log("Checking the contract. Owner is: ", owner);
        console.log("Initial value of the counter: ", counter);
        increase();
    }

    function increase() public {
        counter += 1;
        console.log("User", msg.sender, "just increase the counter. New value = ", counter);
    }

}