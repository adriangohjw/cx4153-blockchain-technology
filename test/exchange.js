const truffleAssert = require('truffle-assertions');

const ERROR_MESSAGE = "VM Exception while processing transaction: revert";

const Exchange = artifacts.require("Exchange");

contract("Exchange", async (accounts) => {

  it("should make deployer the owner", async () => {
    let exchange = await Exchange.deployed();

    let owner = await exchange.getOwner();

    assert.equal(owner, accounts[0]);
  });

  it("depositEther(): can deposit correctly", async () => {
    let exchange = await Exchange.deployed();
    await exchange.depositEther({
      from: accounts[0],
      value: web3.utils.toWei("3"),
    });

    let deposited = await exchange.getEtherBalanceInWei({ from: accounts[0] });
    
    assert.equal(deposited.toString(), web3.utils.toWei("3"));
  });

  it("withdrawEther(): can withdraw less than despoited", async () => {
    let exchange = await Exchange.deployed();
    await exchange.depositEther({
      from: accounts[1],
      value: web3.utils.toWei("3"),
    });

    await exchange.withdrawEther(web3.utils.toWei("2.9"), { from: accounts[1] });

    let etherBalance = await exchange.getEtherBalanceInWei({ from: accounts[1] });
    assert.equal(etherBalance.toString(), web3.utils.toWei("0.1"));
  });

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