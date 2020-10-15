// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma experimental ABIEncoderV2;

import "./owned.sol";
import "./Token.sol";

contract Exchange is owned {

	///////////////
	/* STRUCTURE */
	///////////////

	struct Token {

		address contractAddress;
		string symbolName;

		OrderBook buyOrderBook;
		OrderBook sellOrderBook;

  }

	struct Order {
		
		uint price;
		uint amount;
		address who;

  }

	struct OrderBook {

		uint orderIndex;
		mapping (uint => Order) orders;		

		uint ordersCount;
		uint[] ordersQueue;

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

	event LogBuyToken(string symbolName, uint priceInWei, uint amount, address buyer, uint timestamp);
	event LogSellToken(string symbolName, uint priceInWei, uint amount, address buyer, uint timestamp);

	event LogCreateBuyOrder(string symbolName, uint priceInWei, uint amount, address buyer, uint timestamp);
	event LogCreateSellOrder(string symbolName, uint priceInWei, uint amount, address buyer, uint timestamp);

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


	// Get order books

	function getBuyOrderBook(string memory symbolName) public view returns (uint[] memory, uint[] memory, uint[] memory) {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);
		
		uint[] memory indexes = new uint[](tokens[_tokenIndex].buyOrderBook.ordersCount);
		uint[] memory prices = new uint[](tokens[_tokenIndex].buyOrderBook.ordersCount);
		uint[] memory amounts = new uint[](tokens[_tokenIndex].buyOrderBook.ordersCount);

		for (uint i = 1; i <= tokens[_tokenIndex].buyOrderBook.ordersCount; i++) {				
			Order memory _order = tokens[_tokenIndex].buyOrderBook.orders[tokens[_tokenIndex].buyOrderBook.ordersQueue[i-1]];
			indexes[i-1] = tokens[_tokenIndex].buyOrderBook.ordersQueue[i-1];
			prices[i-1] = _order.price;
			amounts[i-1] = _order.amount;
		}

		return (indexes, prices, amounts);
	}


	function getSellOrderBook(string memory symbolName) public view returns (uint[] memory, uint[] memory, uint[] memory) {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);
		
		uint[] memory indexes = new uint[](tokens[_tokenIndex].sellOrderBook.ordersCount);
		uint[] memory prices = new uint[](tokens[_tokenIndex].sellOrderBook.ordersCount);
		uint[] memory amounts = new uint[](tokens[_tokenIndex].sellOrderBook.ordersCount);

		for (uint i = 1; i <= tokens[_tokenIndex].sellOrderBook.ordersCount; i++) {				
			Order memory _order = tokens[_tokenIndex].sellOrderBook.orders[tokens[_tokenIndex].sellOrderBook.ordersQueue[i-1]];
			indexes[i-1] = tokens[_tokenIndex].sellOrderBook.ordersQueue[i-1];
			prices[i-1] = _order.price;
			amounts[i-1] = _order.amount;
		}
		
		return (indexes, prices, amounts);
  }


	// Create orders (buy / sell)

	function createBuyOrder(string memory symbolName, uint priceInWei, uint amount, address buyer) private {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);
	
		// Update ordersQueue of OrderBook
		(uint[] memory indexes, uint[] memory prices, uint[] memory amounts) = getBuyOrderBook(symbolName);
		uint _newOrderIndex = ++tokens[_tokenIndex].buyOrderBook.orderIndex;
		uint[] memory _newOrdersQueue = new uint[](_newOrderIndex);
		
		bool _isOrderAdded = false;
		if (tokens[_tokenIndex].buyOrderBook.ordersCount == 0) {
			_newOrdersQueue[0] = _newOrderIndex;
			_isOrderAdded = true;
		}
		else {
			uint _newOrdersQueueIndex = 0;
			for (uint _counter = 0; _counter < tokens[_tokenIndex].buyOrderBook.ordersCount; _counter++) {
				if (!_isOrderAdded && priceInWei > prices[_counter]) {
					_newOrdersQueue[_newOrdersQueueIndex++] = _newOrderIndex;
					_isOrderAdded = true;
				}
				_newOrdersQueue[_newOrdersQueueIndex++] = tokens[_tokenIndex].buyOrderBook.ordersQueue[_counter];
			}
			// for the case of the price being lower than the lowest price of the orderbook
			if (!_isOrderAdded) {
			    _newOrdersQueue[_newOrdersQueueIndex] = _newOrderIndex;
			}
		}

		// replace existing orders queue is it's not empty
		tokens[_tokenIndex].buyOrderBook.ordersQueue = _newOrdersQueue;
		
		// Add new order to OrderBook
		tokens[_tokenIndex].buyOrderBook.ordersCount++;
		tokens[_tokenIndex].buyOrderBook.orders[_newOrderIndex] = 
			Order({ price: priceInWei, amount: amount, who: msg.sender });
		
		// fire event
		emit LogCreateBuyOrder(symbolName, priceInWei, amount, buyer, block.timestamp);
	}


	function createSellOrder(string memory symbolName, uint priceInWei, uint amount, address seller) private {
			require(hasToken(symbolName));

			uint8 _tokenIndex = getTokenIndex(symbolName);
		
			// Update ordersQueue of OrderBook
			(uint[] memory indexes, uint[] memory prices, uint[] memory amounts) = getSellOrderBook(symbolName);
			uint _newOrderIndex = ++tokens[_tokenIndex].sellOrderBook.orderIndex;
			uint[] memory _newOrdersQueue = new uint[](_newOrderIndex);
			
			bool _isOrderAdded = false;
			if (tokens[_tokenIndex].sellOrderBook.ordersCount == 0) {
				_newOrdersQueue[0] = _newOrderIndex;
				_isOrderAdded = true;
			}
			else {
				uint _newOrdersQueueIndex = 0;
				for (uint _counter = 0; _counter < tokens[_tokenIndex].sellOrderBook.ordersCount; _counter++) {
					if (!_isOrderAdded && priceInWei < prices[_counter]) {
						_newOrdersQueue[_newOrdersQueueIndex++] = _newOrderIndex;
						_isOrderAdded = true;
					}
					_newOrdersQueue[_newOrdersQueueIndex++] = tokens[_tokenIndex].sellOrderBook.ordersQueue[_counter];
				}
				// for the case of the price being lower than the lowest price of the orderbook
				if (!_isOrderAdded) {
						_newOrdersQueue[_newOrdersQueueIndex] = _newOrderIndex;
				} 
			}

			// replace existing orders queue is it's not empty
			tokens[_tokenIndex].sellOrderBook.ordersQueue = _newOrdersQueue;
			
			// Add new order to OrderBook
			tokens[_tokenIndex].sellOrderBook.ordersCount++;
			tokens[_tokenIndex].sellOrderBook.orders[_newOrderIndex] = 
				Order({ price: priceInWei, amount: amount, who: msg.sender });
			
			// fire event
			emit LogCreateSellOrder(symbolName, priceInWei, amount, seller, block.timestamp);
		}


	// Buy / Sell token
	
	function buyToken(string memory symbolName, uint priceInWei, uint amount) public {
		require(hasToken(symbolName));
		require(priceInWei > 0);
		require(amount > 0);

		uint8 _tokenIndex = getTokenIndex(symbolName);
		
		uint total_ether_needed = priceInWei * amount;
		require(total_ether_needed <= getEtherBalanceInWei());
		etherBalanceForAddress[msg.sender] -= total_ether_needed;

		createBuyOrder(symbolName, priceInWei, amount, msg.sender);

		/*
		TODO: Process the buyOrder (to be done after sellToken is implemented)
		*/
	}


	function sellToken(string memory symbolName, uint priceInWei, uint amount) public {
		require(hasToken(symbolName));
		require(priceInWei > 0);
		require(amount > 0);

		uint8 _tokenIndex = getTokenIndex(symbolName);
		
		uint total_token_available = tokenBalanceForAddress[msg.sender][_tokenIndex];
		require(amount <= total_token_available);
		tokenBalanceForAddress[msg.sender][_tokenIndex] -= amount;

		createSellOrder(symbolName, priceInWei, amount, msg.sender);

		/*
		TODO: Process the buyOrder
		*/
	}


  function cancelOrder(bool isBuy, string memory symbolName, uint offerId) public {
    
  }

} 