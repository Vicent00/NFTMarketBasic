// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/MarketPlace.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract TestNFT is ERC721 {
  constructor() ERC721("TestNFT", "TNFT") {}

    function mintNFT( address to_ , uint256 tokenId_) external {
    _mint(to_, tokenId_);    
    }

}

contract MarketPlaceTest is Test {

MarketPlace marketPlace;
TestNFT testNFT; 

address deployer = vm.addr(1);
address user = vm.addr(2);
uint256 tokenId = 0;
function setUp() public {
vm.startPrank(deployer);

testNFT = new TestNFT();
marketPlace = new MarketPlace();
vm.stopPrank();

vm.startPrank(user);
testNFT.mintNFT(user, tokenId);
vm.stopPrank();

}


    function testMintNFT() public view {

    address ownerOfNFT = testNFT.ownerOf(tokenId);
    assert(ownerOfNFT == user);

    }

    function testListNFT() public {
vm.startPrank(user);
 
 (address sellerBefore,,,) = marketPlace.listing(address(testNFT), tokenId);
 marketPlace.listNFT(address(testNFT), tokenId,  1e18);
    (address sellerAfter,,,) = marketPlace.listing(address(testNFT), tokenId);

assert( sellerBefore == address(0) && sellerAfter == user);
vm.stopPrank();


    }

function testCancelListing() public {
    vm.startPrank(user);
    
    marketPlace.listNFT( address(testNFT), tokenId, 1e18);
    (address sellerAfter,,,) = marketPlace.listing(address(testNFT), tokenId);

    assert(sellerAfter == user);
    marketPlace.cancelListing(address(testNFT), tokenId);

    (address sellerAfterCancel,,,) = marketPlace.listing(address(testNFT), tokenId);
    assert(sellerAfterCancel == address(0));



}

function testGetListingCorrect() public {
vm.startPrank(user);
uint256 price_ = 1e18;

    marketPlace.listNFT( address(testNFT), tokenId, price_);
    (address sellerAfter,,,uint256 price) = marketPlace.listing(address(testNFT), tokenId);
    

    marketPlace.getListing(address(testNFT), tokenId);
assert( sellerAfter == user && price == 1e18);
    
vm.stopPrank();

}


function testBuyNFTcorrect() public{
vm.startPrank(user);
uint256 price_ = 1e18;

    marketPlace.listNFT( address(testNFT), tokenId, price_);
    testNFT.approve(address(marketPlace), tokenId);

vm.stopPrank();

address user2 = vm.addr(3);


vm.startPrank(user2);
vm.deal(user2, 1e18);
  // BE SURE THAT USER2 HAS ENOUGH ETH TO BUY THE NFT
uint256 balanceAfterUser2 = address(user2).balance;

// Check that the NFT is listed for sale
    (address sellerAfter,,,uint256 price) = marketPlace.listing(address(testNFT), tokenId);

  marketPlace.buyNFT{value: price_}(address(testNFT), tokenId);
    // Check that the NFT is transferred to user2
address ownerNFT = testNFT.ownerOf(tokenId);




    assert(balanceAfterUser2 == 1e18);
    assert(sellerAfter == user && price == 1e18);


vm.stopPrank();

}








}