// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private itemIds;
    Counters.Counter private itemsSold;

    address payable owner;
    uint listingPrice = 0.025 ether;

    //Grouping same data types in struct will consume less gas
    struct MarketItem{
        bool sold;
        uint price;
        uint itemId;
        uint tokenId;
        address nftContract;
        address payable seller;
        address payable owner;
    }

    mapping(uint => MarketItem) private idToMarketItem;

    event MarketItemCreated (
        bool sold,
        uint price,
        uint indexed itemId,
        uint indexed tokenId,
        address indexed nftContract,
        address seller,
        address owner
    );

    constructor(){
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns(uint){
        return listingPrice;
    }
    //nonReentrant modifier makes sure that no function re-entrancy(kind of like recursive calls)
    //is made so as to avoid the functions being called again in an inconsistent state(re-entry attack)
    function createMarketItem(address _nftContract, uint _tokenId, uint _priceOfNFT) public payable nonReentrant{
        require(_priceOfNFT >= 1 ether, "Price should be at least 1 ETH");
        require(msg.value == listingPrice, "Amount sent should be equal to listingPrice(0.025 ETH)");
        
        itemIds.increment();
        uint newId = itemIds.current();

        idToMarketItem[newId] = MarketItem(false,
                                _priceOfNFT,
                                newId,
                                _tokenId,
                                _nftContract,
                                payable(msg.sender),
                                payable(address(0)));
        //Since, we haven't inheritied/imported the ERC721 contract thus to call the functions
        //availble in the ERC721 contract, we are using the IERC721 interface to trasnfer the 
        //ownership of this token to the current contract address
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        emit MarketItemCreated (
            false,
            _priceOfNFT,
            newId,
            _tokenId,
            _nftContract,
            msg.sender,
            address(0)
        );
    }
    //function to buy an nft from the marketplace
    function createMarketSale(address _nftContract, uint _itemId) public payable nonReentrant{
        uint price = idToMarketItem[_itemId].price;
        uint tokenId = idToMarketItem[_itemId].tokenId;

        require(msg.value == price, "Please pay the amount asked in order to complete the transaction");
        
        //Transfer the price of the nft token to the seller
        idToMarketItem[_itemId].seller.transfer(msg.value);

        //Trasnfer the owner ship of the minted token from this contract address to the buyer
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);
        
        //Update the owner in the state mapping
        idToMarketItem[_itemId].owner = payable(msg.sender);
        
        itemsSold.increment();
        
        //Send the owner of the contract his/her commission
        payable(owner).transfer(listingPrice);
    }

    function fetchMarketItems() public view returns(MarketItem[] memory){
        uint itemCount = itemIds.current();
        uint unsoldItemCount = itemIds.current() - itemsSold.current();
        uint currentIdx = 0;

        MarketItem[] memory availableItems = new MarketItem[](unsoldItemCount);
        for(uint i = 0; i < itemCount; i++){
            if(idToMarketItem[i+1].owner == address(0)){
                //WHy doing like this
                //why not this => availableItems[currentIdx] = idToMarketItem[i+1];
                MarketItem storage currentItem = idToMarketItem[idToMarketItem[i+1].itemId];
                availableItems[currentIdx] = currentItem;
                currentIdx++;
            }
        }

        return availableItems;
    }

    function fetchMyNFTs() public view returns(MarketItem[] memory){
        uint itemOwnedCount = 0;
        uint itemCount = itemIds.current();
        uint currentIdx = 0;

        for(uint i = 0; i < itemCount; i++){
            if(idToMarketItem[i+1].owner == msg.sender)
                itemOwnedCount++;
        }

        MarketItem[] memory myNFTs = new MarketItem[](itemOwnedCount);
        for(uint i = 0; i < itemCount; i++){
            if(idToMarketItem[i+1].owner == msg.sender){
                MarketItem storage currentItem = idToMarketItem[idToMarketItem[i+1].itemId];
                myNFTs[currentIdx] = currentItem;
                currentIdx++;
            }
        }

        return myNFTs;
    }

    function fetchItemsCreated() public view returns(MarketItem[] memory){
        uint itemOwnedCount = 0;
        uint itemCount = itemIds.current();
        uint currentIdx = 0;

        for(uint i = 0; i < itemCount; i++){
            if(idToMarketItem[i+1].seller == msg.sender)
                itemOwnedCount++;
        }

        MarketItem[] memory itemsCreated = new MarketItem[](itemOwnedCount);
        for(uint i = 0; i < itemCount; i++){
            if(idToMarketItem[i+1].seller == msg.sender){
                MarketItem storage currentItem = idToMarketItem[idToMarketItem[i+1].itemId];
                itemsCreated[currentIdx] = currentItem;
                currentIdx++;
            }
        }
 
        return itemsCreated;
    }
}