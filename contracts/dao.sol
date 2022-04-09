//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract SynergyDAO {
    struct Member {
        bool isJoined;
        uint256 tokensOwned;
    }

    uint256 private _totalGovTokens;
    mapping(address => Member) public memberGovTokenMap;

    constructor() {
        _totalGovTokens = 10000;
    }

    function totalBalance() external view returns (uint256) {
        return _totalGovTokens;
    }

    function isMember() external view returns (bool) {
        return memberGovTokenMap[msg.sender].isJoined;
    }

    function join() public returns (uint256) {
        require(
            memberGovTokenMap[msg.sender].isJoined == false,
            "Already a member!"
        );
        memberGovTokenMap[msg.sender] = Member({
            isJoined: true,
            tokensOwned: 10
        });
        _totalGovTokens -= 10;
        return memberGovTokenMap[msg.sender].tokensOwned;
    }

    function leave() external {
        require(
            memberGovTokenMap[msg.sender].isJoined == true,
            "Not a member!"
        );
        memberGovTokenMap[msg.sender].isJoined = false;
        _totalGovTokens += memberGovTokenMap[msg.sender].tokensOwned;
        memberGovTokenMap[msg.sender].tokensOwned = 0;
    }
}
