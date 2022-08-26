// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "hardhat/console.sol";

contract Lottery is Ownable, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;
    VRFCoordinatorV2Interface COORDINATOR;

    //VRF Variables
    //s_subscriptionId is the Id into Chainlink VRF. Associated to a Metamask account
    uint64 s_subscriptionId;
    //Goerli values
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    //numWords = number of random numbers generated. Goes into array s_randomWords
    uint32 numWords =  2;
    uint256[] public s_randomWords;
    uint256 public s_requestId;


   //lottery variables
    address payable[] public players;
    uint lotteryPrice;
    uint lotteryBalance;
    address currentWinner;
    Counters.Counter private lotteryId;


    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;

        lotteryBalance = 0 ether;
        //Lottery Price = 1 ether because it´s easear to coding
        lotteryPrice = 1 ether;
    }

    //VRF funtions
    //We need funds (LINK) into the  s_subscriptionId -> revert
    function requestRandomWords() external onlyOwner {
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
    );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    //Función buy ticket
    //Now -> msg.value = VALUE in Remix
    //Later -> onClick msg.value = XXX ether
    function buyTicket() public payable {
        require(msg.value == lotteryPrice, "To participate, please add the require amount.");
        players.push(payable(msg.sender));
        lotteryBalance = lotteryBalance + lotteryPrice;
    }

    //Función pick the winner:
    //Receives the number of ChainLink, s_randomWords[0], and adapts to number of players
    //0 =<  winner number =< number of players
    function pickTheWinner() public {
        uint index = s_randomWords[0] % players.length;
        console.log (index);
        currentWinner = players[index];
    }


    //GET FUNCTIONS:
    //Contract balance:
    function getContractBalance() public view returns(uint){
    return address(this).balance;
    }

    //Current lottery balance:
    function getLotteryBalance() public view returns(uint) {
        return lotteryBalance;
    }

    //Current winner:
    function getCurrentWinner() public view returns(address) {
        return currentWinner;
    }


}