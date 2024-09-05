// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Whitelist.sol";

contract DeployWhitelist is Script {
    function run() public {
        vm.startBroadcast();

        // Set the max whitelisted addresses
        uint8 maxWhitelistedAddresses = 10;

        // Deploy the Whitelist contract
        new Whitelist(maxWhitelistedAddresses);

        vm.stopBroadcast();
    }
}