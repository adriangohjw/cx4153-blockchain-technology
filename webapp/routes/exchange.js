// Express routers
var express = require('express');
var router = express.Router();

// importing libraries required for metamask and ethereum libraries
var Web3 = require("web3");

// importing a compiled contract artifact which contains function signature etc. to interact
var exchange_artifact = require("../../build/contracts/Exchange.json");

// set true for testnet / false for development
if (true) {
  // testnet
  var infuraWSS = `wss://ropsten.infura.io/ws/v3/6dbaa0a0eed5453ab2d7e585a6ff39b6`;
  var exchangeContractAddress = "0x641Ad5725E9C2AFb7f7936c3E45711E5dc08D3b5";
}
else {
  // development
  var infuraWSS = `ws://localhost:7545`;
  var exchangeContractAddress = "0xB4C0ed7Ad8616c450A688218eaFABE5f0a45Cdf8";
}

// setting up connection for web3
let web3 = new Web3(
  Web3.currentProvider || new Web3.providers.WebsocketProvider(infuraWSS)  // choose infuraWSS (ropsten testnet) / local_WSS (local)
);
const contract = new web3.eth.Contract(exchange_artifact.abi, exchangeContractAddress);  // choose ExchangeContractAddress (ropsten testnet) / local_ExchangeContractAddress (local)

async function getBuyOrderBook(symbolName) {
  var buyOrderBook = await contract.methods.getBuyOrderBook(symbolName).call();
  return {
    indexes: buyOrderBook['0'],
    prices: buyOrderBook['1'],
    amounts: buyOrderBook['2']
  }
}

async function getAccountBuyOrders(symbolName, addr) {
  var buyOrderBook = await contract.methods.getAccountBuyOrders(symbolName).call({ from: addr });
  return {
    indexes: buyOrderBook['0'],
    prices: buyOrderBook['1'],
    amounts: buyOrderBook['2']
  }
}

async function getSellOrderBook(symbolName) {
  var sellOrderBook = await contract.methods.getSellOrderBook(symbolName).call();
  return {
    indexes: sellOrderBook['0'],
    prices: sellOrderBook['1'],
    amounts: sellOrderBook['2']
  }
}

async function getAccountSellOrders(symbolName, addr) {
  var sellOrderBook = await contract.methods.getAccountSellOrders(symbolName).call({ from: addr });
  return {
    indexes: sellOrderBook['0'],
    prices: sellOrderBook['1'],
    amounts: sellOrderBook['2']
  }
}

router.post('/addToken', async function(req, res) {
  try {
    await contract.methods.addToken(req.query.symbolName, req.query.ecr20TokenAddress).send({ from: req.query.addr });
    res.json({
      success: true
    })
  } catch (error) {
    console.log(error);
    return { 
      msg: "Error adding token"
    };
  }
});

router.post('/depositToken', async function(req, res) {
  try {
    await contract.methods.depositToken(req.query.symbolName, req.query.amount).send({ from: req.query.addr, gas: 1000000 });
    var balanceForToken = await contract.methods.getBalanceForToken(req.query.symbolName).call({ from: req.query.addr });
    res.json({
      balanceForToken: balanceForToken
    })
  } 
  catch (error) {
    console.log(error);
    return {
      msg: "Error depositing token"
    }
  }
});

router.post('/withdrawToken', async function(req, res) {
  try {
    await contract.methods.withdrawToken(req.query.symbolName, req.query.amount).send({ from: req.query.addr, gas: 1000000 });
    var balanceForToken = await contract.methods.getBalanceForToken(req.query.symbolName).call({ from: req.query.addr });
    res.json({
      balanceForToken: balanceForToken
    })
  } 
  catch (error) {
    console.log(error);
    return {
      msg: "Error withdrawing token"
    }
  }
});

router.get('/getTokenAddress', async function(req, res) {
  try {
    var tokenAddress = await contract.methods.getTokenAddress(req.query.symbolName).call();
    res.json({
      tokenAddress: tokenAddress
    })
  } catch (error) {
    console.log(error);
    return { 
      msg: "Error retrieving token address"
    };
  }
});

