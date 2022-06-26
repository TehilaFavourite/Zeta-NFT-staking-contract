# Zeta NFT Staking smart contract Documentation  

In this contract, the user is staking NFT
The NFT addresses required to be staked is set by the owner.


# Functions in the staking contract and their use case

# BatchUpdateAsset()
**input**
_assets (uint256[]) *This holds the Ids of all the NFT Addresses pushed in the array*
forOneYouStakeTheRewardIs (uint256[]) *This is the reward for one NFT user stakes*
_thirtyDays (uint256[]) *This is the reward user gets for staking for 30 days*
_sixtyDays (uint256[]) *This is the reward user gets for staking for 60 days*
_yearly (uint256[]) *This is the reward user gets for staking for a year*

**Essence**
Enables the owner to set the NFT addresses required to be staked

**caller**
owner

The length of arrays in the arguments in BatchUpdateAsset() must be thesame else, it will throw an error

# stake()
**input**
_assetPID (uint256) *This is the pool ID user wants to stake from*
_tokenIds (uint256[]) *This is the token ID user wants to stake*

**Essence**
Enables user to stake different NFT collections

**caller**
user

*address isOwner* ensures that user is the owner of the tokenID
If user is the owner, the NFT is transferred from the user to the smart contract for staking
User can stake multiple NFT at once.

*getAsset* stores the asset information. 
*userStake* store/track userInfo
The bool *ownAny* tracks how to store user information. If there is a successful transfer, it will store the user information as staked.
The loop checks through the tokenID length to know if user is the owner of the NFT.
The mapping in the struct helps to track user's NFT location.
totalStake get the total NFTs users have staked.
When user stake an NFT, an event is emitted.


# unstake()
**input**
_assetPID (uint256) *This is the pool ID user wants to unstake from*
_tokenIds (uint256) *This is the token ID user wants to unstake*

**Essence**
Enables user to unstake different NFT

**caller**
user

user can only unstake one NFT at a time.
*getAsset* stores the asset information.
