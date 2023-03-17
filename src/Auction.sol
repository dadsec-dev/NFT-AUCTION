// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BlindAuction {
using SafeMath for uint256;
// Structure to hold information about a bid
struct Bid {
    address payable bidder; // Ethereum address of the bidder
    uint256 amount; // Amount of ether bid
}

address payable public owner; // Ethereum address of the contract owner
IERC721 public nft; // ERC721 token being auctioned
uint256 public startBlock; // Block number when auction starts
uint256 public endBlock; // Block number when auction ends

Bid[] public bids; // Array to hold all the bids
mapping(address => bytes32) public blindedBids; // Mapping to hold blinded bids

// Constructor function to set initial values
constructor(IERC721 _nft, uint256 _startBlock, uint256 _endBlock) {
    owner = payable(msg.sender);
    nft = _nft;
    startBlock = _startBlock;
    endBlock = _endBlock;
}

// Function to place a blinded bid
function placeBid(bytes32 _blindedBid) public payable {
    require(block.number >= startBlock && block.number <= endBlock, "Auction is not active");
    require(msg.value > 0, "Bid amount must be greater than zero");
    require(blindedBids[msg.sender] == 0, "You have already placed a bid");

    blindedBids[msg.sender] = _blindedBid;
    bids.push(Bid(payable(msg.sender), msg.value));
}

// Function to reveal a blinded bid
function revealBid(uint256 _value, bytes32 _secret) public {
    require(block.number > endBlock, "Auction is still active");
    require(blindedBids[msg.sender] != 0, "You have not placed a bid");
    require(_value == bids[bids.length - 1].amount, "Invalid value");
    
    bytes32 hash = keccak256(abi.encodePacked(_value, _secret));
    require(hash == blindedBids[msg.sender], "Invalid secret");

    bids[bids.length - 1].bidder.transfer(_value);
    nft.transferFrom(address(this), bids[bids.length - 1].bidder, nft.tokenOfOwnerByIndex(owner, 0));
}

// Function to end the auction and transfer the NFT to the highest bidder
function endAuction() public {
    require(block.number > endBlock, "Auction is still active");
    require(msg.sender == owner, "Only the owner can end the auction");
    
    uint256 highestBid = 0;
    address payable highestBidder;

    for (uint256 i = 0; i < bids.length; i++) {
        if (bids[i].amount > highestBid) {
            highestBid = bids[i].amount;
            highestBidder = bids[i].bidder;
        }
    }

    nft.transferFrom(address(this), highestBidder, nft.tokenOfOwnerByIndex(owner, 0));
    owner.transfer(address(this).balance);
}

}