async function main(){
    const nftMarket = await ethers.getContractFactory("NFTMarket");
    const deployedNftMarket = await nftMarket.deploy();
    await deployedNftMarket.deployed();
    console.log("Deployed market address: ", deployedNftMarket.address);

    const nft = await ethers.getContractFactory("NFT");
    const deployedToken = await nft.deploy(deployedNftMarket.address);
    await deployedToken.deployed();
    console.log("Deployed token address: ", deployedToken.address);
}

main().then(()=>process.exit(0)).catch((e)=>{console.log(e); process.exit(1)});