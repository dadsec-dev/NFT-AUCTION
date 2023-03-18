// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
contract Auction {
    
   address public owner;
    
    struct Auction {
        uint128 startBlock;
        uint128 endBlock;
        address  auctionCreator;
        address auctionedItem;
        address highestBidder;
        uint highestBid;
        uint itemID;
        bool started;
        
    }
uint id;
mapping(uint => Auction) public auctionID;
mapping(address =>mapping( uint => uint)) public userBidAMount;

    error invalidBlock();
    error  notStarted();
    constructor() {
        owner = msg.sender;
    }


    function createAuction(uint128 _startBlock, uint128 _endBlock, address _auctionItem, uint256 _nftID)external{
        require(_auctionItem != address(0));

        if(_endBlock<= _startBlock) revert invalidBlock();
        Auction storage auction = auctionID[id];
        auction.startBlock = _startBlock;
        auction.endBlock = _endBlock;
        auction.auctionCreator = msg.sender;
        auction.auctionedItem = _auctionItem;
        auction.started = true;
        auction.itemID = _nftID;
        IERC721(_auctionItem).transferFrom(msg.sender, address(this), _nftID);
        id++; 


    }
    function bid(uint256 _auctionID) external payable {
        require(msg.value != 0, "empty value");
        require(msg.sender != owner, "Ole");
        
        Auction storage auction =  auctionID[_auctionID];
       if(auction.started) revert notStarted();
       require(msg.sender != auction.auctionCreator);
       userBidAMount[msg.sender][_auctionID] = msg.value;
        if(msg.value > auction.highestBid) {
            auction.highestBid = msg.value;
            auction.highestBidder = msg.sender;
       }
       
        
    }
    // function updatebBid() external payable {
    //     userBid[msg.sender] += msg.value;
    // }









    function isOwner() internal view {
        require(msg.sender == owner);
    }
}
