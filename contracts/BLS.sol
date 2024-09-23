// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// BLS Token Contract
contract BLS is ERC20, Ownable {

    constructor(uint256 initialSupply) ERC20("BLS Token", "BLS") {
        _mint(msg.sender, initialSupply);
    }

}