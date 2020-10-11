// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.8.0;

import "./owned.sol";

///////////////
/* STANDARD ERC20 Token Interface */
/* reference: https://eips.ethereum.org/EIPS/eip-20 */
///////////////
contract ERC20Interface {

	string name;
	string symbol;
	uint8 decimals;
	uint totalSupply;
	
	mapping (address => uint) balances;

	function getName() external view returns (string memory);

	function getSymbol() external view returns (string memory);

	function getDecimals() external view returns (uint8);

	function getTotalSupply() external view returns (uint256);

	function balanceOf(address _owner) external view returns (uint256 balance);

	function transfer(address _to, uint256 _value) external returns (bool success);

	function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

	function approve(address _spender, uint256 _value) external returns (bool success);

	function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract Token is ERC20Interface, owned {

	// initialize token with 1 million tokens and allocate all to the token's creator
	constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _totalSupply;

		owner = msg.sender;
		balances[owner] = totalSupply;
	}

	function getName() public view returns (string memory) {
		return name;
	}

	function getSymbol() public view returns (string memory) {
		return symbol;
	}

	function getDecimals() public view returns (uint8) {
		return decimals;
	}

	function getTotalSupply() public view returns (uint256) {
		return totalSupply;
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {
		return success;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		return success;
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {
		return success;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return remaining;
	}

}