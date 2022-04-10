//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SynergyDAO is IERC721Receiver {
    struct Member {
        bool isJoined;
        uint256 tokensOwned;
    }

    enum ProposalType {
        BUY,
        SELL,
        STAKE,
        ISSUE_COLLATERAL,
        ALLOW_BUSINESS_USAGE
    }

    enum VoteType {
        YES,
        NO
    }

    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        address contractAddress;
        bool executed;
        ProposalType proposalType;
        mapping(address => bool) voters;
    }

    uint256 private _totalGovTokens;
    uint256 public numProposals;
    mapping(address => Member) public members;
    mapping(uint256 => Proposal) public proposals;

    modifier memberOnly() {
        require(members[msg.sender].isJoined == true, "Not a member!");
        _;
    }

    constructor() {
        _totalGovTokens = 10000;
    }

    //basic DAO operations............
    function totalBalance() external view returns (uint256) {
        return _totalGovTokens;
    }

    function isMember() external view returns (bool) {
        return members[msg.sender].isJoined;
    }

    function join() public returns (uint256) {
        require(members[msg.sender].isJoined == false, "Already a member!");
        members[msg.sender] = Member({isJoined: true, tokensOwned: 10});
        _totalGovTokens -= 10;
        return members[msg.sender].tokensOwned;
    }

    function leave() external memberOnly {
        require(members[msg.sender].isJoined == true, "Not a member!");
        members[msg.sender].isJoined = false;
        _totalGovTokens += members[msg.sender].tokensOwned;
        members[msg.sender].tokensOwned = 0;
    }

    // xxxxxxxx------Basic DAO operations---------xxxxxxxxxx

    function createProposal(
        address nftContractAddress,
        uint256 _forTokenId,
        ProposalType _proposalType
    ) external memberOnly returns (uint256) {
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _forTokenId;
        proposal.contractAddress = nftContractAddress;
        proposal.deadline = block.timestamp + 2 minutes;
        proposal.proposalType = _proposalType;

        numProposals++;

        return numProposals;
    }

    function voteOnProposal(uint256 _proposalId, VoteType _vote)
        external
        memberOnly
    {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.deadline > block.timestamp, "INACTIVE_PROPOSAL");
        require(proposal.voters[msg.sender] == false, "ALREADY_VOTED");

        proposal.voters[msg.sender] = true;

        if (_vote == VoteType.YES) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }

        members[msg.sender].tokensOwned -= 1;
    }

    function executeProposal(uint256 _proposalId) external memberOnly {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.deadline <= block.timestamp, "ACTIVE_PROPOSAL");
        require(proposal.executed == false, "ALREADY_EXECUTED");

        proposal.executed = true;
        if (proposal.yesVotes > proposal.noVotes) {
            if (proposal.proposalType == ProposalType.BUY) {
                buyNFT(proposal);
            }
        }
    }

    function buyNFT(Proposal storage ps) internal {
        IERC721 nftContract = IERC721(ps.contractAddress);
        address presentOwner = nftContract.ownerOf(ps.nftTokenId);
        nftContract.safeTransferFrom(
            presentOwner,
            address(this),
            ps.nftTokenId
        );
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
