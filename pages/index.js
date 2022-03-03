import { ethers } from "ethers";
import { useEffect, useState } from "react";
import axios from "axios";
import Web3Modal from "web3modal";
import { nftaddress, nftmarketaddress } from "../config";
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import Market from "../artifacts/contracts/NFTMarket.sol/NFTMarket.json";

export default function Home(){
    const [nfts, setNfts] = useState([]);
    const [loadingState, setLoadingState] = useState(true);
    
    useEffect(()=>{
        fetchNFTs();
    },[]);
    
    async function fetchNFTs(){
        const provider  = new ethers.providers.JsonRpcProvider();
        console.log(provider);
        //Referencing the smart contracts
        const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
        const marketContract = new ethers.Contract(nftmarketaddress, Market.abi, provider);
        console.log("ok "+marketContract.address);

        const data = await marketContract.fetchMarketItems();

        const items = await Promise.all(data.map(async item => {
            //tokenURI is a public function available in ERC721 contract that was inherited by
            //our NFT tokenContract
            const tokenUri = await tokenContract.tokenURI(item.itemId);
            //fetch the metadata uploaded to ipfs using axios
            const metaData = await axios.get(tokenUri);
            let price = ethers.utils.formatUnits(item.price.toString(),'ether');
            return  {
                price, 
                tokenId: item.tokenId.toNumber(),
                seller: item.seller,
                owner: item.owner,
                image: metaData.data.image,
                name: metaData.data.name,
                description: metaData.data.description
            };
        }));
        setNfts(items);
        setLoadingState(false);
    }

    async function buyNFT(nft){
        const web3Modal = new Web3Modal();
        const connection = await web3Modal.connect();
        //connection here is similar to the metamask object window.ethereum
        const provider = new ethers.providers.Web3Provider(connection);
        //Now for us to send ether and pay to change state 
        //within the blockchain, we need signer
        const signer = provider.getSigner();
        const contract = new ethers.Contract(nftmarketaddress, Market.abi, signer);
        const price = ethers.utils.parseUnits(nft.price.toString(), 'ether');

        const transaction = await contract.createMarketSale(nftaddress, nft.tokenId, {value: price});
        await transaction.wait();
        fetchNFTs();
    }

    if(!loadingState && nfts.length == 0)
        return(
            <h1 className="px-20 py-10 text-3xl">No NFTs available in the marketplace</h1>
        );

    return(
        <div className="flex justify-center">
            <div className="max-w-[1920px] px-4">
            <div className="grid grid-cols-1 gap-4 pt-4 sm:grid-cols-2 lg:grid-cols-4">
          {
            nfts.map((nft, i) => (
              <div key={i} className="overflow-hidden border shadow rounded-xl">
                <img src={nft.image} />
                <div className="p-4">
                  <p style={{ height: '64px' }} className="text-2xl font-semibold">{nft.name}</p>
                  <div style={{ height: '70px', overflow: 'hidden' }}>
                    <p className="text-gray-400">{nft.description}</p>
                  </div>
                </div>
                <div className="p-4 bg-black">
                  <p className="mb-4 text-2xl font-bold text-white">{nft.price} ETH</p>
                  <button className="w-full px-12 py-2 font-bold text-white bg-pink-500 rounded" onClick={() => buyNFT(nft)}>Buy</button>
                </div>
              </div>
            ))
          }
        </div>
            </div>
        </div>
    );
}