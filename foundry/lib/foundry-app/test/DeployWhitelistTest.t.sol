// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../script/Deploy.s.sol";
import "../src/Whitelist.sol";

contract DeployWhitelistTest is Test {
    function testDeployWhitelist() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Set the max whitelisted addresses
        uint8 maxWhitelistedAddresses = 10;

        // Deploy the Whitelist contract
        Whitelist whitelist = new Whitelist(maxWhitelistedAddresses);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Verify the contract was deployed and initialized correctly
        assertEq(whitelist.maxWhitelistedAddress(), 10, "Incorrect maxWhitelistedAddress");
        assertEq(whitelist.numAddressesWhitelisted(), 0, "Initial numAddressesWhitelisted should be 0");
    }

    function testDeployWhitelistScript() public {
        // Directly instantiate and run the deployment script
        DeployWhitelist deployScript = new DeployWhitelist();

        // No need to call startBroadcast again; just run the script
        deployScript.run();

        // At this point, the Whitelist contract has been deployed.
        address deployedAddress = address(0x90193C961A926261B756D1E5bb255e67ff9498A1);  // Replace with the correct address if necessary

        // Create a Whitelist instance at the deployed address
        Whitelist whitelist = Whitelist(deployedAddress);

        // Validate the deployment
        assertEq(whitelist.maxWhitelistedAddress(), 10, "Incorrect maxWhitelistedAddress");
        assertEq(whitelist.numAddressesWhitelisted(), 0, "Initial numAddressesWhitelisted should be 0");
    }
}
