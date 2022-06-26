// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
/**
* @dev Emitted when `stake` tokens are moved from user to contract  (`user`) to
* another (`address(this)`), and the `tokenID` then the `time` user staked.
*
* Note that `value` may be zero.
*/

interface events {

    event Staked(address indexed user, uint256 tokenID, uint256 timeStake);

    event UnStaked(address indexed user, uint256 tokenID, uint256 timeStake);

    event UpdateAsset(
        address indexed asset, 
        uint256 rewardForOne, 
        uint256 thirtydaysRewards,
        uint256 sixtydaysRewards,
        uint256 yearlyRewards
    );

    event Liquidate(address indexed asset, uint256 liquidationTime);

    event WithdrawReward(address indexed user, uint256 assetID, uint256 time);

}