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


	/////////////////////
	/* FUNCTIONALITIES */
	/////////////////////

  function depositEther() public payable {
		
  }

  function withdrawEther(uint amountInWei) public {

  }

  function getEtherBalanceInWei() public view returns (uint) {
		uint balanceInWei;
		return balanceInWei;
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