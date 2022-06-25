const { expect } = require("chai");
const { ethers } = require("hardhat");

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
        stakeContract = await stake.deploy(nftContract.address, rewardToken.address);
        await stakeContract.deployed();
        [owner, staker1, staker2, staker3, _] = await ethers.getSigners();
    });

    it("Should get stake NFT data passed during contructor", async function () {
        const nftAddress = await stakeContract.StakeNFT();
        const rewardTok = await stakeContract.rewardsToken();
        expect(nftAddress).to.equal(nftContract.address);
        expect(rewardTok).to.equal(rewardToken.address);
    });

    

});
