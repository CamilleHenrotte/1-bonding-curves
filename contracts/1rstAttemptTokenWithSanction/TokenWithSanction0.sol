// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import {ERC777} from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract TokenWithSanction0 is ERC777, Ownable2Step {
    mapping(address => bool) public bannedAddresses;
    event BannedAddressAdded(address indexed bannedAddress);
    event BannedAddressRemoved(address indexed bannedAddress);

    constructor(
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) ERC777(name, symbol, defaultOperators) {}

    function mint(address account, uint256 amount, bytes memory userData, bytes memory operatorData) public onlyOwner {
        _mint(account, amount, userData, operatorData);
    }

    function removeBannedAddress(address bannedAddress) external onlyOwner {
        require(bannedAddresses[bannedAddress], "Address is not banned");
        delete bannedAddresses[bannedAddress];
        emit BannedAddressRemoved(bannedAddress);
    }

    function addBannedAddress(address bannedAddress) external onlyOwner {
        require(bannedAddress != address(this), "Can't ban the address of the contract");
        bannedAddresses[bannedAddress] = true;
        emit BannedAddressAdded(bannedAddress);
    }

    function isAddressBanned(address addressToCheck) public view returns (bool) {
        return bannedAddresses[addressToCheck];
    }
}
