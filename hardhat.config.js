const { task } = require("hardhat/config");

require("@nomiclabs/hardhat-waffle");

task("mintNFT", "Mint Free NFT from HelloNft")
  .addParam("nftContract", "The NFT contract's address")
  .addParam("ownerAddress", "The address of the owner of the NFT")
  .addParam("uri", "URL for the nft data")
  .setAction(async (args, hre) => {
    const NFTContract = await hre.ethers.getContractAt(
      "HelloNft",
      args.nftContract
    );

    const txn = await NFTContract.awardItem(args.ownerAddress, args.uri);
    console.log("Successfully minted a Hello NFT ", txn);
  });

task("allowPermission", "allow the 3rd party to do transactions on the NFT")
  .addParam("nftContract", "The NFT contract's address")
  .addParam("daoContractAddress", "address of the dao")
  .addParam("tokenId", "id of the token")
  .setAction(async (args, hre) => {
    const NFTContract = await hre.ethers.getContractAt(
      "HelloNft",
      args.nftContract
    );
    const txn = await NFTContract.approve(args.daoContractAddress, args.tokenId);
    await txn.wait();
    console.log("DAO approved for token " + args.tokenId);
  });

task("joinDao", "allow the user to join the dao")
  .addParam("daoContractAddress", "address of the dao")
  .setAction(async (args, hre) => {
    const DaoContract = await hre.ethers.getContractAt("SynergyDAO", args.daoContractAddress);
    const txn = await DaoContract.join();
    await txn.wait();
    console.log("new member added to DAO");
  });

task("createProposal", "allow the members to create a proposal")
  .addParam("daoContractAddress", "address of the dao")
  .addParam("nftContractAddress", "address for the nft contract in proposal")
  .addParam("tokenId", "id of the token")
  .addParam("proposalType", "type of the proposal")
  .setAction(async (args, hre) => {
    const DaoContract = await hre.ethers.getContractAt("SynergyDAO", args.daoContractAddress);
    const txn = await DaoContract.createProposal(args.nftContractAddress, args.tokenId, args.proposalType);
    await txn.wait();
    console.log("proposal successfully created");
  });

task("voteOnProposal", "allow the members to vote on an active proposal")
  .addParam("daoContractAddress", "address of the dao")
  .addParam("proposalId", "id of the proposal to vote upon")
  .addParam("voteType", "type of vote to be casted on the proposal")
  .setAction(async (args, hre) => {
    const DaoContract = await hre.ethers.getContractAt("SynergyDAO", args.daoContractAddress);
    const txn = await DaoContract.voteOnProposal(args.proposalId, args.voteType);
    await txn.wait();
    console.log("member vote casted successfully");
  })

task("executeProposal", "allow the proposal to be executed")
  .addParam("daoContractAddress", "address of the dao")
  .addParam("proposalId", "id of the proposal to vote upon")
  .setAction(async (args, hre) => {
    const DaoContract = await hre.ethers.getContractAt("SynergyDAO", args.daoContractAddress);
    const txn = await DaoContract.executeProposal(args.proposalId);
    await txn.wait();
    console.log("NFT bought successfully");
  });

task("getNftOwner", "get the ownerof the NFT token")
  .addParam("nftContract", "The NFT contract's address")
  .addParam("tokenId", "id of the token")
  .setAction(async (args, hre) => {
    const NFTContract = await hre.ethers.getContractAt(
      "HelloNft",
      args.nftContract
    );

    const txn = await NFTContract.ownerOf(args.tokenId);
    console.log("Owner of the NFT is", txn);
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
};
