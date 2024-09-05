// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/FakeNFTMarketplace.sol";

contract FakeNFTMarketplaceTest is Test {
    FakeNFTMarketplace marketplace;

    address user1 = address(1);
    address user2 = address(2);

    function setUp() public {
        marketplace = new FakeNFTMarketplace();
        // Simulate 100 ether balance for users
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    /// @dev Test the price retrieval function
    function testGetPrice() public view {
        uint256 price = marketplace.getPrice();
        assertEq(price, 0.1 ether);
    }

    /// @dev Test purchasing an NFT with the correct price
    function testPurchaseWithCorrectPrice() public {
        uint256 tokenId = 1;
        // Simulate user1 buying the NFT
        vm.prank(user1);
        marketplace.purchase{value: 0.1 ether}(tokenId);
        // Assert that user1 is now the owner of tokenId 1
        assertEq(marketplace.tokens(tokenId), user1);
    }

    /// @dev Test purchasing an NFT with an incorrect price

    function testPurchaseWithIncorrectPrice() public {
        uint256 tokenId = 1;
        vm.prank(user1);
        vm.expectRevert("This NFT costs 0.1 ether");
        marketplace.purchase{value: 2 ether}(tokenId);
    }

    /// @dev Test checking availability before and after purchase

    function testAvailability() public {
        uint256 tokenId = 3;
        // Token should be available before purchase
        bool isAvailableBefore = marketplace.available(tokenId);
        assertTrue(isAvailableBefore);

        // Simulate user2 buying the NFT
        vm.prank(user2);
        marketplace.purchase{value: 0.1 ether}(tokenId);

        // Token should not be available after purchase
        bool isAvailableAfter = marketplace.available(tokenId);
        assertFalse(isAvailableAfter);
    }

    /// @dev Test purchasing an already owned token
    function testPurchaseAlreadyOwnedToken() public {
        uint256 tokenId = 4;
        // Simulate user1 buying the NFT
        vm.prank(user1);
        marketplace.purchase{value: 0.1 ether}(tokenId);
        // Expect revert because the token has already been purchased
        vm.prank(user2);
        vm.expectRevert("This NFT is already owned");
        marketplace.purchase{value: 0.1 ether}(tokenId);
    }

    /// @dev Test edge case: purchase with zero Ether
    function testPurchaseWithZeroEther() public {
        uint256 tokenId = 5;

        // Expect revert because no Ether was sent
        vm.prank(user1);
        vm.expectRevert("This NFT costs 0.1 ether");
        marketplace.purchase{value: 0}(tokenId);
    }
}
