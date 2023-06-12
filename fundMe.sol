//get funds from users
//withdraw funds (onlyowner)
//set a minimum funding value in USD

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//deployed @0xD6653d7c7CcD4a73A5cF350c47f95D36b89e5cd4 sepolia

//0x694AA1769357215DE4FAC081bf1f309aDC325306
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe{

    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    address[] public funders;
    address public owner;

    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "didnt send enough ether" );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value; 
    }

    
    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            //reset the balance of each funder
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);

        //withdraw funds
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");

    }

    modifier onlyOwner(){
        require(msg.sender == owner, "you're not him");
        _;
    }

    
} 