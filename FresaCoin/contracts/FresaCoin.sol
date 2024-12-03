// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title FresaCoin - Ethereum version 
contract FresaCoin is ERC20, Ownable {
    struct Stake {
        uint256 amount; // Amount staked
        uint256 rewardAccumulated; // Accumulated rewards
        uint256 lastStakedTimestamp; // Timestamp of the last stake
        address referrer; // Address of the referrer, if applicable
    }

    struct Proposal {
        string description; // Proposal description
        uint256 votesFor; // Number of votes in favor
        uint256 votesAgainst; // Number of votes against
        bool isApproved; // Whether the proposal is approved
    }

    struct Lottery {
        address[] entries; // List of lottery participants
        uint256 prizePool; // Prize pool for the lottery
    }

    struct StakingPool {
        uint256 rewardRate; // Reward rate for staking
        uint256 lockDuration; // Lock duration for staking
        uint256 totalStaked; // Total staked in the pool
    }

    mapping(address => Stake) public stakes; // Mapping of user stakes
    mapping(uint256 => Proposal) public proposals; // Governance proposals
    Lottery public lottery; // Lottery details
    StakingPool public stakingPool; // Staking pool state
    uint256 public proposalCounter; // Counter for proposals

    uint256 public minStakeDuration = 7 days; // Minimum staking duration
    uint256 public constant REFERRAL_BONUS = 5; // Referral bonus (5%)

    event Staked(address indexed user, uint256 amount, address indexed referrer);
    event Withdrawn(address indexed user, uint256 amount, uint256 penalty);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool voteFor);
    event LotteryEntered(address indexed user, uint256 amount);
    event LotteryWinner(address indexed winner, uint256 prize);

    /// @notice Constructor to initialize the contract
    /// @param _initialSupply Initial token supply
    /// @param _rewardRate Reward rate for staking
    /// @param _lockDuration Lock duration for staking
    constructor(
        uint256 _initialSupply,
        uint256 _rewardRate,
        uint256 _lockDuration
    ) ERC20("FresaCoin", "FRESA") Ownable(msg.sender) {
        _mint(msg.sender, _initialSupply); // Mint initial supply
        stakingPool.rewardRate = _rewardRate;
        stakingPool.lockDuration = _lockDuration;
    }

    /// @notice Stake tokens to earn rewards
    /// @param amount Amount of tokens to stake
    /// @param referrer Optional referrer address
    function stake(uint256 amount, address referrer) external {
        require(amount > 0, "Cannot stake zero tokens");
        _transfer(msg.sender, address(this), amount);

        Stake storage userStake = stakes[msg.sender];
        uint256 currentTime = block.timestamp;

        // Calculate rewards for existing stake
        if (userStake.amount > 0) {
            uint256 duration = currentTime - userStake.lastStakedTimestamp;
            userStake.rewardAccumulated += calculateReward(userStake.amount, duration);
        }

        userStake.amount += amount;
        userStake.lastStakedTimestamp = currentTime;

        // Referral bonus
        if (referrer != address(0) && referrer != msg.sender) {
            uint256 bonus = (amount * REFERRAL_BONUS) / 100;
            _mint(referrer, bonus);
            userStake.referrer = referrer;
        }

        stakingPool.totalStaked += amount;

        emit Staked(msg.sender, amount, referrer);
    }

    /// @notice Withdraw staked tokens with penalty if applicable
    /// @param amount Amount to withdraw
    function withdraw(uint256 amount) external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "Insufficient staked balance");

        uint256 currentTime = block.timestamp;
        uint256 duration = currentTime - userStake.lastStakedTimestamp;

        uint256 penalty = 0;
        if (duration < minStakeDuration) {
            penalty = (amount * 20) / 100; // 20% penalty
            _burn(address(this), penalty / 2); // Burn 50% of the penalty
        }

        uint256 netAmount = amount - penalty;
        userStake.amount -= amount;
        stakingPool.totalStaked -= amount;

        _transfer(address(this), msg.sender, netAmount);

        emit Withdrawn(msg.sender, netAmount, penalty);
    }

    /// @notice Create a governance proposal
    /// @param description Description of the proposal
    function createProposal(string memory description) external onlyOwner {
        proposalCounter++;
        proposals[proposalCounter] = Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            isApproved: false
        });

        emit ProposalCreated(proposalCounter, description);
    }

    /// @notice Vote on a governance proposal
    /// @param proposalId ID of the proposal
    /// @param voteFor True to vote for, false to vote against
    function vote(uint256 proposalId, bool voteFor) external {
        Proposal storage proposal = proposals[proposalId];
        require(bytes(proposal.description).length > 0, "Invalid proposal ID");

        uint256 votingWeight = stakes[msg.sender].amount;
        require(votingWeight > 0, "No staked tokens to vote");

        if (voteFor) {
            proposal.votesFor += votingWeight;
        } else {
            proposal.votesAgainst += votingWeight;
        }

        proposal.isApproved = proposal.votesFor > proposal.votesAgainst;

        emit Voted(proposalId, msg.sender, voteFor);
    }

    /// @notice Enter the lottery by staking tokens
    /// @param amount Amount of tokens to stake for the lottery
    function enterLottery(uint256 amount) external {
        require(amount > 0, "Cannot enter with zero tokens");

        _transfer(msg.sender, address(this), amount);
        lottery.entries.push(msg.sender);
        lottery.prizePool += amount;

        emit LotteryEntered(msg.sender, amount);
    }

    /// @notice Draw a winner for the lottery
    function drawLotteryWinner() external onlyOwner {
        require(lottery.entries.length > 0, "No participants in the lottery");

        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % lottery.entries.length;
        address winner = lottery.entries[randomIndex];

        uint256 prize = lottery.prizePool;
        lottery.prizePool = 0;
        delete lottery.entries;

        _transfer(address(this), winner, prize);

        emit LotteryWinner(winner, prize);
    }

    /// @notice Get lottery participants
    /// @return List of participants
    function getLotteryEntries() external view returns (address[] memory) {
        return lottery.entries;
    }

    /// @notice Get the prize pool for the lottery
    /// @return Prize pool amount
    function getLotteryPrizePool() external view returns (uint256) {
        return lottery.prizePool;
    }

    /// @notice Calculate reward based on stake and duration
    /// @param amount Amount staked
    /// @param duration Duration of the stake
    /// @return reward Calculated reward
    function calculateReward(uint256 amount, uint256 duration)
        public
        view
        returns (uint256 reward)
    {
        uint256 baseRate = (amount > 10_000 ether) ? 15 : (amount > 1_000 ether) ? 12 : 10;
        uint256 multiplier = (duration > 30 days) ? 2 : 1;

        reward = (amount * baseRate / 100) * multiplier;
    }
}
