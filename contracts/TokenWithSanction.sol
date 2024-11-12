// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title TokenWithSanction
 * @dev Implementation of the ERC20 token standard with burnable functionality and ownership control.
 */
contract TokenWithSanction is Ownable2Step {
    mapping(address => bool) public bannedAddresses;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;

    event BannedAddressAdded(address indexed bannedAddress);
    event BannedAddressRemoved(address indexed bannedAddress);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Constructor to initialize the token with name and symbol, and mint initial supply to the deployer.
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, 1 * 10 ** decimals());
    }
    /**
     * @dev Removes an address from the banned list.
     * @param bannedAddress The address to be removed from the banned list.
     * @notice This function can only be called by the contract owner.
     * @dev Reverts if the specified address is not banned.
     * Emits a {BannedAddressRemoved} event.
     */
    function removeBannedAddress(address bannedAddress) external onlyOwner {
        require(bannedAddresses[bannedAddress], "Address is not banned");
        delete bannedAddresses[bannedAddress];
        emit BannedAddressRemoved(bannedAddress);
    }

    /**
     * @dev Adds an address to the banned list.
     * @param bannedAddress The address to be added to the banned list.
     * @notice This function can only be called by the contract owner.
     * @dev Reverts if the specified address is the address of the contract itself.
     * Emits a {BannedAddressAdded} event.
     */
    function addBannedAddress(address bannedAddress) external onlyOwner {
        require(bannedAddress != address(this), "Can't ban the address of the contract");
        bannedAddresses[bannedAddress] = true;
        emit BannedAddressAdded(bannedAddress);
    }

    /**
     * @dev Checks if an address is banned.
     * @param addressToCheck The address to check for banning status.
     * @return bool Returns true if the address is banned, false otherwise.
     */
    function isAddressBanned(address addressToCheck) public view returns (bool) {
        return bannedAddresses[addressToCheck];
    }

    /**
     * @dev Returns the name of the token.
     * @return The name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     * @return The symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * @return The number of decimals
     */
    function decimals() public pure returns (uint8) {
        return 18; // Default decimals for ERC20 tokens
    }

    /**
     * @dev Returns the total supply of tokens in circulation.
     * @return The total supply of the token
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the token balance of a specific account.
     * @param account The address of the account
     * @return The token balance of the account
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers `amount` tokens to `recipient`.
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to transfer
     * @return True if the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
     * @param owner The address of the token owner
     * @param spender The address of the spender
     * @return The remaining allowance
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves `spender` to spend `amount` tokens on behalf of the caller.
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve
     * @return True if the approval was successful
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     * @param sender The address of the sender
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to transfer
     * @return True if the transfer was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    /**
     * @dev Internal function to handle token transfers if the sender or recipient is not banned.
     * @param sender The address of the sender
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to transfer
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(!isAddressBanned(sender), "the address of the sender is banned");
        require(!isAddressBanned(recipient), "the address of the receiver is banned");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Internal function to handle token approvals.
     * @param owner The address of the token owner
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Internal function to mint tokens.
     * @param account The address to mint tokens for
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Burns `amount` tokens from the caller's account.
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Internal function to burn tokens.
     * @param account The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}
