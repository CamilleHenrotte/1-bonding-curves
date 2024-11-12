// SPDX-License-Identifier: MIT
pragma solidity =0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title StandardToken
 * @dev Implementation of a standard ERC20 token with an adjustable initial supply. This contract allows the deployer
 * to mint a fixed amount of tokens at deployment, which are credited to the deployer's address.
 *
 * Inherits from OpenZeppelin's ERC20 contract for full compatibility with the ERC20 standard.
 */
contract StandardToken is ERC20 {
    /**
     * @notice Constructor to initialize the token with a name, symbol, and initial supply.
     * @dev Mints the `initialSupply` to the deployer's address. The `initialSupply` is multiplied by 10^decimals to
     * account for the token's smallest units.
     *
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param initialSupply The total supply of tokens to be minted at deployment, expressed in full token units (not including decimals).
     *                      The actual minted value will be `initialSupply * 10^decimals()`.
     */
    constructor(string memory name_, string memory symbol_, uint256 initialSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply * 10 ** decimals()); // Mint initial supply to the deployer
    }
}
