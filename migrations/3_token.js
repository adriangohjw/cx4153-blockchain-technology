const Token = artifacts.require("Token");
const Token2 = artifacts.require("Token2");
const Token3 = artifacts.require("Token3");

module.exports = function (deployer) {
  deployer.deploy(Token, "AdrianCoin", "ADC", 8, 1000000000);
  deployer.deploy(Token2, "BitConnect", "BCC", 8, 1000000000);
  deployer.deploy(Token3, "OneCoin", "ONE", 8, 1000000000);
};
