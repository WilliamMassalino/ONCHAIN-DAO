// Mark the component as a client component to use hooks and access browser APIs.
'use client';

// Import necessary libraries from Ethers.js, React, and Next.js.
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import Head from 'next/head';
import styles from './page.module.css'; // Import CSS styles.
import { Inter } from 'next/font/google'; // Import a Google font.

import {
  CryptoDevsDAOABI,
  CryptoDevsDAOAddress,
  CryptoDevsNFTABI,
  CryptoDevsNFTAddress,
} from '@/constants'; // Import contract ABIs and addresses.

// Initialize Google font.
const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
});

export default function Home() {
  // Define state variables to manage provider, signer, wallet address, and other data.
  const [provider, setProvider] = useState(null); // Ethereum provider (Ethers.js)
  const [signer, setSigner] = useState(null); // Ethereum signer for signing transactions
  const [address, setAddress] = useState(''); // User's wallet address
  const [isConnected, setIsConnected] = useState(false); // Wallet connection state
  const [isMounted, setIsMounted] = useState(false); // To ensure that the component is mounted
  const [loading, setLoading] = useState(false); // Loading state for transactions
  const [fakeNftTokenId, setFakeNftTokenId] = useState(''); // Input for creating a proposal
  const [proposals, setProposals] = useState([]); // List of DAO proposals
  const [selectedTab, setSelectedTab] = useState(''); // Tracks which tab is selected (Create/View Proposals)
  const [daoBalance, setDaoBalance] = useState(null); // Balance of the DAO treasury
  const [nftBalance, setNftBalance] = useState(null); // User's CryptoDevs NFT balance
  const [daoOwner, setDaoOwner] = useState(''); // Owner of the DAO

  // useEffect hook to initialize provider and signer when the component mounts
  useEffect(() => {
    async function initializeProviderAndSigner() {
      if (typeof window !== 'undefined' && window.ethereum) {
        try {
          // Get the Ethereum provider from MetaMask
          const web3Provider = new ethers.BrowserProvider(window.ethereum);
          const web3Signer = await web3Provider.getSigner(); // Get the signer for the user's wallet
          const signerAddress = await web3Signer.getAddress(); // Get the user's wallet address

          // Set the provider, signer, and user's wallet address in the state
          setProvider(web3Provider);
          setSigner(web3Signer);
          setAddress(signerAddress);
          setIsConnected(true);

          // Log the signer and address for debugging
          console.log("Signer Object:", web3Signer);
          console.log("Signer Address:", signerAddress);
        } catch (error) {
          console.error("Error initializing provider and signer:", error);
        }
      } else {
        console.log("Ethereum provider not found. Please install MetaMask.");
      }
    }

    initializeProviderAndSigner();
  }, []); // Empty dependency array ensures this runs only once when the component mounts

  // Fetch DAO balance, NFT balance, DAO owner, and all proposals when the wallet is connected.
  useEffect(() => {
    if (isConnected && address) {
      fetchDaoBalance();
      fetchNftBalance();
      fetchDaoOwner();
      fetchAllProposals();
    }
  }, [isConnected, address]); // Run this effect whenever the connection status or address changes

  // Ensure the component is mounted before rendering to avoid server-side rendering issues
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Fetch the balance of the DAO contract
  const fetchDaoBalance = async () => {
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, provider);
      const balance = await provider.getBalance(CryptoDevsDAOAddress); // Get the balance of the DAO contract
      setDaoBalance(ethers.formatEther(balance)); // Convert balance to Ether and set state
      console.log("DAO Balance fetched:", ethers.formatEther(balance));
    } catch (error) {
      console.error("Error fetching DAO Balance:", error);
    }
  };

  // Fetch the user's CryptoDevs NFT balance
  const fetchNftBalance = async () => {
    try {
      const contract = new ethers.Contract(CryptoDevsNFTAddress, CryptoDevsNFTABI, signer); // Get contract instance
      const balance = await contract.balanceOf(address); // Get user's NFT balance
      setNftBalance(balance.toString()); // Set the NFT balance in state
      console.log("NFT Balance fetched:", balance.toString());
    } catch (error) {
      console.error("Error fetching NFT Balance:", error);
    }
  };

  // Fetch the owner of the DAO
  const fetchDaoOwner = async () => {
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, provider);
      const owner = await contract.owner(); // Fetch the DAO owner
      setDaoOwner(owner); // Set the DAO owner in state
      console.log("DAO Owner fetched:", owner);
    } catch (error) {
      console.error("Error fetching DAO Owner:", error);
    }
  };

  // Check if the user owns any CryptoDevs NFTs (required for DAO membership)
  const checkNFTOwnership = async () => {
    try {
      if (!signer) {
        throw new Error("Signer is not defined. Please connect your wallet.");
      }

      const nftContract = new ethers.Contract(CryptoDevsNFTAddress, CryptoDevsNFTABI, signer);
      const balance = await nftContract.balanceOf(await signer.getAddress()); // Get the user's NFT balance

      console.log("NFT Balance:", balance.toString());

      return balance > 0; // Return true if the user owns any NFTs
    } catch (error) {
      console.error("Error checking NFT ownership:", error);
      return false;
    }
  };

  // Check the state of the DAO (e.g., number of proposals)
  const checkDAOState = async () => {
    try {
      if (!provider) {
        throw new Error("Provider is not defined. Please connect your wallet.");
      }

      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, provider);
      const numProposals = await contract.numProposals(); // Fetch the number of proposals in the DAO
      console.log("Number of proposals:", numProposals.toString());

      // You can add more state checks here as needed

      return numProposals;
    } catch (error) {
      console.error("Error checking DAO state:", error);
      return null;
    }
  };

  // Function to create a proposal
  const createProposal = async () => {
    setLoading(true);
    try {
      if (!signer) {
        throw new Error("Signer is not defined. Please connect your wallet.");
      }

      const isDAOMember = await checkNFTOwnership(); // Check if the user owns a CryptoDevs NFT
      if (!isDAOMember) {
        throw new Error("You are not a DAO member. You need to own a CryptoDevs NFT to create a proposal.");
      }

      console.log("Signer Object:", signer);
      console.log("Signer Address before transaction:", await signer.getAddress());

      // Validate and convert the input
      if (!fakeNftTokenId || isNaN(fakeNftTokenId)) {
        throw new Error("Invalid token ID");
      }

      const tokenId = BigInt(fakeNftTokenId); // Convert the token ID to a BigInt
      console.log("Token ID:", tokenId.toString());

      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, signer);
      console.log("Contract Object:", contract);

      const tx = await contract.createProposal(tokenId); // Create a proposal on the DAO
      await tx.wait(); // Wait for the transaction to be mined

      console.log("Transaction successful:", tx);
      fetchAllProposals(); // Refresh the proposals after creating a new one
    } catch (error) {
      console.error("Error creating proposal:", error);
      window.alert(error.message); // Show an error message to the user
    }
    setLoading(false); // Stop loading after the transaction is complete
  };

  // Fetch a single proposal by its ID
  const fetchProposalById = async (id) => {
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, provider);
      const proposal = await contract.proposals(id); // Fetch the proposal details by ID
      const [nftTokenId, deadline, yayVotes, nayVotes, executed] = proposal; // Destructure the proposal details
      return {
        proposalId: id,
        nftTokenId: nftTokenId.toString(),
        deadline: new Date(parseInt(deadline.toString()) * 1000), // Convert the deadline to a JavaScript Date object
        yayVotes: yayVotes.toString(),
        nayVotes: nayVotes.toString(),
        executed: Boolean(executed),
      };
    } catch (error) {
      console.error("Error fetching proposal by ID:", error);
    }
  };

  // Fetch all proposals in the DAO
  const fetchAllProposals = async () => {
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, provider);
      const numProposals = await contract.numProposals(); // Get the total number of proposals
      const proposalsData = [];
      for (let i = 0; i < numProposals; i++) {
        const proposal = await fetchProposalById(i); // Fetch each proposal by ID
        proposalsData.push(proposal); // Add the proposal to the list
      }
      setProposals(proposalsData); // Set all proposals in state
      console.log("All Proposals fetched:", proposalsData);
    } catch (error) {
      console.error("Error fetching all proposals:", error);
    }
  };

  // Vote on a proposal (YAY or NAY)
  const voteForProposal = async (proposalId, vote) => {
    setLoading(true);
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, signer);
      const tx = await contract.voteOnProposal(proposalId, vote === 'YAY' ? 0 : 1); // 0 = YAY, 1 = NAY
      await tx.wait();
      await fetchAllProposals(); // Refresh proposals after voting
    } catch (error) {
      console.error("Error voting for proposal:", error);
      window.alert(error.message); // Show an error message to the user
    }
    setLoading(false); // Stop loading after the transaction is complete
  };

  // Execute a proposal after the voting deadline
  const executeProposal = async (proposalId) => {
    setLoading(true);
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, signer);
      const tx = await contract.executeProposal(proposalId); // Execute the proposal
      await tx.wait(); // Wait for the transaction to be mined
      await fetchAllProposals(); // Refresh the proposals after execution
    } catch (error) {
      console.error("Error executing proposal:", error);
      window.alert(error.message); // Show an error message to the user
    }
    setLoading(false); // Stop loading after the transaction is complete
  };

  // Withdraw Ether from the DAO treasury (only callable by the DAO owner)
  const withdrawDAOEther = async () => {
    setLoading(true);
    try {
      const contract = new ethers.Contract(CryptoDevsDAOAddress, CryptoDevsDAOABI, signer);
      const tx = await contract.withdrawEther(); // Withdraw Ether from the DAO contract
      await tx.wait(); // Wait for the transaction to be mined
    } catch (error) {
      console.error("Error withdrawing DAO Ether:", error);
      window.alert(error.message); // Show an error message to the user
    }
    setLoading(false); // Stop loading after the transaction is complete
  };

  // Connect the user's wallet
  const connectWallet = async () => {
    try {
      if (typeof window !== 'undefined' && window.ethereum) {
        await window.ethereum.request({ method: 'eth_requestAccounts' }); // Request wallet connection
        const web3Provider = new ethers.BrowserProvider(window.ethereum);
        const web3Signer = await web3Provider.getSigner();
        const signerAddress = await web3Signer.getAddress();

        setProvider(web3Provider);
        setSigner(web3Signer);
        setAddress(signerAddress);
        setIsConnected(true);

        console.log("Wallet connected:", signerAddress);
      } else {
        console.log("Ethereum provider not found. Please install MetaMask.");
      }
    } catch (error) {
      console.error("Error connecting wallet:", error);
    }
  };

  // If the component is not mounted, return null (prevents rendering on the server)
  if (!isMounted) return null;

  // If the wallet is not connected, show the "Connect Wallet" button
  if (!isConnected)
    return (
      <div>
        <button onClick={connectWallet} className={styles.button}>
          Connect Wallet
        </button>
      </div>
    );

  // The main component rendering logic
  return (
    <div className={inter.className}>
      <Head>
        <title>CryptoDevs DAO</title>
        <meta name="description" content="CryptoDevs DAO" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className={styles.main}>
        <div>
          <h1 className={styles.title}>Welcome to Crypto Devs!</h1>
          <div className={styles.description}>Welcome to the DAO!</div>
          <div className={styles.description}>
            Your CryptoDevs NFT Balance: {nftBalance || 'Loading...'}
            <br />
            Treasury Balance: {daoBalance ? `${daoBalance} ETH` : 'Loading...'}
            <br />
            Total Number of Proposals: {proposals.length}
          </div>
          <div className={styles.flex}>
            <button className={styles.button} onClick={() => setSelectedTab('Create Proposal')}>
              Create Proposal
            </button>
            <button className={styles.button} onClick={() => setSelectedTab('View Proposals')}>
              View Proposals
            </button>
          </div>

          {/* Render the "Create Proposal" tab */}
          {selectedTab === 'Create Proposal' && (
            <div className={styles.container}>
              <label>Fake NFT Token ID to Purchase: </label>
              <input
                placeholder="0"
                type="number"
                onChange={(e) => setFakeNftTokenId(e.target.value)}
              />
              <button className={styles.button2} onClick={createProposal}>
                Create
              </button>
            </div>
          )}

          {/* Render the "View Proposals" tab */}
          {selectedTab === 'View Proposals' && (
            <div>
              {proposals.map((p, index) => (
                <div key={index} className={styles.card}>
                  <p>Proposal ID: {p.proposalId}</p>
                  <p>Fake NFT to Purchase: {p.nftTokenId}</p>
                  <p>Deadline: {p.deadline.toLocaleString()}</p>
                  <p>Yay Votes: {p.yayVotes}</p>
                  <p>Nay Votes: {p.nayVotes}</p>
                  <p>Executed?: {p.executed.toString()}</p>
                  {p.deadline.getTime() > Date.now() && !p.executed ? (
                    <div className={styles.flex}>
                      <button className={styles.button2} onClick={() => voteForProposal(p.proposalId, 'YAY')}>
                        Vote YAY
                      </button>
                      <button className={styles.button2} onClick={() => voteForProposal(p.proposalId, 'NAY')}>
                        Vote NAY
                      </button>
                    </div>
                  ) : p.deadline.getTime() < Date.now() && !p.executed ? (
                    <div className={styles.flex}>
                      <button className={styles.button2} onClick={() => executeProposal(p.proposalId)}>
                        Execute Proposal {p.yayVotes > p.nayVotes ? '(YAY)' : '(NAY)'}
                      </button>
                    </div>
                  ) : (
                    <div className={styles.description}>Proposal Executed</div>
                  )}
                </div>
              ))}
            </div>
          )}

          {/* Show the "Withdraw DAO ETH" button if the connected user is the DAO owner */}
          {address && daoOwner && address.toLowerCase() === daoOwner.toLowerCase() && (
            <div>
              {loading ? (
                <button className={styles.button}>Loading...</button>
              ) : (
                <button className={styles.button} onClick={withdrawDAOEther}>
                  Withdraw DAO ETH
                </button>
              )}
            </div>
          )}
        </div>
        <div>
          <img className={styles.image} src="https://i.imgur.com/buNhbF7.png" alt="CryptoDevs DAO" />
        </div>
      </div>
    </div>
  );
}
