// providers.js
import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

// Create a provider
export const provider = new ethers.JsonRpcProvider(process.env.INFURA_API_URL);

// Optionally create a signer if you need to sign transactions
export const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

export default {
    provider,
    signer,
};
