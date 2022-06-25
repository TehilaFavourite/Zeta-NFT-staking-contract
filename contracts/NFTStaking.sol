// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./events.sol";

contract NFTStaking is ERC721Holder, Ownable, events {
    IERC20 public rewardsToken;
    uint256 public totalStaked;
    uint256 public rewardForOneToken;

    struct Stake {
        address asset;
        uint256[] tokenID;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(uint256 => uint256) _indexes;
        uint256 totalRewards;
        uint256 time;
    }

    struct RewardsByAssets {
        address Asset;
        uint256 reward;
        uint256 ThirtyDays;
        uint256 SixtyDays;
        uint256 Yearly;
    }

    error errorUpdatingStore();
    error liquidate();
    error invalidLength();
    error insufficientReward;

    mapping(uint256 => mapping(address => Stake)) internal stakes;
    mapping(address => bool) public liquidated;
    RewardsByAssets[] public rewardsByAssests;

    constructor(address _token) {
        rewardsToken = IERC20(_token);
    }

    function BatchUpdateAsset(
        address[] memory _assets, 
        uint256[] memory forOneYouStakeTheRewardIs, 
        uint256[] memory _thirtyDays, 
        uint256[] memory _sixtyDays, 
        uint256[] memory _yearly
    ) external onlyOwner {
        uint256 _asset = _assets.length;
        if (_asset != forOneYouStakeTheRewardIs.length ||
            _thirtyDays.length != _sixtyDays.length ||
            _sixtyDays.length != _yearly.length
        ) revert invalidLength();

        for (uint256 i; i < _asset; ) {
            updateAssets(
                _assets[i],
                forOneYouStakeTheRewardIs[i],
                _thirtyDays[i],
                _sixtyDays[i],
                _yearly[i]
            );
            unchecked {
                i++;
            }
        }
    }

    function updateAssets(
        address _asset, 
        uint256 forOneYouStakeTheRewardIs, 
        uint256 _thirtyDays, 
        uint256 _sixtyDays, 
        uint256 _yearly
    ) internal {
        RewardsByAssets memory reward = RewardsByAssets(
            _asset, 
            forOneYouStakeTheRewardIs,
            _thirtyDays, 
            _sixtyDays, 
            _yearly
        );
        rewardsByAssests.push(reward);
        emit UpdateAsset(
            _asset, 
            forOneYouStakeTheRewardIs,
            _thirtyDays, 
            _sixtyDays, 
            _yearly
        );
    }

    function liquidateAsset(address _asset, bool status) external onlyOwner {
        liquidated[_asset] = status;
        emit Liquidate(_asset, block.timestamp);
    }

    function stake(uint256 _assetPID, uint256[] memory _tokenIds) external {
        // get the length of tokenID
        uint256 lent = _tokenIds.length;
        RewardsByAssets memory getAsset = rewardsByAssests[_assetPID];
        address _asset = getAsset.Asset;
        // declare user storage file
        Stake storage userStake = stakes[_assetPID][_msgSender()];
        // bool to check if the user own any token it will be true
        // otherwise no state variable will be initialized.
        bool ownAny;
        for (uint256 i; i < lent; ) {
            // safe to get the owner of the token to be staked
            address isOwner = IERC721(_asset).ownerOf(_tokenIds[i]);
            // if caller is the owner of the ID, then update it state
            if (isOwner == _msgSender()) {
                // approval have to be made before staking
                IERC721(_asset).safeTransferFrom(_msgSender(), address(this), _tokenIds[i]);
                // update user storage
                userStake.tokenID.push(_tokenIds[i]); 
                // The value is stored at length-1, but we add 1 to all indexes
                // and use 0 as a sentinel value
                userStake._indexes[_tokenIds[i]] = userStake.tokenID.length;
                totalStaked ++;
                if (!ownAny) {
                    // update this state once for gas efficiency
                    ownAny = true;
                }
                // emmit stake event
                emit Staked(_msgSender(), _tokenIds[i], block.timestamp);
            }           
            unchecked {
                i++;
            }
        }
        // if caller has any token ID from the inputs IDs then `ownAny` will be initialized to true
        if(ownAny) {
            // update user asset
            userStake.asset = _asset;
            // initialize user time
            userStake.time = block.timestamp;
            // updating user rewards to add 0
            userStake.totalRewards += 0;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(uint256 _assetPID, uint256 value) private returns (bool) {

        Stake storage userStake = stakes[_assetPID][_msgSender()];
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = userStake._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = userStake.tokenID.length - 1;

            if (lastIndex != toDeleteIndex) {
                uint256 lastValue = userStake.tokenID[lastIndex];

                // Move the last value to the index where the value to delete is
                userStake.tokenID[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                userStake._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            userStake.tokenID.pop();

            // Delete the index for the deleted slot
            delete userStake._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function unstake(uint256 _assetPID, uint256 _tokenID) external {
        // declare user storage file
        RewardsByAssets memory getAsset = rewardsByAssests[_assetPID];
        address _asset = getAsset.Asset;
        if (liquidated[_asset]) revert liquidate();
        Stake storage userStake = stakes[_assetPID][_msgSender()];
        uint256 lent = userStake.tokenID.length;
        bool iOwnedTheTokenID;
        for (uint256 i; i < lent; ) {
            uint256 _id = userStake.tokenID[i];
            if (_id == _tokenID) {
                iOwnedTheTokenID = true;
                break;
            } else {
                iOwnedTheTokenID = false;
            }
        }
        if(iOwnedTheTokenID) {
            bool rem = _remove(_assetPID, _tokenID);
            if (!rem) revert errorUpdatingStore();
            IERC721(_asset).safeTransferFrom(address(this), _msgSender(), _tokenID);
            // emmit stake event
            if (userStake.tokenID.length == 0) {
                uint256 _reward = calculatReward(_assetPID, _msgSender());
                withdrawReward(_assetPID, _reward);
            }
            emit UnStaked(_msgSender(), _tokenID, block.timestamp);
        }
    }

    function withdrawReward(uint256 _assetPID, uint256 amount) public {
        Stake storage userStake = stakes[_assetPID][_msgSender()];
        RewardsByAssets memory getAsset = rewardsByAssests[_assetPID];
        uint256 _rewards = calculatReward(_assetPID, _msgSender());
        if (amount > _rewards) revert insufficientReward();
        _rewards -= amount;
        userStake.totalRewards = _rewards;
    }

    function calculatReward(uint256 _assetPID, address _user) public view returns(uint256 rewards) {
        Stake storage userStake = stakes[_assetPID][_user];
        RewardsByAssets memory getAsset = rewardsByAssests[_assetPID];
        uint256 userStakeTime = userStake.time;
        uint256 amountStaked = userStake.tokenID.length;
        uint256 time = block.timestamp.sub(userStakeTime);
    
        if (block.timestamp <= userStakeTime.add(30 days)) {
            uint256 pendingReward = (amountStaked.mul(getAsset.reward));
            uint256 thirty = (pendingReward / 365 days);
            reward = (thirty.mul(time));
            return (userStake.totalRewards + reward);
        }
        
        if (block.timestamp >= userStakeTime.add(30 days) && block.timestamp <= userStakeTime.add(60 days)) {
            uint256 pendingReward = (amountStaked.mul(getAsset.reward));
            uint256 sixty = (pendingReward / 365 days);
            reward = (sixty.mul(time));
            return (userStake.totalRewards + reward);
        }
        
        if (block.timestamp > userStakeTime.add(60 days)) {
            uint256 pendingReward = (amountStaked.mul(getAsset.reward));
            uint256 yearly = (pendingReward / 365 days);
            reward = (yearly.mul(time));
            return (userStake.totalRewards + reward);
        }
    }

    function getUserInfo(uint256 _assetPID, address _user) external view returns(
        address asset,
        uint256[] memory ids,
        uint256 rewards,
        uint256 _time
    ) {
        Stake storage _stakes = stakes[_assetPID][_user];
        uint256 lent = _stakes.tokenID.length;
        asset = _stakes.asset;
        ids = new uint256[](lent);
        ids = _stakes.tokenID;
        rewards = _stakes.totalRewards;
        _time = _stakes.time;
    }

    function getAssetData(uint256 _assetPID) external view returns(RewardsByAssets memory data) {
        data = rewardsByAssests[_assetPID];
    }
}
