// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Whitelist {
    // Max number of whitelisted addresses allowed
    uint8 public maxWhitelistedAddress;

    // List of whitelisted addresses
    // If an address is whitelisted, we would set it to true, it is false by default

    mapping(address =>bool) public whitelistedAddresses;
    // numAddressesWhiteListed would be used to keep track of how many addressses have been whitelisted
    uint8 public numAddressesWhitelisted;

    // Seeting the Max number of whitelisted addresses
    // User will put the value at the time of deployment

    constructor(uint8 _maxWhitelistedAddress) {
        maxWhitelistedAddress = _maxWhitelistedAddress;
    }

    /**
     * AddressesToWhitelist - This function adds the address of the sender to the whitelist
     */

    function addressesToWhitelist() public {
        // check if the user has already been whitelisted
        require(!whitelistedAddresses[msg.sender],"Sender has already been whitelisted");
        // check if the numAddressesWhitelisted < maxWhitelistedAddresses,if not then throw an error.abi
        require(numAddressesWhitelisted < maxWhitelistedAddress, "More addresses cant be added, limit reached");
        // Add the address which called the function to the whitelistedAddress array
        whitelistedAddresses[msg.sender] = true;
        // Increment the numAddressesWhitelisted
        numAddressesWhitelisted++;
    }
} 

