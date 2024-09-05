# ONCHAIN-DAO
## Introduction
ONCHAIN-DAO is a decentralized autonomous organization (DAO) designed for holders of CryptoDevs NFTs. The project consists of two main components: a smart contract layer (managed via Foundry) and a frontend interface (built with Next.js) that interacts with Ethereum smart contracts using Ethers.js.

## Table of Contents
- [Installation](#Installation)
- [Features](#Features)
- [Dependencies](#Dependencies)
- [License](#License)

## Installation

Backend (Foundry)

Installation
Backend(Foundry)

1. Clone this repository:

```bash
git clone https://github.com/WilliamMassalino/ONCHAIN-DAO.git
cd ONCHAIN-DAO
```
2. Install dependencies for the backend:

```bash
cd foundry
forge install
```
3. Create a `.env`file in the root directory:

```bash
touch .env
```
Paste the following environmental variables:

```text
PRIVATE_KEY="[PASTE YOUR PRIVATE KEY]"
SEPOLIA_RPC_URL="[PASTE YOUR RPC URL]" (ALCHEMY, INFURA ETC...) // I used SEPOLIA test net
ETHERSCAN_API_KEY="[PASTE YOUR ETHERSCAN API KEY]" (OPCIONAL)
WHITELIST_CONTRACT="0x3E8475476B125023070FcB17322B97b4455CAE95" //Here I used my deployed WHITELIST CONTRACT address, you can use yours if you prefer to deploy by yourself.
CRYPTODEVS_CONTRACT="0x2B0b7ad30710555C34969C0349aD575d2c82ab5A" //Here I used my deployed CRYPTODEVS CONTRACT address, you can use yours if you prefer to deploy by yourself.
FAKENFTMARKETPLACE_CONTRACT="0x92e7cCddE4B8DEeDcB08ed64881661D83943C275" //Here I used my deployed FAKENFTMARKETPLACE CONTRACT address, you can use yours if you prefer to deploy by yourself.
```
*I used the `WhiteList Contract` and `CryptoDevs contract` from my previous project <https://github.com/WilliamMassalino/foundry-app.git> Check it out to understand how this two contracts works. If you choose to deploy by yourself, remember to navigate to: ./frontend/src/constans/index.js/ and change the addresses and ABIs from the variables.*

Frontend(Next.js)

1. Navigate to the frontend directory:
```bash
cd ..
cd frontend
```

2. Install the required dependencies:

```bash
npm install
```

3. Start the development server:

```bash
npm run dev
```
## Frontend Interface

1. After starting the frontend, open your browser and go to `http://localhost:3000`.
2. Connect your MetaMask wallet and interact whith the DAO, such as creating proposals or voting on them.

## Features

* **DAO Creation:** Only users holding CryptoDevs NFTs can create and vote on proposals.
* **Proposal Execution:** Proposals can be executed if they receive sufficient votes.
* **DAO Treasury:** The DAO manages its own treasury, which can be withdrawn by the DAO owner.
* **Fake NFT Marketplace:** Simulates an NFT marketplace for interacting with the DAO proposals.

## Dependencies

**Backend (Foundry)**

* **OpenZeppelin Contracts:** @openzeppelin/contracts for standard ERC-20 and ERC-721 functionality.

**Frontend (Next.js)**

* **Next.js:** next framework for server-side rendering.
* **Ethers.js:** ethers for interacting with Ethereum contracts.
* **React:** react library for building user interfaces.
* **RainbowKit:** For wallet connection UI.
* **dotenv:** For managing environment variables.

## License

This project is licensed under the MIT License.
