// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/ownable.sol";
import "./events.sol";

contract Staking is ERC721Holder, events {
    IERC721 public StakeNFT;
    IERC20 public rewardsToken;
    uint256 public totalStaked;

    struct Stake {
        uint256[] tokenID;
        uint256 totalRewards;
        uint256 time;
    }

    mapping(address => Stake) public stakes;

    constructor(address _nft, address _token) {
        StakeNFT = IERC721(_nft);
        rewardsToken = IERC20(_token);
    }

    function stake(uint256[] memory _tokenIds) external {
        // get the length of tokenID
        uint256 lent = _tokenIds.length;
        // declare user storage file
        Stake storage userStake = stakes[_msgSender()];
        // bool to check if the user own any token it will be true
        // otherwise no state variable will be initialized.
        bool ownAny;
        for (uint256 i; i < lent; ) {
            // safe to get the owner of the token to be staked
            address isOwner = StakeNFT.ownerOf(_tokenIds[i]);
            // if caller is the owner of the ID, then update it state
            if (isOwner == _msgSender()) {
                userStake.tokenID.push(_tokenIds[i]); 
                totalStaked ++;
                if (!ownAny) {
                    // update this state once for gas efficiency
                    ownAny = true;
                }
                // emmit stake event
                emit Stake(_msgSender(), _tokenIds[i], block.timestamp);
            }           
            unchecked {
                i++;
            }
        }
        // if caller has any token ID from the inputs IDs then `ownAny` will be initialized to true
        if(ownAny) {
            // initialize user time
            userStake.time = block.timestamp;
            // updating user rewards to add 0
            userStake.totalRewards += 0;
        }
    }
}
