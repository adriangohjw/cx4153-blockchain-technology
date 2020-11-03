var express = require('express');
var router = express.Router();

// blockchain http address
const infuraHttp = `https://mainnet.infura.io/v3/5a68d74b5a074d7ab6834c50c65773b9`; // To change to your own infura endpoint
const local_Http = `http://localhost:7545`;

// contract address
const ExchangeContractAddress = "0x1420180D527adfDcb7c17C8eA3a39C6b53b573Ab"; // To change to your own testnet contract address
const local_ExchangeContractAddress = "0x98b7dE6C91529F1e0fC7039b4357105ec3379926"; // To change to your own local contract address

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', {
    web3_http: local_Http,  // To change to infuraHttp for testnet
    contract_address: local_ExchangeContractAddress // to change to ExchangeContractAddress for testnet
  })
});

module.exports = router;
