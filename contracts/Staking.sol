// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./RewardsToken.sol";
import "./NFT.sol";

contract Staking is ERC721Holder {
    NFT public nft;
    RewardsToken public rewardsToken;
    address public owner;
    uint256 public totalStaked;

    struct Stake {
        address userAddr;
        uint256 tokenID;
        uint256 amount;
        uint256 time;
    }

    constructor(NFT _nft, RewardsToken _token) {
        nft = _nft;
        rewardsToken = _token;
        owner = msg.sender;
    }

    mapping(address => Stake) public stakes;

    function stake(uint256[] memory _tokenIds) external {
        uint256 tokenIds;
        totalStaked += _tokenIds.length;
    }
}
