// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Lottery003 is Ownable {
    using Counters for Counters.Counter;

    address payable[] public players;
    uint bet;
    uint8 maxPlayers;
    bool start;
    uint contractBalance;
    Counters.Counter private lotteryId;

    constructor() {
        bet = 1 ether;
        maxPlayers = 10;
        start = false;
    }


    event lotteryConditions (
        uint8 maxPlayers,
        uint bet
    );

    function setLotteryConditions (uint8 _maxPlayers, uint _bet) public onlyOwner {
        require (players.length == 0, "New lottery already started");
        maxPlayers = _maxPlayers;
        bet = _bet;
        emit lotteryConditions(maxPlayers, bet);
    }

    function makeABet() public payable {
        require(msg.value == bet, "To bet, please add the require amount.");
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public pure returns(uint8) {
        return (8);
    }

    function selectTheWinner() public payable onlyOwner {
        uint index = getRandomNumber() % players.length;
        (bool success, ) = payable(players[index]).call{value: getContractBalance()}("");
        require(success, "failed");

        lotteryId++;

        players = new address payable[](0);
    } 
