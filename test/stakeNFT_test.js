const { expect } = require("chai");
const { ethers } = require("hardhat");
const cTable = require('console.table');

describe("Stake NFT Contract Test", function () {

    let stakeContract, nftContract, rewardToken, owner, staker1, staker2, staker3;
    beforeEach(async function () {
        // deploy token for reward
        const token = await ethers.getContractFactory("RewardsToken");
        rewardToken = await token.deploy("Reward Token", "RTK");
        await rewardToken.deployed();
        // deploy nft contract
        const nft = await ethers.getContractFactory("NFT");
        nftContract = await nft.deploy("Test NFT", "TNFTs");
        await nftContract.deployed();
        // deployments
        const stake = await ethers.getContractFactory("NFTStaking");
        stakeContract = await stake.deploy(rewardToken.address);
        await stakeContract.deployed();
        [owner, staker1, staker2, staker3, _] = await ethers.getSigners();

        // setting values
        const reward = ethers.utils.parseEther("3");
        const thirty = ethers.utils.parseEther("2");
        const sixty = ethers.utils.parseEther("4");
        const yearly = ethers.utils.parseEther("8");
        await stakeContract.BatchUpdateAsset(
            [nftContract.address],
            [reward],
            [thirty],
            [sixty],
            [yearly]
        );

        const amountTransferred = ethers.utils.parseEther("100");
        await rewardToken.transfer(stakeContract.address, amountTransferred)
    });

    // verify all inputs data are correct
    it("Should get stake NFT data passed during contructor", async function () {
        const rewardTok = await stakeContract.rewardsToken();
        // expect checks
        expect(rewardTok).to.equal(rewardToken.address);
        const assetData = await stakeContract.getAssetData(0);
        console.table([ {
            'Asset: ': assetData[0],
            'reward: ': assetData[1].toString(),
            'thirty Days: ': assetData[2].toString(),
            'sixty Days: ': assetData[3].toString(),
            'yearly: ': assetData[4].toString()
        }]);
    });

    it("Should be able to stake single NFT and get owner stake info", async function () {
        // get the balance of owner
        const ownerBalance = await rewardToken.balanceOf(owner.address)
        // owner minting NFT...
        await nftContract.connect(owner).mint(1);
        const NFTOwner = await nftContract.ownerOf(1)
        // console.log("owner balance is: ", ownerBalance.toString())
        // console.log("owner of token ID of 1 is :", NFTOwner)
        expect(NFTOwner).to.equal(owner.address);
        // expect(rewardTok).to.equal(rewardToken.address);
        // owner staking NFT
        const arg = [1]
        await nftContract.connect(owner).setApprovalForAll(stakeContract.address, true);
        await stakeContract.connect(owner).stake(0, arg)

        const stakeNFTContractBalance = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalance = await nftContract.balanceOf(owner.address)
        const userStaked = await stakeContract.getUserInfo(0, owner.address);
        console.table([{
            'User ID': userStaked.ids.toString(),
            'user Reward': userStaked.rewards.toString(),
            'user stake time': userStaked._time.toString()
        }])
        expect(userStaked.ids.toString()).to.equal("1");
        expect(stakeNFTContractBalance.toString()).to.equal("1");
        expect(ownerNFTBalance.toString()).to.equal("0");
    });

    it("Should be able to stake multiple NFT and get owner stake info", async function () {
        // get the balance of owner
        const ownerBalance = await rewardToken.balanceOf(owner.address)
        // owner minting NFT...
        await nftContract.connect(owner).mint(1);
        await nftContract.connect(owner).mint(2);
        const NFTOwner = await nftContract.ownerOf(1)
        // console.log("owner balance is: ", ownerBalance.toString())
        // console.log("owner of token ID of 1 is :", NFTOwner)
        expect(NFTOwner).to.equal(owner.address);
        // expect(rewardTok).to.equal(rewardToken.address);
        // owner staking NFT
        const arg = [1, 2]
        await nftContract.connect(owner).setApprovalForAll(stakeContract.address, true);
        await stakeContract.connect(owner).stake(0, arg)
        const stakeNFTContractBalance = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalance = await nftContract.balanceOf(owner.address)
        const userStaked = await stakeContract.getUserInfo(0, owner.address);
        expect(userStaked.ids.toString()).to.equal("1,2");
        expect(stakeNFTContractBalance.toString()).to.equal("2");
        expect(ownerNFTBalance.toString()).to.equal("0");
    });

    it("Should be able to UnStake single NFT", async function () {
        // get the balance of owner
        const ownerBalance = await rewardToken.balanceOf(owner.address)
        // owner minting NFT...
        await nftContract.connect(owner).mint(1);
        await nftContract.connect(owner).mint(2);
        const NFTOwner = await nftContract.ownerOf(1)
        expect(NFTOwner).to.equal(owner.address);
        await nftContract.connect(owner).setApprovalForAll(stakeContract.address, true);
        const arg = [1, 2]
        await stakeContract.connect(owner).stake(0, arg)
        const stakeNFTContractBalance = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalance = await nftContract.balanceOf(owner.address)

        const userStaked = await stakeContract.getUserInfo(0, owner.address);
        expect(userStaked.ids.toString()).to.equal("1,2");
        expect(stakeNFTContractBalance.toString()).to.equal("2");
        expect(ownerNFTBalance.toString()).to.equal("0");


        await stakeContract.connect(owner).unstake(0, arg[0])

        const userUnStaked = await stakeContract.getUserInfo(0, owner.address);
        console.log("user ID: ", userUnStaked.ids.toString())


        const stakeNFTContractBalanceAfterUnstake = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalanceAfterUnstake = await nftContract.balanceOf(owner.address)
        expect(stakeNFTContractBalanceAfterUnstake.toString()).to.equal("1");
        expect(ownerNFTBalanceAfterUnstake.toString()).to.equal("1");
    });

    it("Should revert when asset has been liquidated", async function () {
        // get the balance of owner
        const ownerBalance = await rewardToken.balanceOf(owner.address)
        // owner minting NFT...
        await nftContract.connect(owner).mint(1);
        await nftContract.connect(owner).mint(2);
        const NFTOwner = await nftContract.ownerOf(1)
        expect(NFTOwner).to.equal(owner.address);
        await nftContract.connect(owner).setApprovalForAll(stakeContract.address, true);
        const arg = [1, 2]
        await stakeContract.connect(owner).stake(0, arg)
        const stakeNFTContractBalance = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalance = await nftContract.balanceOf(owner.address)

        const userStaked = await stakeContract.getUserInfo(0, owner.address);
        expect(userStaked.ids.toString()).to.equal("1,2");
        expect(stakeNFTContractBalance.toString()).to.equal("2");
        expect(ownerNFTBalance.toString()).to.equal("0");

        await stakeContract.connect(owner).liquidateAsset(nftContract.address, true);        
        await expect(stakeContract.connect(owner).unstake(0, arg[0])).to.be.revertedWith(
            'liquidate'
        );

        const userUnStaked = await stakeContract.getUserInfo(0, owner.address);
        console.log("user ID: ", userUnStaked.ids.toString())
        const stakeNFTContractBalanceAfterUnstake = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalanceAfterUnstake = await nftContract.balanceOf(owner.address)
        expect(stakeNFTContractBalanceAfterUnstake.toString()).to.equal("2");
        expect(ownerNFTBalanceAfterUnstake.toString()).to.equal("0");
    });

    it("Should withdraw from the contract", async function () {
        // get the balance of owner
        const ownerBalance = await rewardToken.balanceOf(owner.address)
        // owner minting NFT...
        await nftContract.connect(owner).mint(1);
        await nftContract.connect(owner).mint(2);
        const NFTOwner = await nftContract.ownerOf(1)
        expect(NFTOwner).to.equal(owner.address);
        await nftContract.connect(owner).setApprovalForAll(stakeContract.address, true);
        const arg = [1, 2]
        await stakeContract.connect(owner).stake(0, arg)
        const stakeNFTContractBalance = await nftContract.balanceOf(stakeContract.address)
        const ownerNFTBalance = await nftContract.balanceOf(owner.address)

        const userStaked = await stakeContract.getUserInfo(0, owner.address);
        expect(userStaked.ids.toString()).to.equal("1,2");
        expect(stakeNFTContractBalance.toString()).to.equal("2");
        expect(ownerNFTBalance.toString()).to.equal("0"); 
        // 190258751902 // 95129375951 // 190258751902
        await stakeContract.connect(owner).withdrawReward(0, "95129375951")
        const getUserRewards = await stakeContract.calculatReward(0, owner.address)
        console.log("user rewards: ", getUserRewards.toString())
    });

});
