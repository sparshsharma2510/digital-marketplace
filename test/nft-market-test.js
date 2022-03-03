describe("NFTMarket", function(){
    it("Should create and execute market sales", async function(){
        const [owner, addr1] = await ethers.getSigners();
        console.log("owner: ",owner.address);
        const Market = await ethers.getContractFactory("NFTMarket");
        const marketToken = await Market.deploy();

        const marketPlaceAddress = marketToken.address;
        console.log("marketplace address: ",marketPlaceAddress);

        const NFT = await ethers.getContractFactory("NFT");
        const NFTToken = await NFT.deploy(marketPlaceAddress); 

        const nftContractAddress = NFTToken.address;
        console.log("nft contract address: ", nftContractAddress);

        let listingPrice = await marketToken.getListingPrice();
        listingPrice = listingPrice.toString();

        const auctionPrice = await ethers.utils.parseUnits('100','ether');
        await NFTToken.createToken("www.mytoken1.com");
        await NFTToken.createToken("www.mytoken2.com");

        await marketToken.createMarketItem(nftContractAddress, 1, auctionPrice, {value: listingPrice});
        await marketToken.createMarketItem(nftContractAddress, 2, auctionPrice, {value: listingPrice});
        await marketToken.connect(addr1).createMarketSale(nftContractAddress, 1, {value: auctionPrice});

        let itemsOnMarket = await marketToken.fetchMarketItems();

        itemsOnMarket = await Promise.all(itemsOnMarket.map(async i => {
            const tokenURI = await NFTToken.tokenURI(i.tokenId);
            return {
                price : i.price.toString(),
                tokenId: i.tokenId.toString(),
                seller: i.seller,
                owner: i.owner,
                tokenURI,
            };
        }));

        console.log("Items avaliable are: ", itemsOnMarket);
    });
});