const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Token, "AdrianCoin", "ADC", 8, 1000000);
};
