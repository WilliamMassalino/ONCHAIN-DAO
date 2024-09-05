// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/CryptoDevs.sol";

contract DeployCryptoDevs is Script {
    function run(address whitelistAddress) public returns(address){
        vm.startBroadcast(); 
        
        // Deploy the CryptoDevs contract, passing the address of the Whitelist contract
        CryptoDevs cryptoDevs = new CryptoDevs(whitelistAddress);

        vm.stopBroadcast();

        // Return the address of the deployed contract

        return address(cryptoDevs);
    }
}
