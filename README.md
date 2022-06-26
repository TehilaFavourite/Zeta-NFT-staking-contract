# Zeta NFT Staking smart contract Documentation  

In this contract, the user is staking NFT
The NFT addresses required to be staked is set by the owner.


# Functions in the staking contract and their use case

```solidity
pragma solidity 0.8.7;

contract NFTStaking is ERC721Holder, Ownable, events {

    /**
     * @dev Enables the owner to set the NFT addresses required to be staked
     * withdraw the `tokenIds`
     * Enables users to stake different NFT collections
     *
     * IMPORTANT: require The length of arrays in the arguments in BatchUpdateAsset() must be thesame else
     * it will throw an error.
     * 
     * - arrays `_assets`, This holds the Ids of all the NFT Addresses pushed in the array
     * - arrays `forOneYouStakeTheRewardIs`, This is the reward for one NFT user stakes
     * - arrays `_thirtyDays`, This is the reward user gets for staking for 30 days
     * - arrays `_sixtyDays`,  This is the reward user gets for staking for 60 days
     * - arrays `_yearly`    This is the reward user gets for staking for a year
     *
     * Emits an {Staked} event.
     */
    function BatchUpdateAsset(
        address[] memory _assets,
        uint256[] memory forOneYouStakeTheRewardIs,
        uint256[] memory _thirtyDays,
        uint256[] memory _sixtyDays,
        uint256[] memory _yearly 
    ) external;

    /**
     * @dev stake arrays of `_tokenIds` the `msg.sender` must have set `setApproval()` for the contract to
     * withdraw the `tokenIds`
     * Enables users to stake different NFT collections
     *
     * IMPORTANT: Beware that allowance must not be false for `_tokenIds`.
     * the caller (msg.sender) must be the owner of the `tokenIds`.
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed.
     * - The `_tokenIds` arrays of tokenID that user own on the (NFT address) to be staked.
     *
     * Emits a {Stake} event.
     */
    function stake(uint256 _assetPID, uint256[] memory _tokenIds) external {
        <!-- address isOwner ensures that user is the owner of the tokenID
        If user is the owner, the NFT is transferred from the user to the smart contract for staking.
        User can stake multiple NFT at once.

        *getAsset* stores the asset information. 
        *userStake* store/track userInfo
        The bool *ownAny* tracks how to store user information. If there is a successful transfer, it will store the user information as staked.
        The loop checks through the tokenID length to know if user is the owner of the NFT.
        The mapping in the struct helps to track user's NFT location.
        totalStake get the total NFTs users have staked. -->
    }

    /**
     * @dev unstake `_tokenIds` the `msg.sender` must have staked first
     * it's advisable to always withdraw rewards before unstaking if any.
     * Enables users to unstake staked NFT collections from the pool
     *
     * IMPORTANT: Beware that liquidation must not occur before unstaking if not an error will be triggered.
     * the caller (msg.sender) must have staked `tokenIds` on the pool.
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed.
     * - The `_tokenIds` the staked tokenID that user own on the pool.
     *
     * Emits an {UnStake} event.
     */
    function unstake(uint256 _assetPID, uint256 _tokenID) external {
        <!-- Recieved the asset PID and the _tokenID check if asset has been liquidated first,
        get the length of token that the user staked and loop thorugh to check if user staked
        the token id he wants to withdraw. If user own it, `iOwnedTheTokenID` will be set to true
        otherwise set to false which shows user does not own the tokenID or did not stake the tokenID,
        if owned, it pops the length of user collection and update its state, 
        then initiates a transfer to the user -->
    }

    /**
     * @dev withdrawReward `amount` the `msg.sender`
     * Enables users to withdraw rewards.
     *
     * IMPORTANT: Beware that for security, user must stake before calling this function at least once.
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed.
     * - The `amount` amount to withdraw from the pool must be less than or equal to total reward.
     *
     * Emits an {WithdrawReward} event.
     */
    function withdrawReward(uint256 _assetPID, uint256 amount) public {
        <!-- 
         Use the _assetPID to get user information from storage,
         checks to see if user staked any token if not, it throws an error,
         calculate user current rewards,
         if input amount is greater that reward generated, it throws an error,
         initiate a transfer of amount to user.
        -->
    }

    /**
     * @dev calculatReward view functions
     * Enables users to check their rewards.
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed.
     * - The `_user` address of the users to check reward.
     *
     */
    function calculatReward(uint256 _assetPID, address _user) public view returns(uint256 rewards) {
        <!-- calculate user rewards based on timing -->
    }

    /**
     * @dev get information related to a user in each asset. view functions
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed.
     * - The `_user` address of the users to check reward.
     *
     */
    function getUserInfo(uint256 _assetPID, address _user) external view returns {
        <!-- user infor in each pool 
         return the struct called `Stake`-->
    }

    /**
     * @dev Returns the true if an asset has been liquidated.
     * 
     * - The `_asset` is this assest (NFT address) liquidated ?.
     *
     */
    function isAssetLiquidated(address _asset) external view returns (bool);

    /**
     * @dev get information related to a a pool. view functions
     * 
     * - The `_assetPID` is the assest (NFT address) associated to that indexed set by owner.
     *
     */
    function getAssetData(uint256 _assetPID) external view returns(RewardsByAssets memory data) {
        <!-- user infor of each pool 
         return the struct called `RewardsByAssets`-->
    }

    /**
     * @dev safe withdrawaL mechanism to witdraw token (ERC20) can only be called by owner
     */
    function safeWithdrawalToken(address _token, address _to, uint256 _amount) external;

    /**
     * @dev safe withdrawaL mechanism to witdraw token (ERC721) can only be called by owner
     */
    function safeWithdrawalNFT(address _token, address _to, uint256 _tokenId) external;

    /**
     * @dev safe withdrawaL mechanism to witdrawal for Batch token (ERC721) can only be called by owner
     * not gas efficient.
     */
    function BatchSafeWithdrawalNFT(address _token, address _to, uint256[] memory _tokenIds) external
}

```