router.post('/withdrawEther', async function(req, res) {
  var etherBalanceInWei = await contract.methods.withdrawEther(req.query.amountInWei).send({ from: req.query.addr });
  res.json({
    etherBalanceInWei: etherBalanceInWei
  })
});

router.get('/getEtherBalanceInWei', async function(req, res) {
  try {
    var etherBalanceInWei = await contract.methods.getEtherBalanceInWei().call({ from: req.query.addr });
    res.json({
      etherBalanceInWei: etherBalanceInWei
    })
  }
  catch (error) {
    console.log(error);
    return { 
      msg: "Error retrieving Ether balance"
    };
  }
});

router.get('/getBalanceForToken', async function(req, res) {
  try {
    var balanceForToken = await contract.methods.getBalanceForToken(req.query.symbolName).call({ from: req.query.addr });
    res.json({
      balanceForToken: balanceForToken
    })
  }
  catch (error) {
    console.log(error);
    return { 
      msg: "Error retrieving token balance"
    };
  }
});

router.get('/hasToken', async function(req, res) {
  try {
    var response = await contract.methods.hasToken(req.query.tokenSymbol).call();
    res.json({
      hasToken: response
    })
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error determining if token exist`
    })
  }
});

router.get('/getAllTokens', async function(req, res) {
  try {
    var response = await contract.methods.getAllTokens().call();

    var tokens = new Array();
    for (var i=0; i < response['0'].length; i++) {
      tokens.push({
        symbolName: response['0'][i],
        address: response['1'][i]
      })
    }
    
    res.json({
      tokens: tokens
    })
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error getting all tokens`
    })
  }
});

router.get('/getBuyOrderBook', async function(req, res) {
  try {
    var response = await getBuyOrderBook(req.query.symbolName);
    res.json(response);
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error retrieving buyOrderBook`
    })
  }
});

router.get('/getAccountBuyOrders', async function(req, res) {
  try {
    var response = await getAccountBuyOrders(req.query.symbolName, req.query.addr);
    res.json(response);
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error retrieving getAccountBuyOrders`
    })
  }
});

router.get('/getSellOrderBook', async function(req, res) {
  try {
    var response = await getSellOrderBook(req.query.symbolName);
    res.json(response);
  }
  catch (error) {
    console.log(error);
    res.json({ 
      msg: `Error retrieving sellOrderBook`
    })
  }
});

router.get('/getAccountSellOrders', async function(req, res) {
  try {
    var response = await getAccountSellOrders(req.query.symbolName, req.query.addr);
    res.json(response);
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error retrieving getAccountSellOrders`
    })
  }
});

router.post('/buyToken', async function(req, res) {
  try {
    await contract.methods.buyToken(req.query.symbolName, req.query.priceInWei, req.query.amount)
                          .send({ from: req.query.addr, gas: 1000000 });
    
    var response = await getBuyOrderBook(req.query.symbolName);
    res.json(response);
  } 
  catch (error) {
    console.log(error);
    res.json({ 
      msg: `Error buying token`
    })
  }
})

router.post('/sellToken', async function(req, res) {
  try {
    await contract.methods.sellToken(req.query.symbolName, req.query.priceInWei, req.query.amount)
                          .send({ from: req.query.addr, gas: 1000000 });

    var response = await getSellOrderBook(req.query.symbolName);
    res.json(response);
  } 
  catch (error) {
    console.log(error);
    res.json({ 
      msg: `Error buying token`
    })
  }
})

router.post('/cancelBuyOrder', async function(req, res) {
  try {
    await contract.methods.cancelBuyOrder(req.query.symbolName, req.query.orderIndex)
                          .send({ from: req.query.addr, gas: 1000000 });

    var response = await getBuyOrderBook(req.query.symbolName);
    res.json(response);
  } catch (error) {
    console.log(error);
    res.json({
      msg: "Error cancelling buy order"
    })
  }
})

router.post('/cancelSellOrder', async function(req, res) {
  try {
    await contract.methods.cancelSellOrder(req.query.symbolName, req.query.orderIndex)
                          .send({ from: req.query.addr, gas: 1000000 });

    var response = await getSellOrderBook(req.query.symbolName);
    res.json(response);
  } catch (error) {
    console.log(error);
    res.json({
      msg: "Error cancelling sell order"
    })
  }
})

module.exports = router;
