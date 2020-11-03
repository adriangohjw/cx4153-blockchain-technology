var express = require('express');
var router = express.Router();

// set true for testnet / false for development
if (true) {
  // testnet
  var infuraHttp = `https://ropsten.infura.io/v3/6dbaa0a0eed5453ab2d7e585a6ff39b6`; // To change to your own infura endpoint
  var exchangeContractAddress = "0x641Ad5725E9C2AFb7f7936c3E45711E5dc08D3b5";
}
else {
  // development
  var infuraHttp = `http://localhost:7545`;
  var exchangeContractAddress = "0xB4C0ed7Ad8616c450A688218eaFABE5f0a45Cdf8";
}

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', {
    web3_http: infuraHttp,  // To change to infuraHttp for testnet
    contract_address: exchangeContractAddress // to change to ExchangeContractAddress for testnet
  })
});

module.exports = router;
