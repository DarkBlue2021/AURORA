![Logo](/pitch-deck/Aurora_logo.png)

# AURORA Protocol

### Babylon-Secured Carbon Credit Certification & Farming Investment Platform

AURORA Protocol is a blockchain-based platform aimed at transforming carbon credit certification and investment in the agriculture sector. Built on secure, decentralized technologies, AURORA leverages **Babylon Bitcoin staking** and the **Rooch Network** to enable efficient, scalable, and accessible carbon credit investments for a sustainable future.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Rooch Network Integration](#rooch-network-integration)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

The AURORA Protocol addresses the high costs, limited liquidity, and access barriers to carbon credit certification, especially for small-scale farmers. Through Bitcoin staking with Babylon, it secures liquidity and returns for investors, while Rooch Network provides scalable, cross-chain smart contract execution to streamline transactions and optimize data flow.

---

## Key Features

- **Low-Cost Carbon Credit Certification**: Efficiently certifies carbon credits, making it accessible to smaller agricultural projects.
- **Bitcoin-Backed Yield Generation**: Uses Babylon Bitcoin staking to generate yields, ensuring liquidity and high returns for investors.
- **Scalability via Rooch Network**: Facilitates modular, high-volume smart contract execution to accommodate growth and cross-chain operability.
- **Smart Contracts for Investment & Return**: Securely manages investment cycles with two core smart contracts for streamlined returns.

---

## Architecture

1. **Invest Smart Contract**: Manages initial carbon credit investments, allocates funds for certification, and interfaces with Babylon for staking.
2. **Return Smart Contract**: Distributes returns to investors, pulling yield data from Babylon and executing distributions via Rooch Network.
3. **Babylon Staking Integration**: Generates staking yields from invested Bitcoin, which are processed and distributed to investors.
4. **Rooch Network**: Provides execution for high-volume transactions, ensuring real-time data flow, scalability, and interoperability.

---

## Rooch Network Integration

The AURORA Protocol integrates with the **Rooch Network** as a critical component of its architecture:

- **Stackable Layer 2 Solution**: Rooch Network offers a Layer 2 (L2) solution designed for building off-chain, Bitcoin-centric applications that are scalable and efficient, allowing AURORA to handle high transaction volumes.
- **On-Chain State Access**: AURORA benefits from Rooch's ability to access Bitcoin’s complete on-chain state directly within smart contracts, simplifying the investment process by eliminating the need for bridging.
- **Cross-Layer Asset Migration**: The Rooch Network enables seamless migration of assets between Layer 1 (L1) and L2, allowing flexible asset management within AURORA.
- **MoveVM & VApp Container**: Using Rooch’s MoveVM-based VApp Container, AURORA can build verifiable applications that ensure secure and transparent operations, crucial for carbon credit certification and returns distribution.

With Rooch Network, AURORA Protocol provides a robust and scalable environment to manage carbon credit investments backed by Bitcoin, enhancing liquidity and investor confidence.

---

## Prerequisites

- **Node.js** (v14.x or later)
- **npm** or **yarn**
- **Solidity** (for smart contract development)
- **Rooch CLI** (for deploying and managing contracts on the Rooch Network)
- **Babylon API Access** (for accessing staking yield data)

---

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/yourusername/AURORA-Protocol.git
cd AURORA-Protocol

node scripts/invest.js --amount 100 --project-id 1

---

## Example: Invest Smart Contact 

This contract includes functions for initializing investments, tracking investors' contributions, and allocating funds to carbon credit projects.

// Invest.move

module AuroraProtocol::InvestSmartContract {

    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::Coin;
    
    // Define the structure for an investment record
    struct InvestmentRecord has store {
        investor: address,
        amount: u64,
        timestamp: u64,
    }

    // Define a resource to hold all investments
    struct InvestmentPortfolio has key {
        total_invested: u64,
        investments: vector<InvestmentRecord>,
    }

    // Define an event for investment activity
    struct InvestmentEvent has copy, drop {
        investor: address,
        amount: u64,
        timestamp: u64,
    }

    // Initialize the event handle for tracking investments
    public fun new_portfolio(account: &signer) {
        move_to<InvestmentPortfolio>(account, InvestmentPortfolio {
            total_invested: 0,
            investments: vector::empty<InvestmentRecord>(),
        });
    }

    // Function to make an investment
    public fun invest(account: &signer, amount: u64) acquires InvestmentPortfolio {
        let investor_address = Signer::address_of(account);

        // Ensure the investor has sufficient funds
        Coin::withdraw(account, amount);

        // Log the investment with a timestamp
        let investment_record = InvestmentRecord {
            investor: investor_address,
            amount,
            timestamp: Timestamp::now(),
        };

        // Add investment to portfolio
        let portfolio = borrow_global_mut<InvestmentPortfolio>(investor_address);
        vector::push_back(&mut portfolio.investments, investment_record);
        portfolio.total_invested = portfolio.total_invested + amount;

        // Emit an investment event
        Event::emit<InvestmentEvent>(
            &portfolio.investments,
            InvestmentEvent {
                investor: investor_address,
                amount,
                timestamp: Timestamp::now(),
            },
        );
    }

    // Function to view total investment for a specific investor
    public fun get_total_invested(account: address): u64 acquires InvestmentPortfolio {
        let portfolio = borrow_global<InvestmentPortfolio>(account);
        portfolio.total_invested
    }

    // Withdraw function for returning funds (partial or complete)
    public fun withdraw(account: &signer, amount: u64) acquires InvestmentPortfolio {
        let investor_address = Signer::address_of(account);
        let portfolio = borrow_global_mut<InvestmentPortfolio>(investor_address);

        assert!(portfolio.total_invested >= amount, 0x1); // Ensure sufficient balance
        portfolio.total_invested = portfolio.total_invested - amount;

        // Transfer back to the investor
        Coin::deposit(account, amount);
    }
}
---
## Example: Return Smart Contact 

This contract manages the distribution of returns, including Bitcoin staking yields from Babylon, to investors in the AURORA Protocol.

// Return.move

module AuroraProtocol::ReturnSmartContract {

    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::Coin;
    use 0x1::Vector;
    
    // Struct to represent an investor's return record
    struct ReturnRecord has store {
        investor: address,
        amount: u64,
        yield_amount: u64,
        timestamp: u64,
    }

    // Resource to hold return records for all investors
    struct ReturnPortfolio has key {
        total_returned: u64,
        return_records: vector<ReturnRecord>,
    }

    // Event to emit when a return is distributed
    struct ReturnEvent has copy, drop {
        investor: address,
        amount: u64,
        yield_amount: u64,
        timestamp: u64,
    }

    // Function to initialize a new return portfolio for an investor
    public fun new_return_portfolio(account: &signer) {
        move_to<ReturnPortfolio>(account, ReturnPortfolio {
            total_returned: 0,
            return_records: vector::empty<ReturnRecord>(),
        });
    }

    // Function to distribute returns to investors
    public fun distribute_return(account: &signer, amount: u64, yield_amount: u64) acquires ReturnPortfolio {
        let investor_address = Signer::address_of(account);

        // Ensure the smart contract has sufficient funds
        Coin::withdraw(account, amount + yield_amount);

        // Create a return record with the current timestamp
        let return_record = ReturnRecord {
            investor: investor_address,
            amount,
            yield_amount,
            timestamp: Timestamp::now(),
        };

        // Update the return portfolio with the new return record
        let portfolio = borrow_global_mut<ReturnPortfolio>(investor_address);
        vector::push_back(&mut portfolio.return_records, return_record);
        portfolio.total_returned = portfolio.total_returned + amount + yield_amount;

        // Emit a return event
        Event::emit<ReturnEvent>(
            &portfolio.return_records,
            ReturnEvent {
                investor: investor_address,
                amount,
                yield_amount,
                timestamp: Timestamp::now(),
            },
        );

        // Deposit the return amount and yield back into the investor's account
        Coin::deposit(account, amount + yield_amount);
    }

    // Function to view total returns for an investor
    public fun get_total_returned(account: address): u64 acquires ReturnPortfolio {
        let portfolio = borrow_global<ReturnPortfolio>(account);
        portfolio.total_returned
    }
}







