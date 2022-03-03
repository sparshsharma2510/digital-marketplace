// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

/**
Inheritance tree:

    ERC721
       ⬇
    ERC721URI
       ⬇
      NFT
*/

contract NFT is ERC721URIStorage{
    //Counter is a struct from the Counters contract
    //and is defined as follows: struct Counter{uint256 _value;} 
    //and this value is accessed via current() method
    //and if we want to reset the value, we can do it via reset method
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;
    address contractAddress;

    constructor(address _marketPlace) ERC721("Metaverse Tokens","METT"){
        contractAddress = _marketPlace;
    }
    //tokenURI contains the IPFS hash/URL received on uploading the document
    function createToken(string memory tokenURI) public returns(uint){
        tokenId.increment();
        uint newId = tokenId.current();

        //_mint() is a function avaliable in ERC721 contract
        //_mint(owner, tokenID)
        //the mint function has two checks in it
        //1. the address of the owner should not be zero
        //2. the tokenId should not be exisiting in the contract before
        _mint(msg.sender, newId);
        // console.log("msg sender: " ,msg.sender);
        //Set the tokenURI for this newly created token
        _setTokenURI(newId, tokenURI);
        //Allows the contract to trade this token from another contracts as well
        setApprovalForAll(contractAddress, true);

        return newId;
    }
}