// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardsToken is ERC20 {
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        // total supply minted to owner
        _mint(msg.sender, 10000000 * (10**18));
    }
    
}


