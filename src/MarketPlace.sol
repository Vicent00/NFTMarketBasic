// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";


contract MarketPlace is Ownable, ReentrancyGuard {


// Structs 
 struct Listing {

    address seller;
    address nftAddress;
    uint256 tokenId;
    uint256 price;
 }


mapping (address => mapping(uint256 => Listing)) public listing;

// Events
 

constructor () Ownable(msg.sender) {}



// Listing Function

function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external nonReentrant {
// Requires

// Chech if the NFT is real from seller
address seller = IERC721(nftAddress_).ownerOf(tokenId_);
require(seller == msg.sender, "You are not the owner of this NFT");
// Check the price of Nft
require(price_ > 0, "Price must be greater than 0");



Listing memory listing_ = Listing({
    seller: msg.sender,
    nftAddress: nftAddress_,
    tokenId: tokenId_,
    price: price_
});

listing[nftAddress_][tokenId_] = listing_;



}






// Buy Function


function buyNFT (address nftAddress_, uint256 tokenId_) external payable nonReentrant {
    // Requires
    // Check if the NFT is listed for sale
    Listing memory listing_ = listing[nftAddress_][tokenId_];
    require(listing_.price > 0, "NFT is not listed for sale");
    // Check if the price is correct
    require(msg.value == listing_.price, "Incorrect price sent");
    

    // Delete the listing from marketplace

    delete listing[nftAddress_][tokenId_];

    // Transfer the NFT to the buyer
    IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, tokenId_);
    
    
    // Transfer the payment to the seller
(bool sent, ) = listing_.seller.call{ value: msg.value}("");
require(sent, "Failed to send Ether");

}





// Cancel Function


function cancelListing(address nftAddress_, uint256 tokenId_) external nonReentrant {
    // Requires 
    // Check if the NFT is listed for sale
    Listing memory listing_ = listing[nftAddress_][tokenId_];
    require(listing_.price > 0, "NFT is not listed for sale");
    // Check if the seller is the owner of the NFT
    require(listing_.seller == msg.sender, "You are not the owner of this NFT");
    // Delete the listing from marketplace
    delete listing[nftAddress_][tokenId_];


}



// Get Listing Function to show the listing of the NFT is showed the price and the seller

function getListing(address nftAddress_, uint256 tokenId_) external view returns (address, uint256) {
    // Requires
    // Check if the NFT is listed for sale
    Listing memory listing_ = listing[nftAddress_][tokenId_];
    require(listing_.price > 0, "NFT is not listed for sale");
    
    
    return (listing_.seller, listing_.price);



}

}


















