// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

///////////////
/* STANDARD ERC20 Token Interface */
/* reference: https://eips.ethereum.org/EIPS/eip-20 */
///////////////

contract Token {

	function name() virtual public view returns (string memory);

	function symbol() virtual public view returns (string memory);

	function decimals() virtual public view returns (uint8);

	function totalSupply() virtual public view returns (uint256);

	function balanceOf(address _owner) virtual public view returns (uint256 balance);

	function transfer(address _to, uint256 _value) virtual public returns (bool success);

	function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);

	function approve(address _spender, uint256 _value) virtual public returns (bool success);

	function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract ERC20Token is Token {

	function name() virtual public view returns (string memory) {
		string name;
		return name;
	};

	function symbol() virtual public view returns (string memory) {
		string symbol;
		return symbol;
	};

	function decimals() virtual public view returns (uint8) {
		uint8 decimals;
		return decimals;
	};

	function totalSupply() virtual public view returns (uint256) {
		uint256 supply;
		return supply;
	};

	function balanceOf(address _owner) virtual public view returns (uint256 balance) {
		uint256 balance;
		return balance;
	};

	function transfer(address _to, uint256 _value) virtual public returns (bool success) {
		bool success;
		return success;
	};

	function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success) {
		bool success;
		return success;
	};

	function approve(address _spender, uint256 _value) virtual public returns (bool success) {
		bool success;
		return success;
	};

	function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining) {
		uint256 remaining;
		return remaining;
	};

	event Transfer(address indexed _from, address indexed _to, uint256 _value) {

	};

	event Approval(address indexed _owner, address indexed _spender, uint256 _value) {

	};

}