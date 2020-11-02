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
const local_OwnerAddress = "0xA6891dAC0434Fb05dC91f1EFb43b7B609CE3194e"; // To change to your own local wallet address

// contract address
const ExchangeContractAddress = "0x1420180D527adfDcb7c17C8eA3a39C6b53b573Ab"; // To change to your own testnet contract address
const local_ExchangeContractAddress = "0xf4fd9FeBB6E7D2F1852f56aB8869321422274c51"; // To change to your own local contract address

// testnet that contract is deployed on
const Testnet = "ropsten";

// setting up connection for web3
let web3 = new Web3(
  Web3.currentProvider || new Web3.providers.WebsocketProvider(local_WSS)  // choose infuraWSS (ropsten testnet) / local_WSS (local)
);
const contract = new web3.eth.Contract(exchange_artifact.abi, local_ExchangeContractAddress);  // choose ExchangeContractAddress (ropsten testnet) / local_ExchangeContractAddress (local)

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

router.get('/getBuyOrderBook', async function(req, res) {
  try {
    var buyOrderBook = await contract.methods.getBuyOrderBook(req.query.symbolName).call();
    res.json({
      indexes: buyOrderBook['0'],
      prices: buyOrderBook['1'],
      amounts: buyOrderBook['2']
    })
  }
  catch (error) {
    console.log(error);
    res.json({
      msg: `Error retrieving buyOrderBook`
    })
  }
});

router.get('/getSellOrderBook', async function(req, res) {
  try {
    var sellOrderBook = await contract.methods.getSellOrderBook(req.query.symbolName).call();
    res.json({
      indexes: sellOrderBook['0'],
      prices: sellOrderBook['1'],
      amounts: sellOrderBook['2']
    })
  }
  catch (error) {
    console.log(error);
    res.json({ 
      msg: `Error retrieving sellOrderBook`
    })
  }
});

module.exports = router;
