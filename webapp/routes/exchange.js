// Express routers
var express = require('express');
var router = express.Router();

// importing libraries required for metamask and ethereum libraries
var Web3 = require("web3");

// importing a compiled contract artifact which contains function signature etc. to interact
var exchange_artifact = require("../../build/contracts/Exchange.json");
var token_artifact = require("../../build/contracts/Token.json");

// infura endpoint
const infuraWSS = `wss://ropsten.infura.io/ws/v3/5a68d74b5a074d7ab6834c50c65773b9`; // To change to your own infura endpoint
const local_WSS = `ws://localhost:7545`;

// contract owner's address
const OwnerAddress = "0xfC4E8AFeF7AD2a37DF8Ad0C3Ce038E4196501Fbe"; // To change to your own testnet wallet address
const local_OwnerAddress = "0xc97f9e2a6469190894e403e7ea5e3620bfa790fd"; // To change to your own local wallet address

// contract address
const ExchangeContractAddress = "0x1420180D527adfDcb7c17C8eA3a39C6b53b573Ab"; // To change to your own testnet contract address
const local_ExchangeContractAddress = "0xE39726aD7Ad1079560EAE85085D408ade7407BBd"; // To change to your own local contract address

// testnet that contract is deployed on
const Testnet = "ropsten";

// setting up connection for web3
let web3 = new Web3(
  Web3.currentProvider || new Web3.providers.WebsocketProvider(local_WSS)  // choose infuraWSS (ropsten testnet) / local_WSS (local)
);
const contract = new web3.eth.Contract(exchange_artifact.abi, local_ExchangeContractAddress);  // choose ExchangeContractAddress (ropsten testnet) / local_ExchangeContractAddress (local)

// Exchange Contract - getBalanceForToken
async function getBalanceForToken(addr, symbolName) {
  try {
    const balanceForToken = await contract.methods.getBalanceForToken(symbolName).call({ from: addr });
    return { 
      address: addr, 
      balance: balanceForToken
    };
  } catch (error) {
    console.log(error);
    return { 
      msg: "Error retrieving token balance"
    };
  }
}

// Exchange Contract - hasToken
async function hasToken(symbolName) {
  try {
    let isHasToken = await contract.methods.hasToken(symbolName).call();
    return isHasToken;
  }
  catch (error) {
    console.log(error);
    return false;
  }
}

// Exchange Contract - getEtherBalanceInWei()
async function getEtherBalanceInWei(addr) {
  try {
    const etherBalanceInWei = await contract.methods.getEtherBalanceInWei().call({ from: addr });
    return { 
      address: addr, 
      balance: etherBalanceInWei
    };
  } 
  catch (error) {
    console.log(error);
    return { 
      msg: "Error retrieving Ether balance"
    };
  }
}

// Exchange Contract - getBuyOrderBook
async function getBuyOrderBook(symbolName) {
  try {
    const orderBook = await contract.methods.getBuyOrderBook(symbolName).call();
    return { 
      is_success: true,
      indexes: orderBook['0'],
      prices: orderBook['1'],
      amounts: orderBook['2']
    };
  } 
  catch (error) {
    console.log(error);
    return { 
      is_success: false,
      msg: `Error retrieving orderBook for ${symbolName}`
    };
  }
}

// Exchange Contract - getSellOrderBook
async function getSellOrderBook(symbolName) {
  try {
    const orderBook = await contract.methods.getSellOrderBook(symbolName).call();
    return { 
      is_success: true,
      indexes: orderBook['0'],
      prices: orderBook['1'],
      amounts: orderBook['2']
    };
  } 
  catch (error) {
    console.log(error);
    return { 
      is_success: false,
      msg: `Error retrieving orderBook for ${symbolName}`
    };
  }
}

router.get('/getBalanceForToken', async function(req, res) {
  response = await getBalanceForToken(req.query.addr, req.query.symbolName);
  res.json({
    balanceForToken: response.balance
  })
});

router.get('/hasToken', async function(req, res) {
  response = await hasToken(req.query.tokenSymbol);
  res.json({
    hasToken: response
  })
});

router.get('/getEtherBalanceInWei', async function(req, res) {
  if (req.query.addr) {
    response = await getEtherBalanceInWei(req.query.addr);
    res.json({
      etherBalanceInWei: response.balance
    })
  }
});

router.get('/getBuyOrderBook', async function(req, res) {
  response = await getBuyOrderBook(req.query.symbolName);
  if (response.is_success) {
    res.json({
      indexes: response.indexes,
      prices: response.prices,
      amounts: response.amounts
    })
  }
  else {
    res.json({
      msg: response.msg
    })
  }
});

router.get('/getSellOrderBook', async function(req, res) {
  response = await getSellOrderBook(req.query.symbolName);
  if (response.is_success) {
    res.json({
      indexes: response.indexes,
      prices: response.prices,
      amounts: response.amounts
    })
  }
  else {
    res.json({
      msg: response.msg
    })
  }
});

module.exports = router;
