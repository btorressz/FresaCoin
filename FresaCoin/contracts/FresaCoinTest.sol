// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./FresaCoin.sol";

/// @title FresaCoinTest - A test contract for FresaCoin
contract FresaCoinTest {
    FresaCoin public fresaCoin;

    /// @notice Deploy a new FresaCoin contract for testing
    /// @param initialSupply The initial token supply
    /// @param rewardRate Reward rate for staking
    /// @param lockDuration Lock duration for staking
    constructor(uint256 initialSupply, uint256 rewardRate, uint256 lockDuration) {
        fresaCoin = new FresaCoin(initialSupply, rewardRate, lockDuration);
    }

    /// @notice Test staking tokens
    /// @param amount Amount of tokens to stake
    /// @param referrer Referrer address
    function testStake(uint256 amount, address referrer) external {
        // Approve tokens for transfer
        fresaCoin.approve(address(fresaCoin), amount);

        // Stake tokens
        fresaCoin.stake(amount, referrer);
    }

    /// @notice Test withdrawing staked tokens
    /// @param amount Amount of tokens to withdraw
    function testWithdraw(uint256 amount) external {
        fresaCoin.withdraw(amount);
    }

    /// @notice Test creating a governance proposal
    /// @param description Description of the proposal
    function testCreateProposal(string memory description) external {
        fresaCoin.createProposal(description);
    }

    /// @notice Test voting on a proposal
    /// @param proposalId ID of the proposal
    /// @param voteFor True to vote for, false to vote against
    function testVote(uint256 proposalId, bool voteFor) external {
        fresaCoin.vote(proposalId, voteFor);
    }

    /// @notice Test entering the lottery
    /// @param amount Amount of tokens to stake for the lottery
    function testEnterLottery(uint256 amount) external {
        // Approve tokens for transfer
        fresaCoin.approve(address(fresaCoin), amount);

        // Enter the lottery
        fresaCoin.enterLottery(amount);
    }

    /// @notice Test drawing a lottery winner
    function testDrawLotteryWinner() external {
        fresaCoin.drawLotteryWinner();
    }

    /// @notice Get the details of a proposal
    /// @param proposalId ID of the proposal
    /// @return description Description of the proposal
    /// @return votesFor Number of votes in favor
    /// @return votesAgainst Number of votes against
    /// @return isApproved Whether the proposal is approved
    function getProposal(uint256 proposalId)
        external
        view
        returns (
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            bool isApproved
        )
    {
        (description, votesFor, votesAgainst, isApproved) = fresaCoin.proposals(proposalId);
    }

    /// @notice Get lottery entries
    /// @return entries List of participants
    function getLotteryEntries() external view returns (address[] memory entries) {
        return fresaCoin.getLotteryEntries();
    }

    /// @notice Get the lottery prize pool
    /// @return prizePool Total prize pool
    function getLotteryPrizePool() external view returns (uint256 prizePool) {
        return fresaCoin.getLotteryPrizePool();
    }
}
