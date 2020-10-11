// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./owned.sol";
import "./Token.sol";

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

	mapping(uint8 => Token) tokens;
	uint8 tokenIndex;	

  mapping (address => mapping(uint8 => uint)) tokenBalanceForAddress;

  mapping (address => uint) etherBalanceForAddress;

	constructor () public {
		owner = msg.sender;
		tokenIndex = 1;
	}

	////////////
	/* EVENTS */
	////////////

	event LogDepositEther(address accountAddress, uint amount);
	event LogWithdrawEther(address accountAddress, uint amount);

	event LogDepositToken(string symbolName, address accountAddress, uint amount, uint timestamp);
	event LogWithdrawToken(string symbolName, address accountAddress, uint amount, uint timestamp);
	event LogAddToken(uint tokenIndex, string symbolName, address EC20TokenAddress, uint timestamp);

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


	// Owner's AddToken ability

	function addToken(string memory symbolName, address EC20TokenAddress) public onlyowner {
		require(!hasToken(symbolName));
		require(tokenIndex + 1 >= tokenIndex);

		tokenIndex++;

		tokens[tokenIndex].symbolName = symbolName;
		tokens[tokenIndex].contractAddress = EC20TokenAddress;
		
		emit LogAddToken(tokenIndex, symbolName, EC20TokenAddress, block.timestamp);
  }


	// Address's Tokens account management

  function depositToken(string memory symbolName, uint amount) public returns (uint tokenBalance) {
		require(hasToken(symbolName));
		require(getBalanceForToken(symbolName) + amount >= getBalanceForToken(symbolName));

		tokenIndex = getTokenIndex(symbolName);	
		ERC20Interface token = ERC20Interface(tokens[tokenIndex].contractAddress);

		tokenBalanceForAddress[msg.sender][tokenIndex] += amount;

		emit LogDepositToken(symbolName, msg.sender, amount, block.timestamp);

		return getBalanceForToken(symbolName);
  }


  function withdrawToken(string memory symbolName, uint amount) public returns (uint tokenBalance) {	
		require(hasToken(symbolName));
		require(amount <= getBalanceForToken(symbolName));

		tokenIndex = getTokenIndex(symbolName);	
		ERC20Interface token = ERC20Interface(tokens[tokenIndex].contractAddress);

		tokenBalanceForAddress[msg.sender][tokenIndex] -= amount;

		emit LogWithdrawToken(symbolName, msg.sender, amount, block.timestamp);

		emit consoleLog("hello");
		return 100;
  }
	

  function getBalanceForToken(string memory symbolName) public view returns (uint) {
		return tokenBalanceForAddress[msg.sender][getTokenIndex(symbolName)];
  }


	function hasToken(string memory symbolName) public view returns (bool) {
		return getTokenIndex(symbolName) > 0;
  }


	function getTokenIndex(string memory symbolName) public view returns (uint8) {
		for (uint8 i = 1; i <= tokenIndex; i++) {
			if (keccak256(bytes(symbolName)) == keccak256(bytes(tokens[i].symbolName))) {
				return i;
			}
		}
		return 0;
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