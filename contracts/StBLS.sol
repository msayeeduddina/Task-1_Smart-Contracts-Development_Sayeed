// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// stBLS Token Contract
contract StBLS is ERC20, Ownable {

    constructor() ERC20("Staked BLS", "stBLS") {}

    function mint(address recipient, uint256 amount) external onlyOwner {
        require(amount > 0, "Mint amount must be greater than zero");
        _mint(recipient, amount);
    }

}