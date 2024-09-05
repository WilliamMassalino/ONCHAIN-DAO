// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/CryptoDevs.sol";
import "../src/Whitelist.sol";

contract CryptoDevsTest is Test {

    CryptoDevs cryptoDevs;
    Whitelist whitelist;

    address owner = address(1);
    address whitelistAddress1 = address(2);
    address whitelistAddress2 = address(3);
    address notWhitelisted = address(4);

    function setUp() public {
        // Deploy Whitelist contract with max 2 whitelisted addresses
        whitelist = new Whitelist(2);

        // Whitelist two addresses

        vm.prank(whitelistAddress1);
        whitelist.addressesToWhitelist();
        vm.prank(whitelistAddress2);
        whitelist.addressesToWhitelist();

        // Deploy CryptoDevs contract with the Whitelist contract address
        vm.prank(owner);
        cryptoDevs = new CryptoDevs(address(whitelist));
    }

    function testInitialValues() public view {
        // Test initial values after deployment
        assertEq(cryptoDevs.maxTokenIds(), 20);
        assertEq(cryptoDevs._price(), 0.01 ether);
        assertEq(cryptoDevs.reservedTokens(), 2);
        assertEq(cryptoDevs.reservedTokensClaimed(), 0);    
    }

    function testMintForWhitelistedWithReservation() public {
        // Test minting for a whitelisted address with reservation
        vm.prank(whitelistAddress1);
        cryptoDevs.mint{value: 0 ether}();
        
        assertEq(cryptoDevs.balanceOf(whitelistAddress1), 1);
        assertEq(cryptoDevs.reservedTokensClaimed(), 1);
    }

    function testMintForWhitelistedWithFullReservation() public {
        // Test minting for both whitelisted addresses
        vm.prank(whitelistAddress1);
        cryptoDevs.mint{value: 0 ether} ();

        vm.prank(whitelistAddress2);
        cryptoDevs.mint{value: 0 ether}();

        assertEq(cryptoDevs.balanceOf(whitelistAddress1), 1);
        assertEq(cryptoDevs.balanceOf(whitelistAddress2), 1);
        assertEq(cryptoDevs.reservedTokensClaimed(), 2);
    }

    function testFailMintForWhitelistedAlreadyOwned() public {
        // Test that a whitelisted address can't mint twice
        vm.prank(whitelistAddress1);
        cryptoDevs.mint{value: 0 ether}();
        // Try to mint again, should fail
        vm.prank(whitelistAddress1);
        vm.expectRevert(bytes("ALREADY OWNED"));
        cryptoDevs.mint{value: 0 ether} ();
    }

    function testFailMintForNonWhitelistedAndNotEnoughEth() public {
        // Test minting for a non-whitelisted address
        vm.prank(notWhitelisted);
        vm.expectRevert(bytes("NOT WHITELISTED"));
        // Should fail      
        cryptoDevs.mint{value: 0 ether} ();
        vm.prank(notWhitelisted);
        vm.expectRevert(bytes("NOT ENOUGH ETHER"));
        // Should fail
        cryptoDevs.mint{value: 0.001 ether} ();
    }

    function testFailMintExceedMaxSupply() public {
        // Mint tokens to reach max supply
        for (uint256 i = 0; i < 18; i++) {
            address newAddress = address(uint160(5 + i));
            vm.deal(newAddress, 1 ether);
            vm.prank(newAddress);
            cryptoDevs.mint{value: 0.01 ether}();
        }

        // The last two tokens are reserved for whitelisted addresses
        vm.prank(whitelistAddress1);
        cryptoDevs.mint{value: 0 ether}();
        
        vm.prank(whitelistAddress2);
        cryptoDevs.mint{value: 0 ether}();

        // Attempting to mint another token should fail
        vm.prank(notWhitelisted);
        vm.expectRevert(bytes("EXCEEDED_MAX_SUPPLY"));
        cryptoDevs.mint{value: 0.01 ether}();
    }

    function testWithdraw() public {
        // Test withdrawing ether from the contract
        // Mint a token to have ether in the contract

        // Ensure the address has enough balance to mint
        vm.deal(notWhitelisted, 1 ether);  // Fund the `notWhitelisted` address with 1 ether

        vm.prank(notWhitelisted);
        cryptoDevs.mint{value: 0.01 ether}();

        // Withdraw ether from the contract
        uint256 initialBalance = owner.balance;

        vm.prank(owner);
        cryptoDevs.withdraw();

        assertEq(owner.balance, initialBalance + 0.01 ether);
    }

    function testFailWithdrawNotOwner() public {
        // Test that only the owner can withdraw
        vm.prank(notWhitelisted);
        vm.expectRevert("Ownable: caller is not the owner!");
        cryptoDevs.withdraw();
    }
}