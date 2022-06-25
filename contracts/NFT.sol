// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    // note anyone can mint, this is just for test purposes
    function mint(uint256 tokenId) external {
        _safeMint(msg.sender, tokenId);
    }
}
