// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract owned {
    address owner;

    modifier onlyowner() {
        require(msg.sender == owner);
        _;

    }
}
