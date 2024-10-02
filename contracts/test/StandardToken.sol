// SPDX-License-Identifier: MIT
pragma solidity =0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TokenBondingCurve
 * @dev ERC20 token with a linear bonding curve mechanism for minting and burning.
 * The price of the token increases or decreases based on the supply and a constant coefficient.
 * Uses the bonding curve to calculate the number of tokens to mint or burn based on ETH sent or tokens burnt.
 */
contract StandardToken is ERC20 {
    /**
     * @dev Initializes the token with a name, symbol, initial supply, and bonding curve coefficient.
     * Mints the initial supply to the deployer's address.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param initialSupply The initial supply of tokens to be minted (in full token units).
   
     */
    constructor(string memory name_, string memory symbol_, uint256 initialSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply * 10 ** decimals()); // Mint initial supply to deployer
    }
}
