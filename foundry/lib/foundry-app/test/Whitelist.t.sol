// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "../src/Whitelist.sol";

contract WhitelistTest is Test {
    Whitelist whitelist;

    function setUp() public {
        // Deploy the Whitelist contract with a maximum of 3 whitelisted addresses
        whitelist = new Whitelist(3);
    }

    function testInitialValues() public view {
        // Test that a new address can be whitelisted
        assertEq(whitelist.maxWhitelistedAddress(), 3);
        assertEq(whitelist.numAddressesWhitelisted(), 0);
    }

    function testAddAddressToWhitelist() public {
        // Test that a new address can be whitelisted
        vm.prank(address(1)); // Simulate a different address calling the function
        whitelist.addressesToWhitelist();

        assertTrue(whitelist.whitelistedAddresses(address(1)));
        assertEq(whitelist.numAddressesWhitelisted(),1);
    }

    function testFailAddingSameAddressTwice() public {
        // Test that the same address cannot be whitelisted twice
        vm.prank(address(1)); 
        whitelist.addressesToWhitelist();

        // Attempting to whitelist the same address again should fail
        vm.prank(address(1));
        whitelist.addressesToWhitelist();
        vm.expectRevert(bytes("Sender has already been whitelisted"));
    }

    function testFailAddingMoreThanMaxWhitelist() public {
        // Test that the number of whitelisted addresses cannot exceed the maximum
        vm.prank(address(1));
        whitelist.addressesToWhitelist();
        vm.prank(address(2));
        whitelist.addressesToWhitelist();
        vm.prank(address(3));
        whitelist.addressesToWhitelist();
        // Attempting to whitelist another address should fail as the limit is reached
        vm.prank(address(4));
        whitelist.addressesToWhitelist();
        vm.expectRevert(bytes("More addresses cant be added, limit reached"));

    }

    function testAddMultipleAddress() public {
        // Test adding multiple addresses up to the maximum limit
        vm.prank(address(1));
        whitelist.addressesToWhitelist();
        vm.prank(address(2));
        whitelist.addressesToWhitelist();
        vm.prank(address(3));
        whitelist.addressesToWhitelist();

        assertEq(whitelist.numAddressesWhitelisted(),3);
    }
}



