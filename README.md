# StacksFi Protocol

> **Real-World Asset Tokenization Platform on Stacks Layer 2**

[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-orange?style=flat-square)](https://stacks.co)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-f7931a?style=flat-square)](https://bitcoin.org)


StacksFi is a comprehensive DeFi protocol that enables institutional-grade tokenization of real-world assets through Semi-Fungible Tokens (SFTs) on the Stacks blockchain. Built to leverage Bitcoin's security while maintaining enterprise-level performance and compliance standards.

## 🚀 Key Features

- **🏢 Asset Tokenization**: Convert real-world assets into tradeable SFT tokens with configurable fractional ownership
- **💰 Automated Dividends**: Proportional revenue distribution to token holders with on-chain claiming
- **🗳️ Decentralized Governance**: Token-weighted voting system for asset management decisions
- **🛡️ KYC/AML Compliance**: Integrated regulatory compliance framework with multi-level verification
- **📊 Price Oracle Integration**: Real-time asset valuation through trusted oracle feeds
- **🔒 Enterprise Security**: Multi-layered access controls and institutional-grade security measures

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    StacksFi Protocol                        │
├─────────────────────────────────────────────────────────────┤
│  Frontend Applications  │  API Layer  │  Oracle Services    │
├─────────────────────────────────────────────────────────────┤
│                    Smart Contract Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐   │
│  │   Asset     │ │ Governance  │ │     Compliance      │   │
│  │ Management  │ │   System    │ │     Framework       │   │
│  └─────────────┘ └─────────────┘ └─────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                   Stacks Layer 2 Network                   │
├─────────────────────────────────────────────────────────────┤
│                    Bitcoin Blockchain                       │
│                   (Settlement Layer)                        │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Contract Architecture

### Core Components

#### 1. **Asset Registry**

- **Purpose**: Central registry for tokenized real-world assets
- **Key Features**: Metadata management, valuation tracking, ownership records
- **Data Structure**: Asset ID mapping with comprehensive asset information

#### 2. **Token Management System**

- **Purpose**: SFT token balance tracking and ownership management
- **Standard**: Semi-Fungible Token (SFT) implementation
- **Supply**: 100,000 tokens per asset (configurable)

#### 3. **Governance Framework**

- **Purpose**: Decentralized decision-making for asset management
- **Voting Power**: Token-weighted based on ownership percentage
- **Proposal Types**: Asset management, policy changes, revenue distribution

#### 4. **Compliance Engine**

- **Purpose**: KYC/AML regulatory compliance management
- **Verification Levels**: 5-tier KYC system with expiry management
- **Integration**: Seamless compliance checks across all operations

#### 5. **Dividend Distribution**

- **Purpose**: Automated revenue sharing with token holders
- **Calculation**: Proportional distribution based on token ownership
- **Claiming**: On-demand dividend claiming with historical tracking

#### 6. **Price Oracle Integration**

- **Purpose**: Real-time asset valuation and price feeds
- **Data Sources**: Multiple oracle providers with fallback mechanisms
- **Update Frequency**: Configurable update intervals with staleness protection

### Data Flow Architecture

```
Asset Registration → Token Minting → Secondary Trading
         ↓                ↓              ↓
    Governance ← Revenue Generation → Dividend Distribution
         ↓                ↓              ↓
    Price Updates ← Compliance Checks → Oracle Feeds
```

## 🔧 Smart Contract Functions

### Public Functions

| Function | Purpose | Access Level |
|----------|---------|--------------|
| `register-asset` | Register new asset for tokenization | Owner Only |
| `claim-dividends` | Claim proportional dividend payments | Token Holders |
| `create-proposal` | Create governance proposals | 10%+ Token Holders |
| `vote` | Vote on governance proposals | Token Holders |

### Read-Only Functions

| Function | Purpose | Returns |
|----------|---------|---------|
| `get-asset-info` | Asset details and metadata | Asset record |
| `get-balance` | Token balance for address | Balance amount |
| `get-proposal` | Governance proposal details | Proposal record |
| `get-vote` | Voting record for proposal | Vote details |
| `get-price-feed` | Current asset price data | Price information |

## 🛠️ Technical Specifications

### Constants & Limits

```clarity
Asset Value Range: 1,000 - 1,000,000,000,000 STX
Governance Duration: 2 - 24 hours (12 - 144 blocks)
KYC Levels: 1 - 5 (increasing verification requirements)
Token Supply: 100,000 SFT per asset
Proposal Threshold: 10% token ownership minimum
```

### Error Codes

| Code | Category | Description |
|------|----------|-------------|
| u100-u104 | Access Control | Authorization and permission errors |
| u105, u108 | Compliance | KYC and regulatory compliance issues |
| u106-u107 | Governance | Voting and proposal management errors |
| u110-u117 | Validation | Input validation and constraint violations |

## 🚦 Getting Started

### Prerequisites

- **Stacks Wallet**: xverse or compatible
- **STX Tokens**: For transaction fees and asset registration
- **KYC Verification**: Required for compliance-regulated operations

### Deployment

1. **Deploy Contract**

   ```bash
   clarinet deploy --network mainnet
   ```

2. **Verify Deployment**

   ```bash
   clarinet call-read-only .stacksfi get-asset-info u1
   ```

### Basic Usage

#### Register an Asset

```clarity
(contract-call? .stacksfi register-asset 
  "ipfs://Qm..." 
  u1000000)
```

#### Create Governance Proposal

```clarity
(contract-call? .stacksfi create-proposal 
  u1 
  "Increase dividend distribution rate" 
  u144 
  u10000)
```

#### Vote on Proposal

```clarity
(contract-call? .stacksfi vote 
  u1 
  true 
  u5000)
```

## 🔐 Security Considerations

### Access Controls

- **Owner-only functions** for asset registration and critical operations
- **Token-weighted governance** preventing centralization attacks
- **Multi-signature support** for high-value operations (recommended)

### Compliance Framework

- **KYC verification** required for regulatory compliance
- **AML monitoring** through transaction pattern analysis
- **Jurisdiction filtering** based on regulatory requirements

### Economic Security

- **Minimum asset values** prevent spam registrations
- **Proposal thresholds** ensure meaningful governance participation
- **Dividend locks** prevent manipulation of distribution timing

## 📊 Use Cases

### Real Estate Tokenization

- **Fractional Property Ownership**: Enable micro-investments in premium real estate
- **Rental Income Distribution**: Automated dividend payments from rental revenues
- **Property Management Voting**: Decentralized decisions on maintenance and improvements

### Art & Collectibles

- **Fine Art Fractionalization**: Democratize access to high-value art investments
- **Exhibition Revenue Sharing**: Distribute income from exhibitions and loans
- **Conservation Decisions**: Community governance for artwork preservation

### Infrastructure Assets

- **Renewable Energy Projects**: Tokenize solar farms, wind projects
- **Revenue Stream Sharing**: Distribute energy sales revenue to token holders
- **Expansion Funding**: Use governance for reinvestment decisions

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code standards and formatting
- Testing requirements and procedures  
- Pull request process and review
- Community guidelines and conduct
