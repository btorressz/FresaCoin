# FresaCoin

**FresaCoin** is an Ethereum-based token that combines staking, governance, and lottery functionalities. This project has a Solana version as well and I wanted to make a eth concept for it so I trasnlated it to Solidity for eth purposes. This project was made in Remix IDE. 

## Features

### 1. ERC20 Token

FresaCoin is an ERC20 token with the following specifications:

- **Token Name**: FresaCoin
- **Symbol**: FRESA
- **Initial Supply**: Minted at deployment.

### 2. Staking Pool

Users can stake their FresaCoin tokens to earn rewards based on:

- **Reward Rate**: A configurable percentage.
- **Lock Duration**: The minimum staking duration to avoid penalties.

Key functionalities include:

- Reward accumulation based on staking duration.
- Referral bonuses for onboarding new users.
- Penalties for early withdrawal.

### 3. Governance

FresaCoin supports decentralized governance, where token holders can:

- Create proposals.
- Vote on proposals using their staked tokens as voting weight.
- Automatically approve proposals based on vote outcomes.

### 4. Lottery

A fun and engaging lottery system where users can:

- Enter by staking tokens.
- A winner is drawn randomly to receive the prize pool.

### 5. Penalty and Burning

Penalties for early withdrawal, a portion of which is burned to reduce the token supply.

---

## How It Works

### 1. Staking

Users can stake FresaCoin tokens to participate in the staking pool. Staking rewards are calculated dynamically based on:

- The amount staked.
- The duration of staking.

Rewards increase for long-term and larger stakes, following the reward rate defined at deployment.

### 2. Governance

Token holders can create proposals to suggest changes or improvements. Other users can vote on these proposals, with their voting power determined by the amount they have staked.

### 3. Lottery

Users can enter the lottery by staking tokens. The prize pool grows with each entry, and a winner is selected randomly, receiving the entire prize pool.

---

## Contract Overview

### Contract: FresaCoin

#### Key State Variables:
- **Staking Pool**: Manages the total staked tokens and reward configuration.
- **Proposals**: Stores governance proposals.
- **Lottery**: Tracks lottery entries and prize pool.

#### Events:
- **Staked**: Emitted when a user stakes tokens.
- **Withdrawn**: Emitted when a user withdraws tokens (with or without penalties).
- **ProposalCreated**: Emitted when a governance proposal is created.
- **Voted**: Emitted when a user votes on a proposal.
- **LotteryEntered**: Emitted when a user enters the lottery.
- **LotteryWinner**: Emitted when a lottery winner is drawn.
