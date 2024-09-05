// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "../src/CryptoDevsDAO.sol";


contract CryptoDevsDAOTest is Test {
    // Declare variables for the contracts
    CryptoDevsDAO dao;

    // Declare variables to simulate external contracts
    address fakeMarketplace = address(this);
    address fakeCryptoDevsNFT = address(this);

    // Define the users for testing
    address user1 = address(1);
    address user2 = address(2);

    // State to manage token availability
    mapping(uint256 => bool) public availableTokens;
    uint256 public nftPrice = 0.1 ether;

    // Mock data for NFT ownership
    mapping(address => uint256[]) public ownerToTokenIds;

    function setUp() public {
        // Deploy the DAO contract
        dao = new CryptoDevsDAO(fakeMarketplace, fakeCryptoDevsNFT);
        // Set token 1 as available for sale
        availableTokens[1] = true;
        // Simulate minting NFTs to users
        ownerToTokenIds[user1] = [1]; // user1 owns tokenId 1
        ownerToTokenIds[user2] = [2, 3]; // user2 owns tokenIds 2 and 3

        // Fund the DAO contract with ETH
        vm.deal(address(dao), 1 ether);
    }
    // Inline implementation of the marketplace and NFT functions
    function getPrice() external pure returns(uint256){
        return 0.1 ether;
    }

    function available(uint256 _tokenId) external view returns (bool) {
        return availableTokens[_tokenId];
    }

    function balanceOf(address owner) external view returns (uint256) {
        return ownerToTokenIds[owner].length;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return ownerToTokenIds[owner][index];
    }

    function purchase(uint256 _tokenId) external payable {
        require(msg.value == nftPrice, "Incorrect price");
        require(availableTokens[_tokenId], "Token not available");
        availableTokens[_tokenId] = false; // Mark as sold
    }

    /// @dev Allow this contract to receive Ether
    receive() external payable {}


     /// @dev Test the creation of a proposal in the DAO
    function testCreateProposal() public {
        // Simulate user1 calling the function
        vm.prank(user1);
        // Create a proposal to purchase NFT with tokenId 1
        uint256 proposalId = dao.createProposal(1);
        // Assert that the returned proposal ID is 0 (first proposal)
        assertEq(proposalId,0);
        // Fetch the details of the created proposal
        (uint256 nftTokenId, uint256 deadline, uint256 yayVotes, uint256 nayVotes, bool executed) = dao.proposals(proposalId);
        // Assert that the NFT token ID in the proposal is 1
        assertEq(nftTokenId,1);
        // Assert that the proposal's deadline is set to a time in the future
        assertGt(deadline,block.timestamp); // Gt assert that the first argument is greater than the second one
        // Assert that the initial YAY vote count is 0
        assertEq(yayVotes,0);
        // Assert that the initial NAY vote count is 0
        assertEq(nayVotes,0);
        // Assert that the proposal has not been executed
        assertEq(executed,false);
        // Assert that the proposal has not been executed
        assertFalse(executed);

    }
    /// @dev Test that creating a proposal fails if the NFT is not available for sale
    function testCreateProposalFailsIfNotNFTAvailable() public {
        // Simulate user1 calling the function
        vm.prank(user1);
        // Expect the function to revert with "NFT_NOT_FOR_SALE" since tokenId 2 is not available(_tokenId);
        vm.expectRevert("NFT_NOT_FOR_SALE");
        dao.createProposal(2); // Token 2 is not available
    }
    /// @dev Test voting on a proposal with a NAY vote
    function testVoteOnProposalNay() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);
        // Simulate user2 casting a NAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.NAY);
        // Fetch the updated proposal details
        (,,,uint256 nayVotes,) = dao.proposals(proposalId);
        // Assert that the YAY vote count is now 1 (user2's vote should be counted only once)
        assertEq(nayVotes,1);
    }
    /// @dev Test voting on a proposal with a YAY vote
    function testVoteOnProposalYay() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);
        // Simulate user2 casting a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);
        // Fetch the updated proposal details
        (,,uint256 yayVotes,,) = dao.proposals(proposalId);
        // Assert that the YAY vote count is now 1 (user2's vote should be counted only once)
        assertEq(yayVotes,1);
    }

    /// @dev Test that voting on a proposal fails if the user has already voted
    function testVoteOnProposalFailsIfAlreadyVoted() public {
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);
        // Simulate user2 voting on the proposal with a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);
        // Simulate user2 trying to vote again on the same proposal
        vm.prank(user2);
        // Expect the function to revert with "ALREADY_VOTED" since user2 has already voted
        vm.expectRevert("ALREADY_VOTED");
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.NAY);
    }
    /// @dev Test executing a proposal where the YAY votes win
    function testExecuteProposalYayWins() public {
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);
        // Simulate user2 voting on the proposal with a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);
        // Fast-forward time past the proposal deadline
        vm.warp(block.timestamp + 10 minutes);
        // Simulate user1 executing the proposal
        vm.prank(user1);
        dao.executeProposal(proposalId);
        // Fetch the updated proposal details
        (,,,,bool executed) = dao.proposals(proposalId);
        // Assert that the proposal has been executed
        assertTrue(executed);
        // Check if the NFT with tokenId 1 is no longer available by calling available on the fake marketplace
        bool isAvailable = this.available(1);
        // Assert that the NFT with tokenId 1 is no longer available (purchased)
        assertFalse(isAvailable);
    }

    /// @dev Test executing a proposal where the NAY votes win
    function testExecuteProposalNayWins() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);

        // Simulate user2 voting on the proposal with a NAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.NAY);

        // Fast-forward time past the proposal deadline
        vm.warp(block.timestamp + 10 minutes);

        // Simulate user1 executing the proposal
        vm.prank(user1);
        dao.executeProposal(proposalId);

        // Fetch the updated proposal details
        (, , , , bool executed) = dao.proposals(proposalId);
        
        // Assert that the proposal has been executed
        assertTrue(executed);
        // Check if the NFT with tokenId 1 is available by calling available on the fake marketplace
        bool isAvailable = this.available(1);
        // Assert that the NFT with tokenId 1 is still available (not purchased)
        assertTrue(isAvailable);
    }

    /// @dev Test that executing a proposal fails if the DAO does not have enough funds
    function testExecuteProposalFailsIfNotEnoughFunds() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);

        // Simulate user2 voting on the proposal with a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);

        // Fast-forward time past the proposal deadline
        vm.warp(block.timestamp + 10 minutes);

        // Empty the DAO's balance to simulate insufficient funds
        deal(address(dao), 0);

        // Simulate user1 trying to execute the proposal
        vm.prank(user1);
        // Expect the function to revert with "NOT_ENOUGH_FUNDS" due to insufficient funds
        vm.expectRevert("NOT_ENOUGH_FUNDS");
        dao.executeProposal(proposalId);
    }

    /// @dev Test that executing a proposal fails if the deadline has not passed
    function testExecuteProposalFailsIfNotExpired() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);

        // Simulate user2 voting on the proposal with a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);

        // Simulate user1 trying to execute the proposal before the deadline
        vm.prank(user1);
        // Expect the function to revert with "DEADLINE_NOT_EXCEEDED" since the deadline has not passed
        vm.expectRevert("DEADLINE_NOT_EXCEEDED");
        dao.executeProposal(proposalId);
    }

    /// @dev Test that executing a proposal fails if it has already been executed
    function testExecuteProposalFailsIfAlreadyExecuted() public {
        // Simulate user1 creating a proposal
        vm.prank(user1);
        uint256 proposalId = dao.createProposal(1);

        // Simulate user2 voting on the proposal with a YAY vote
        vm.prank(user2);
        dao.voteOnProposal(proposalId, CryptoDevsDAO.Vote.YAY);

        // Fast-forward time past the proposal deadline
        vm.warp(block.timestamp + 10 minutes);

        // Simulate user1 executing the proposal
        vm.prank(user1);
        dao.executeProposal(proposalId);

        // Simulate user1 trying to execute the same proposal again
        vm.prank(user1);
        // Expect the function to revert with "PROPOSAL_ALREADY_EXECUTED" since the proposal was already executed
        vm.expectRevert("PROPOSAL_ALREADY_EXECUTED");
        dao.executeProposal(proposalId);
    }

    /// @dev Test withdrawing Ether from the DAO by the owner
    function testWithdrawEther() public {
        // Record the initial balance of the owner
        uint256 initialBalance = address(this).balance;
       
        // Record the initial balance of the DAO contract
        uint256 daoBalance = address(dao).balance;
        
        
        // Simulate the owner calling the withdraw function
        vm.prank(dao.owner());
        dao.withdrawEther();

        // Assert that the DAO's balance is now 0 after the withdrawal
        assertEq(address(dao).balance, 0);
        
        // Assert that the owner's balance has increased by the amount withdrawn from the DAO
        assertEq(address(dao.owner()).balance, daoBalance + initialBalance);
        
    }

    /// @dev Test that withdrawing Ether fails if called by a non-owner
    function testWithdrawEtherFailsIfNotOwner() public {
        // Simulate user1 (not the owner) trying to withdraw Ether from the DAO
        vm.prank(user1);
        // Expect the function to revert with "Ownable: caller is not the owner"
        vm.expectRevert();
        dao.withdrawEther();
    }
}








