// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./owned.sol";

contract Exchange is owned {

	///////////////
	/* STRUCTURE */
	///////////////

	struct Token {

		address contractAddress;
		string symbolName;
		
		mapping (uint => OrderBook) buyOrderBook;
		uint currentBuyPrice;
		uint lowestBuyPrice;
		uint volumnAtCurrentBuyPrice;

		mapping (uint => OrderBook) sellOrderBook;
		uint currentSellPrice;
		uint highestSellPrice;
		uint volumnAtCurrentSellPrice;

  }

	struct Offer {
		
		uint amount;
		address who;

  }

	struct OrderBook {

		mapping (uint => Offer) offers;
		uint lowerPrice;
		uint higherPrice;
		uint offersCount;

  }

  mapping (address => mapping(uint8 => uint)) tokenBalanceForAddress;

  mapping (address => uint) etherBalanceForAddress;

	event LogDepositEther(address accountAddress, uint amount);
	event LogWithdrawEther(address accountAddress, uint amount);

	constructor () public {
		owner = msg.sender;
	}

	/////////////////////
	/* FUNCTIONALITIES */
	/////////////////////

	// Address's Ether account management

  function depositEther() public payable returns (uint totalEtherBalanceInWei) {
		require(getEtherBalanceInWei() + msg.value >= getEtherBalanceInWei());

		etherBalanceForAddress[msg.sender] += msg.value;

		emit LogDepositEther(msg.sender, msg.value);

		return getEtherBalanceInWei();
  }


  function withdrawEther(uint amountInWei) public returns (uint totalEtherBalanceInWei) {
		require(amountInWei <= getEtherBalanceInWei());

		etherBalanceForAddress[msg.sender] -= amountInWei;

		msg.sender.transfer(amountInWei);

		emit LogWithdrawEther(msg.sender, amountInWei);

		return getEtherBalanceInWei();
  }


  function getEtherBalanceInWei() public view returns (uint) {
		return etherBalanceForAddress[msg.sender];
  }


  function depositToken(string memory symbolName, uint amount) public {

  }

  function withdrawToken(string memory symbolName, uint amount) public {

  }

  function getBalanceForToken(string memory symbolName) public view returns (uint) {
		uint balanceForToken;
		return balanceForToken;
  }

  function addToken(string memory symbolName, address EC20TokenAddress) public onlyowner {

  }

  function hasToken(string memory symbolName) public view returns (bool) {
		bool isTokenFound;
		return isTokenFound;
  }

  function getOrderBook(bool isBuy, string memory symbolName) public view returns (uint[] memory, uint[] memory) {
		uint[] memory prices;
		uint[] memory volumn;
		return (prices, volumn);
  }

  function createOrder(bool isBuy, string memory symbolName, uint priceInWei, uint amount) public {

  }

  function cancelOrder(bool isBuy, string memory symbolName, uint offerId) public {
    
  }

} 