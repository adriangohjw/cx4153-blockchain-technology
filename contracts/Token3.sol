// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.8.0;

import "./owned.sol";
import "./token.sol";

///////////////
/* STANDARD ERC20 Token Interface */
/* reference: https://eips.ethereum.org/EIPS/eip-20 */
///////////////
contract Token3 is ERC20Interface, owned {

	// initialize token with 1 million tokens and allocate all to the token's creator
	constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _totalSupply;

		owner = msg.sender;
		balances[owner] = totalSupply;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

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
		if (balances[msg.sender] >= _value
			&& _value > 0
			&& balances[_to] + _value > balances[_to]) {
					balances[msg.sender] -= _value;
					balances[_to] += _value;
					emit Transfer(msg.sender, _to, _value);
					return true;
			}
			else {
					return false;
			}
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		if (balances[_from] >= _value
        && _value > 0
        && balances[_to] + _value > balances[_to]) {
            balances[_from] -= _value;
            balances[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {
		return success;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return remaining;
	}

}