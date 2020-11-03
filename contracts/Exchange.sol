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
	event LogCreateSellOrder(string symbolName, uint priceInWei, uint amount, address seller, uint timestamp);

	event LogFulfilBuyOrder(string symbolName, uint orderIndex, uint priceInWei, uint amount, uint timestamp);
	event LogFulfilSellOrder(string symbolName, uint orderIndex, uint priceInWei, uint amount, uint timestamp);

	event LogCancelBuyOrder(string symbolName, uint orderIndex, address buyer, uint timestamp);
	event LogCancelSellOrder(string symbolName, uint orderIndex, address seller, uint timestamp);

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

		uint8 _tokenIndex = getTokenIndex(symbolName);	

		ERC20Interface token = ERC20Interface(tokens[_tokenIndex].contractAddress);
		require(token.transferFrom(msg.sender, address(this), amount) == true);

		tokenBalanceForAddress[msg.sender][_tokenIndex] += amount;

		emit LogDepositToken(symbolName, msg.sender, amount, block.timestamp);

		return getBalanceForToken(symbolName);
  }


  function withdrawToken(string memory symbolName, uint amount) public returns (uint tokenBalance) {	
		require(hasToken(symbolName));
		require(amount <= getBalanceForToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);
		
		ERC20Interface token = ERC20Interface(tokens[_tokenIndex].contractAddress);

		tokenBalanceForAddress[msg.sender][_tokenIndex] -= amount;

		require(token.transfer(msg.sender, amount) == true);

		emit LogWithdrawToken(symbolName, msg.sender, amount, block.timestamp);

		return getBalanceForToken(symbolName);
  }
	

  function getBalanceForToken(string memory symbolName) public view returns (uint) {
		return tokenBalanceForAddress[msg.sender][getTokenIndex(symbolName)];
  }


	function getTokenAddress(string memory symbolName) public view returns (address) {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);	

		return tokens[_tokenIndex].contractAddress;
	}


	function hasToken(string memory symbolName) public view returns (bool) {
		return getTokenIndex(symbolName) > 0;
  }

	
	function getAllTokens() public view returns (string[] memory, address[] memory) {
		string[] memory symbolNames = new string[](tokenIndex-1);
		address[] memory addresses = new address[](tokenIndex-1);

		for (uint8 i = 2; i <= tokenIndex; i++) {
			symbolNames[i-2] = tokens[i].symbolName;
			addresses[i-2] = tokens[i].contractAddress;
		}

		return (symbolNames, addresses);
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

	
	function getAccountBuyOrders(string memory symbolName) public view returns (uint[] memory, uint[] memory, uint[] memory) {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		(uint[] memory indexes, uint[] memory prices, uint[] memory amounts) = getBuyOrderBook(symbolName);
		uint _accountOrdersCount = 0;

		uint[] memory _tempIndexes = new uint[](tokens[_tokenIndex].buyOrderBook.ordersCount);

		for (uint i = 0; i < tokens[_tokenIndex].buyOrderBook.ordersCount; i++) {
			uint _orderIndex = indexes[i];
			if (tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].who == msg.sender) {
				_tempIndexes[_accountOrdersCount] = _orderIndex;
				_accountOrdersCount++;
			}
		}

		uint[] memory _accountIndexes = new uint[](_accountOrdersCount);
		uint[] memory _accountPrices = new uint[](_accountOrdersCount);
		uint[] memory _accountAmounts = new uint[](_accountOrdersCount);

		for (uint j = 0; j < _accountOrdersCount; j++) {
			_accountIndexes[j] = _tempIndexes[j];
			_accountPrices[j] = tokens[_tokenIndex].buyOrderBook.orders[_tempIndexes[j]].price;
			_accountAmounts[j] = tokens[_tokenIndex].buyOrderBook.orders[_tempIndexes[j]].amount;
		}

		return (_accountIndexes, _accountPrices, _accountAmounts);
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


	function getAccountSellOrders(string memory symbolName) public view returns (uint[] memory, uint[] memory, uint[] memory) {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		(uint[] memory indexes, uint[] memory prices, uint[] memory amounts) = getSellOrderBook(symbolName);
		uint _accountOrdersCount = 0;

		uint[] memory _tempIndexes = new uint[](tokens[_tokenIndex].sellOrderBook.ordersCount);

		for (uint i = 0; i < tokens[_tokenIndex].sellOrderBook.ordersCount; i++) {
			uint _orderIndex = indexes[i];
			if (tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].who == msg.sender) {
				_tempIndexes[_accountOrdersCount] = _orderIndex;
				_accountOrdersCount++;
			}
		}

		uint[] memory _accountIndexes = new uint[](_accountOrdersCount);
		uint[] memory _accountPrices = new uint[](_accountOrdersCount);
		uint[] memory _accountAmounts = new uint[](_accountOrdersCount);

		for (uint j = 0; j < _accountOrdersCount; j++) {
			_accountIndexes[j] = _tempIndexes[j];
			_accountPrices[j] = tokens[_tokenIndex].sellOrderBook.orders[_tempIndexes[j]].price;
			_accountAmounts[j] = tokens[_tokenIndex].sellOrderBook.orders[_tempIndexes[j]].amount;
		}

		return (_accountIndexes, _accountPrices, _accountAmounts);
	}


	// Create orders (buy / sell)

	function createBuyOrder(string memory symbolName, uint priceInWei, uint amount, address buyer) private {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		uint _buy_amount_balance = amount;

		// fulfil buyOrder by checking against which sell orders can be fulfil
		if (tokens[_tokenIndex].sellOrderBook.ordersCount > 0) {
			_buy_amount_balance = fulfilBuyOrder(symbolName, _buy_amount_balance, priceInWei);
		} 
	
		// check if buyOrder is fully fulfiled
		if (_buy_amount_balance > 0) {
			// update buyOrderBook - ordersQueue
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
				Order({ price: priceInWei, amount: _buy_amount_balance, who: msg.sender });
			
			// fire event
			emit LogCreateBuyOrder(symbolName, priceInWei, _buy_amount_balance, buyer, block.timestamp);
		}
	}


	function fulfilBuyOrder(string memory symbolName, uint _buy_amount_balance, uint priceInWei) private returns (uint) {
		uint8 _tokenIndex = getTokenIndex(symbolName);
		uint _currSellOrdersCount = tokens[_tokenIndex].sellOrderBook.ordersCount;

		uint _countSellOrderFulfiled = 0;

		// update sellOrderBook - orders
		for (uint i = 0; i < _currSellOrdersCount; i++) {
			if (_buy_amount_balance == 0) break;

			uint _orderIndex = tokens[_tokenIndex].sellOrderBook.ordersQueue[i];
			uint _orderPrice = tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].price;
			uint _orderAmount = tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].amount;
			address _orderOwner = tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].who;

			if (priceInWei < _orderPrice) break;

			if (_buy_amount_balance >= _orderAmount) {
				_buy_amount_balance -= _orderAmount;
				
				tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].amount = 0;
				_countSellOrderFulfiled++;
				emit LogFulfilSellOrder(symbolName, _orderIndex, priceInWei, _orderAmount, block.timestamp);

				etherBalanceForAddress[_orderOwner] += priceInWei * _orderAmount;
				tokenBalanceForAddress[msg.sender][_tokenIndex] += _orderAmount;
			}
			else {
				tokens[_tokenIndex].sellOrderBook.orders[_orderIndex].amount -= _buy_amount_balance;
				emit LogFulfilSellOrder(symbolName, _orderIndex, priceInWei, _buy_amount_balance, block.timestamp);

				etherBalanceForAddress[_orderOwner] += priceInWei * _buy_amount_balance;
				tokenBalanceForAddress[msg.sender][_tokenIndex] += _buy_amount_balance;

				_buy_amount_balance = 0;
			}
		}

		// update sellOrderBook - ordersBook and ordersCount
		uint _newSellOrdersCount = _currSellOrdersCount - _countSellOrderFulfiled;

		uint[] memory _newSellOrdersQueue = new uint[](_newSellOrdersCount);
		for (uint i = 0; i < _newSellOrdersCount; i++) {
			_newSellOrdersQueue[i] = tokens[_tokenIndex].sellOrderBook.ordersQueue[i + _countSellOrderFulfiled];
		}

		tokens[_tokenIndex].sellOrderBook.ordersCount = _newSellOrdersCount;
		tokens[_tokenIndex].sellOrderBook.ordersQueue = _newSellOrdersQueue;

		return _buy_amount_balance;
	}


	function createSellOrder(string memory symbolName, uint priceInWei, uint amount, address seller) private {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		uint _sell_amount_balance = amount;

		// fulfil sellOrder by checking against which buy orders can be fulfil
		if (tokens[_tokenIndex].buyOrderBook.ordersCount > 0) {
			_sell_amount_balance = fulfilSellOrder(symbolName, _sell_amount_balance, priceInWei);
		} 

		// check if buyOrder is fully fulfiled
		if (_sell_amount_balance > 0) {
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
	}


	function fulfilSellOrder(string memory symbolName, uint _sell_amount_balance, uint priceInWei) private returns (uint) {
		uint8 _tokenIndex = getTokenIndex(symbolName);
		uint _currBuyOrdersCount = tokens[_tokenIndex].buyOrderBook.ordersCount;

		uint _countBuyOrderFulfiled = 0;

		// update buyOrderBook - orders
		for (uint i = 0; i < _currBuyOrdersCount; i++) {
			if (_sell_amount_balance == 0) break;

			uint _orderIndex = tokens[_tokenIndex].buyOrderBook.ordersQueue[i];
			uint _orderPrice = tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].price;
			uint _orderAmount = tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].amount;
			address _orderOwner = tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].who;

			if (priceInWei > _orderPrice) break;

			if (_sell_amount_balance >= _orderAmount) {
				_sell_amount_balance -= _orderAmount;
				
				tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].amount = 0;
				_countBuyOrderFulfiled++;
				emit LogFulfilBuyOrder(symbolName, _orderIndex, priceInWei, _orderAmount, block.timestamp);

				tokenBalanceForAddress[_orderOwner][_tokenIndex] += _orderAmount;
				etherBalanceForAddress[msg.sender] += priceInWei * _orderAmount;
			}
			else {
				tokens[_tokenIndex].buyOrderBook.orders[_orderIndex].amount -= _sell_amount_balance;
				emit LogFulfilBuyOrder(symbolName, _orderIndex, priceInWei, _sell_amount_balance, block.timestamp);

				tokenBalanceForAddress[_orderOwner][_tokenIndex] += _sell_amount_balance;
				etherBalanceForAddress[msg.sender] += priceInWei * _sell_amount_balance;

				_sell_amount_balance = 0;
			}
		}

		// update buyOrderBook - ordersBook and ordersCount
		uint _newBuyOrdersCount = _currBuyOrdersCount - _countBuyOrderFulfiled;

		uint[] memory _newBuyOrdersQueue = new uint[](_newBuyOrdersCount);
		for (uint i = 0; i < _newBuyOrdersCount; i++) {
			_newBuyOrdersQueue[i] = tokens[_tokenIndex].buyOrderBook.ordersQueue[i + _countBuyOrderFulfiled];
		}

		tokens[_tokenIndex].buyOrderBook.ordersCount = _newBuyOrdersCount;
		tokens[_tokenIndex].buyOrderBook.ordersQueue = _newBuyOrdersQueue;

		return _sell_amount_balance;
	}


	// Buy / Sell token
	
	function buyToken(string memory symbolName, uint priceInWei, uint amount) public {
		require(hasToken(symbolName));
		require(priceInWei > 0);
		require(amount > 0);
		
		uint total_ether_needed = priceInWei * amount;
		require(total_ether_needed <= getEtherBalanceInWei());
		etherBalanceForAddress[msg.sender] -= total_ether_needed;

		createBuyOrder(symbolName, priceInWei, amount, msg.sender);
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
	}


  function cancelBuyOrder(string memory symbolName, uint orderIndex) public {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		require(tokens[_tokenIndex].buyOrderBook.ordersCount > 0);

		// Check order is in OrderBook
		// Create new orderQueue
		bool _isOrderInBook = false;
		uint _newOrderQueueIndex = 0;
		uint[] memory _newOrdersQueue = new uint[](tokens[_tokenIndex].buyOrderBook.ordersCount - 1);
		uint _priceInWei;
		uint _amount;
		
		for (uint _orderQueueIndex = 0; _orderQueueIndex < tokens[_tokenIndex].buyOrderBook.ordersCount; _orderQueueIndex++) {
			if (orderIndex == tokens[_tokenIndex].buyOrderBook.ordersQueue[_orderQueueIndex]) {
				_isOrderInBook = true;
				_priceInWei = tokens[_tokenIndex].buyOrderBook.orders[orderIndex].price;
				_amount = tokens[_tokenIndex].buyOrderBook.orders[orderIndex].amount;
			} else {
				_newOrdersQueue[_newOrderQueueIndex] = tokens[_tokenIndex].buyOrderBook.ordersQueue[_orderQueueIndex];
				_newOrderQueueIndex++;
			}
		}
		require(_isOrderInBook);		

		// Update OrderBook and OrderQueue
		tokens[_tokenIndex].buyOrderBook.ordersCount--;
		tokens[_tokenIndex].buyOrderBook.ordersQueue = _newOrdersQueue;

		// refund ether balance back to user's account
		etherBalanceForAddress[msg.sender] += _priceInWei * _amount;

		emit LogCancelBuyOrder(symbolName, orderIndex, msg.sender, block.timestamp);
  }

	function cancelSellOrder(string memory symbolName, uint orderIndex) public {
		require(hasToken(symbolName));

		uint8 _tokenIndex = getTokenIndex(symbolName);

		require(tokens[_tokenIndex].sellOrderBook.ordersCount > 0);

		// Check order is in OrderBook
		// Create new orderQueue
		bool _isOrderInBook = false;
		uint _newOrderQueueIndex = 0;
		uint[] memory _newOrdersQueue = new uint[](tokens[_tokenIndex].sellOrderBook.ordersCount - 1);
		uint _amount;
		
		for (uint _orderQueueIndex = 0; _orderQueueIndex < tokens[_tokenIndex].sellOrderBook.ordersCount; _orderQueueIndex++) {
			if (orderIndex == tokens[_tokenIndex].sellOrderBook.ordersQueue[_orderQueueIndex]) {
				_isOrderInBook = true;
				_amount = tokens[_tokenIndex].sellOrderBook.orders[orderIndex].amount;
			} else {
				_newOrdersQueue[_newOrderQueueIndex] = tokens[_tokenIndex].sellOrderBook.ordersQueue[_orderQueueIndex];
				_newOrderQueueIndex++;
			}
		}
		require(_isOrderInBook);		

		// Update OrderBook and OrderQueue
		tokens[_tokenIndex].sellOrderBook.ordersCount--;
		tokens[_tokenIndex].sellOrderBook.ordersQueue = _newOrdersQueue;

		// refund token balance back to user's account
		tokenBalanceForAddress[msg.sender][_tokenIndex] += _amount;

		emit LogCancelSellOrder(symbolName, orderIndex, msg.sender, block.timestamp);
  }

} 