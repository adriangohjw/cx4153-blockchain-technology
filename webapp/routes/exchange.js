// Express routers
var express = require('express');
var router = express.Router();

// importing libraries required for metamask and ethereum libraries
var Web3 = require("web3");

// importing a compiled contract artifact which contains function signature etc. to interact
var artifact = require("../../build/contracts/Exchange.json");

// infura endpoint
const infuraWSS = `wss://ropsten.infura.io/ws/v3/5a68d74b5a074d7ab6834c50c65773b9`;

// contract address
const ExchangeContractAddress = "0x1420180D527adfDcb7c17C8eA3a39C6b53b573Ab";

// testnet that contract is deployed on
const Testnet = "ropsten";

// setting up connection for web3
let web3 = new Web3(
  Web3.currentProvider || new Web3.providers.WebsocketProvider(infuraWSS)
);
const contract = new web3.eth.Contract(artifact.abi, ExchangeContractAddress);

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

router.get('/getEtherBalanceInWei', async function(req, res) {
  if (req.query.addr) {
    response = await getEtherBalanceInWei(req.query.addr);
    res.json({
      etherBalanceInWei: response.balance
    })
  }
});

module.exports = router;
