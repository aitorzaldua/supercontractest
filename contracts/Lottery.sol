// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";



contract Lottery is Ownable, VRFConsumerBase {
    using Counters for Counters.Counter;

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    address payable[] public players;
    uint bet;
    uint8 maxPlayers;
    bool start;
    uint contractBalance;
    uint8 winNumber;
    Counters.Counter private lotteryId;

    event lotteryHistory (
        Counters.Counter lotteryId,
        uint winNumber,
        address winner
    );

constructor()
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        )
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18;
        bet = 1 ether;
        maxPlayers = 10;
        start = false;

    }


    event lotteryConditions (
        uint8 maxPlayers,
        uint bet
    );

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        selectTheWinner();
    }

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

    function selectTheWinner() public payable onlyOwner {
        uint index = randomResult % players.length;
        (bool success, ) = payable(players[index]).call{value: getContractBalance()}("");
        require(success, "failed");

        emit lotteryHistory(lotteryId, index, players[index]);

        lotteryId.increment();
        players = new address payable[](0);
 
    } 

    function getContractBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getId() public view onlyOwner returns (Counters.Counter memory) {
        return lotteryId;
    }

}