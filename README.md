# cx4153-blockchain-technology
## Project aDEX (adriangohjw Decentralized EXchanege)

Build a minimal viable Decentralized Exchange (DEX) on Ethereum and a simple (minimally styled) front-end website, which supports listing of available asset tokens on the marketplace, submission of trading order, matching and execution of orders (i.e. swapping/exchanging/trading assets), and most importantly, in our DEX, users have the ultimate control of his/her own digital assets.

## Background

Traditional trading sites and centralized exchanges allow users to purchase and trade different digital assets on their platforms. For example, your first time purchasing an Ethereum token or Bitcoin was probably through a centralized exchange like Coinbase, Binance, Bittrex, Huobi and alike.  The central thesis for these exchanges is “key management is hard for average users”, thereby they will manage cryptographic keys for you and provide more friendly interface as a service, and all you, the user, need to do is authenticate yourself to these platforms using traditional login username and passwords. The actual private keys that control and “own” the assets/cryptocurrencies are in the database of these companies. Evidentially, all these platforms claim that they have best security team in the world to secure your keys and therefore your assets from stolen or lost.

Unfortunately, there are no lack of examples of those platforms mishandling or losing users' assets, either by internal corruption, or by external hacks. The most infamous Mt.Gox, a centralized bitcoin exchange, which at one time is handling 70% of all bitcoin trading – the largest in the world, until they got hacked and lost majority of its bitcoin, or rather its customers’ bitcoin and filed bankruptcy.

Fundamentally, the problem is that your cryptocurrencies and digital assets are as secure as your key management. Regardless of all the cryptographic protections and techniques we cover previously in our course, and how unhackable the underlying math is, if you don’t own your keys, then you don’t really own your asset. And asking a centralized exchange to hold your keys for you is a huge trust assumption and liability.
With this problem in mind, here comes a promising solution – decentralized exchanges or DEX for short.
What distinguish DEX is that, users would need to manage their keys in their digital wallet locally (e.g. MetaMask). Now, no one else would have control over your money – there isn’t a honeypot of millions of bitcoin sitting in certain company’s database waiting for hackers to get a shot, you don’t have to trust any third party that your assets are safe.

In a DEX system, the exchange only manages buy/sell orders from users – exactly like a marketplace where sellers put out the prices range and amount to exchange, and later on some buyers will fulfill that requests. In simpler term, DEX are places where you bring your own key/wallet, to trade your digital assets (e.g. USD token) with other assets (e.g. Gold Token, ETH token) -- and this process is referred as token exchange, or token trading, or token swap. Here are some top tokens/digital assets on Ethereum blockchain.

## Project Description:


## Table of Contents
* [Installation](#installation)
* [Usage](#usage)

## Installation

It is assumed that the following pre-requisits are met:
- Node (v12.16.1) installed
- npm (v6.13.4) installed
- MetaMask Extension and created at least 1 account
- Truffle v5.1.45 (core: 5.1.45) installed
- Infura account setup with at least one set of endpoints
- Ganache (for running local blockchain)

Steps to install:
1. Clone this repository
2. Run `npm install`
3. Run `cd webapp && npm install`

## Usage

### Adding secrets

1. Create a file called `secret.js` in the root directory
   ```javascript
   const secrets = {
      infuraKey: "xxx" // this should be your infuraKey
    };
   ```

### To choose local or testnet

1. Go to `Exchange.js` and update the `true` / `false` value
    ```javascript
    // set true for testnet / false for development
    if (true) {
      // testnet
      var infuraWSS = `wss://ropsten.infura.io/ws/v3/6dbaa0a0eed5453ab2d7e585a6ff39b6`;
      var exchangeContractAddress = "0x641Ad5725E9C2AFb7f7936c3E45711E5dc08D3b5";
    }
    else {
      // development - to update this
      var infuraWSS = `ws://localhost:7545`;
      var exchangeContractAddress = "0xB4C0ed7Ad8616c450A688218eaFABE5f0a45Cdf8";
    }
    ```
  
2. Go to `Index.js` and update the `true` / `false` value
    ```javascript
    // set true for testnet / false for development
    if (true) {
      // testnet
      var infuraHttp = `https://ropsten.infura.io/v3/6dbaa0a0eed5453ab2d7e585a6ff39b6`;
      var exchangeContractAddress = "0x641Ad5725E9C2AFb7f7936c3E45711E5dc08D3b5";
    }
    else {
      // development - to update  this
      var infuraHttp = `http://localhost:7545`;
      var exchangeContractAddress = "0xB4C0ed7Ad8616c450A688218eaFABE5f0a45Cdf8";
    }
    ```

### For local blockchain network
1. Run `npm start` to get the server running
2. Go to [localhost:3000](http://localhost:3000/)

### For testnet (ropsten) network (Ignore)

NOTE: Turns out the code faces some last minute problem because Infura doesn't support sending non-raw transactions. 
1. Add tokens to your Metamask wallet (Reference: [Adding custom tokens to Metamask](https://metamask.zendesk.com/hc/en-us/articles/360015489031-How-to-View-See-Your-Tokens-in-Metamask))

      | Token Name | Contract Address                           | Symbol Name | Decimals |
      |------------|--------------------------------------------|-------------|----------|
      | AdrianCoin | 0xd3F1b9650d4E07e6d2B053efAFFfa60d569CDb8B | ADC         | 8        |
      | Bitconnect | 0xE5C41188462E63c602Bb831AfBA62C11c794De36 | BCC         | 8        |
      | One Coin   | 0xc21192efb4dfB112Eb69a036DbFE4BC263CA52Cd | ONE         | 8        |

2. Reach out to me with your address to get some ERC20 tokens for testing
3. Run `npm start` to get the server and go to [localhost:3000](http://localhost:3000/)


## Author 
Adrian Goh Jun Wei - [GitHub](https://github.com/adriangohjw)
