# Crypto Devs NFT Collection with Whitelist

## Introduction

Crypto Devs is an NFT collection designed to give early supporters guaranteed access to mint NFTs. This project includes a whitelist system allowing a limited number of users to mint NFTs for free, while others have to pay a specified fee. The project is built using Solidity and Foundry, with smart contracts deployed on the Sepolia Ethereum test network.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Environment Variables](#environment-variables)
- [Contracts](#contracts)
- [Deployment](#deployment)
- [Testing](#testing)
- [License](#license)

## Installation

To get started with the project, follow the steps below:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/WilliamMassalino/foundry-app.git
   cd foundry-app
   
2. **Set Up Foundry:** Ensure that Foundry is installed on your machine. If not, you can install it by following the [Foundry installation guide](https://book.getfoundry.sh/getting-started/installation.html).
.

3. **Install Dependencies:**
    ```bash
    forge install

## Usage

**Writing the Whitelist Contract**

* The `Whitelist.sol` contract allows users to join a whitelist, limiting the number of addresses that can join.
* Users can add themselves to the whitelist by calling the addAddressToWhitelist function.
* The first 10 users can join the whitelist for free.

**Writing the NFT Contract**

* The `CryptoDevs.sol` contract is an ERC-721 implementation that allows users to mint NFTs from the Crypto Devs collection.
* Whitelisted users can mint NFTs for free, while others must pay 0.01 ETH.

## Adding Environment Variables

1. Create a `.env` file in the root of your project.
   
2. Add the following variables:
   
```bash
PRIVATE_KEY="your_private_key_here"
SEPOLIA_RPC_URL="your_quicknode_rpc_url_here"
ETHERSCAN_API_KEY="your_etherscan_api_key_here" (OPTIONAL).
```
## Features

* **Whitelist Functionality:** Ensures only a limited number of users can join the whitelist.
* **ERC-721 NFT Contract:** Implements the NFT standard with custom minting rules.
* **Whitelist-based Minting:** Whitelisted users can mint NFTs for free.

## Environment Variables

Ensure to set up the following environment variables in your `.env` file:

* `PRIVATE_KEY:` The private key of the wallet deploying the contracts.
* `SEPOLIA_RPC_URL:` The RPC URL for the Ethereum Sepolia network.
* `ETHERSCAN_API_KEY:` The API key for verifying contracts on Etherscan.

## Contracts

* **Whitelist.sol:** Handles the whitelist functionality.
* **CryptoDevs.sol:** The NFT contract that interacts with the whitelist contract.

## Deployment

To deploy the contracts:

1. **Deploy the Whitelist Contract:**
```bash
forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --constructor-args 10 --etherscan-api-key $ETHERSCAN_API_KEY --verify src/Whitelist.sol:Whitelist
```
2. **Deploy the NFT Contract:**
```bash
forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --constructor-args <your Whitelist Contract's address> --etherscan-api-key $ETHERSCAN_API_KEY --verify src/CryptoDevs.sol:CryptoDevs
```
## Testing

To run the tests:

1. **Run Tests for Whitelist:**

```bash
forge test --match-path src/tests/Whitelist.t.sol
```

2. **Run Tests for CryptoDevs:**
```bash
forge test --match-path src/tests/CryptoDevs.t.sol
```
3. **Deployment Tests:**
```bash
forge test --match-path src/tests/DeployWhitelistTest.t.sol
forge test --match-path src/tests/DeployCryptoDevsTest.t.sol
```
Or simply `forge test` to run all the tests at once.

## License

This project is licensed under the MIT License. 


### Summary:

- The `CryptoDevs.sol` and `Whitelist.sol` files are the main contracts.
- `Deploy.s.sol`, `DeployCryptoDevs.s.sol`, and the corresponding test files are used for deployment and testing.
- The remappings in `remappings.txt` are configured for the project to correctly reference dependencies.

This `README.md` provides an overview, installation steps, usage details, deployment instructions, and testing guidelines to help users understand and interact with your project. Let me know if there's anything else you'd like to add or modify!

