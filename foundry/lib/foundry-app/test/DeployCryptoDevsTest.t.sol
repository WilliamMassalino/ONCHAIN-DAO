// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../script/DeployCryptoDevs.s.sol";
import "../src/CryptoDevs.sol";
import "../src/Whitelist.sol";

contract DeployCryptoDevsTest is Test {
    DeployCryptoDevs deployCryptoDevs;
    Whitelist whitelist;

    function setUp() public {
        // Deploy the Whitelist contract first
        whitelist = new Whitelist(10);

        // Now initialize the DeployCryptoDevs contract instance
        deployCryptoDevs = new DeployCryptoDevs();
    }

    function testDeployCryptoDevs() public {
        // Run the deployment script, passing the correct whitelist address
        address deployedCryptoDevsAddress = deployCryptoDevs.run(address(whitelist));

        // Create an instance of the deployed CryptoDevs contract
        CryptoDevs cryptoDevs = CryptoDevs(deployedCryptoDevsAddress);

        // Validate the Whitelist contract address in the CryptoDevs contract
        assertEq(cryptoDevs.getWhitelistAddress(), address(whitelist), "Whitelist address mismatch");
    }
}
