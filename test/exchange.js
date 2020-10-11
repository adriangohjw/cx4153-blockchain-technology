const { assert } = require('console');
const truffleAssert = require('truffle-assertions');

const Exchange = artifacts.require("Exchange");
const Token = artifacts.require("Token");

contract("Exchange", async (accounts) => {
  it("should make deployer the owner", async () => {
    let exchange = await Exchange.deployed();

    let owner = await exchange.getOwner();

    assert(owner == accounts[0]);
  });
});

contract("Exchange - depositEther()", async (accounts) => {
  it("depositEther(): can deposit correctly", async () => {
    let exchange = await Exchange.deployed();
    await exchange.depositEther({
      from: accounts[0],
      value: web3.utils.toWei("3"),
    });

    let deposited = await exchange.getEtherBalanceInWei({ from: accounts[0] });
    
    assert(deposited.toString() == web3.utils.toWei("3"));
  });

  it("withdrawEther(): can withdraw less than despoited", async () => {
    let exchange = await Exchange.deployed();
    await exchange.depositEther({
      from: accounts[1],
      value: web3.utils.toWei("3"),
    });

    await exchange.withdrawEther(web3.utils.toWei("2.9"), { from: accounts[1] });

    let etherBalance = await exchange.getEtherBalanceInWei({ from: accounts[1] });
    assert(etherBalance.toString() == web3.utils.toWei("0.1"));
  });
});

contract("Exchange - withdrawEther()", async (accounts) => {
  it("withdrawEther(): cannot withdraw less than despoited", async () => {
    let exchange = await Exchange.deployed();
    await exchange.depositEther({
      from: accounts[2],
      value: web3.utils.toWei("3"),
    });

    await truffleAssert.reverts(
      exchange.withdrawEther(web3.utils.toWei("3.5"), { from: accounts[2] })
    );
  });
});

contract("Exchange - addToken()", async (accounts) => {
  it("can only add token if symbolName does not exist and it's by owner", async() => {
    let exchange = await Exchange.deployed(); 
    let token = await Token.deployed("AdrianCoin", "ADC", 8, 1000000);

    await exchange.addToken("ADC", token.address, { from: accounts[0] });

    assert(exchange.hasToken("ADC"));
  })

  it("cannot add token if symbolName already exist", async() => {
    let exchange = await Exchange.deployed(); 
    let token = await Token.deployed("AdrianCoin", "ADC2", 8, 1000000);

    await exchange.addToken("ADC2", token.address, { from: accounts[0] });

    await truffleAssert.reverts(
      exchange.addToken("ADC2", token.address, { from: accounts[0] })
    );
  })

  it("cannot add token if it's not by owner even if symbolName does not exist", async() => {
    let exchange = await Exchange.deployed(); 
    let token = await Token.deployed("AdrianCoin", "ADC", 8, 1000000);

    await truffleAssert.reverts(
      exchange.addToken("ADC", token.address, { from: accounts[1] })
    );
  })

  it("can add at least 2 types of tokens", async() => {
    let exchange = await Exchange.deployed(); 
    let token = await Token.deployed("AdrianCoin", "ADC3", 8, 1000000);
    let token_2 = await Token.deployed("AdrianCoin", "ADC4", 8, 1000000);

    await exchange.addToken("ADC3", token.address, { from: accounts[0] });
    await exchange.addToken("ADC4", token_2.address, { from: accounts[0] });

    assert(exchange.hasToken("ACD3"));
    assert(exchange.hasToken("ACD4"));
  })
});

contract("Exchange - depositToken()", async (accounts) => {
  it("can deposit amount if token is supported", async() => {
    let exchange = await Exchange.deployed();
    let token = await Token.deployed("AdrianCoin", "ADC", 8, 1000000);
    await exchange.addToken("ADC", token.address, { from: accounts[0] });

    await exchange.depositToken("ADC", 100, { from: accounts[1] });

    let balance = await exchange.getBalanceForToken("ADC", { from: accounts[1] });    
    assert(balance.toString() == "100");
  })

  it("cannot deposit amount if token is not supported", async() => {
    let exchange = await Exchange.deployed();
    let token = await Token.deployed("AdrianCoin", "ADC2", 8, 1000000);
    await exchange.addToken("ADC2", token.address, { from: accounts[0] });
    
    await truffleAssert.reverts(
      exchange.depositToken("XXX", 100, { from: accounts[1] })
    );
  })
});

contract("Exchange - withdrawToken()", async (accounts) => {
  it("can withdraw amount if token is supported and amount is less than balance", async() => {
    let exchange = await Exchange.deployed();
    let token = await Token.deployed("AdrianCoin", "ADC", 8, 1000000);
    await exchange.addToken("ADC", token.address, { from: accounts[0] });
    await exchange.depositToken("ADC", 100, { from: accounts[1] });

    await exchange.withdrawToken("ADC", 80, { from: accounts[1] });

    let balance = await exchange.getBalanceForToken("ADC", { from: accounts[1] });    
    assert(balance.toString() == "20");
  })

  it("cannot withdraw amount if token is not supported", async() => {
    let exchange = await Exchange.deployed();
    let token = await Token.deployed("AdrianCoin", "ADC2", 8, 1000000);
    await exchange.addToken("ADC2", token.address, { from: accounts[0] });
    
    await truffleAssert.reverts(
      exchange.depositToken("XXX", 100, { from: accounts[1] })
    );
  })

  it("cannot withdraw amount if token is supported but amount is more than balance", async() => {
    let exchange = await Exchange.deployed();
    let token = await Token.deployed("AdrianCoin", "ADC3", 8, 1000000);
    await exchange.addToken("ADC3", token.address, { from: accounts[0] });
    await exchange.depositToken("ADC3", 100, { from: accounts[1] });

    await truffleAssert.reverts(
      exchange.withdrawToken("ADC3", 120, { from: accounts[1] })
    );
  })
});