// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import {TokenTimelock} from "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title UntrustedEscrow
 * @dev A contract for securely holding and managing ERC20 tokens in an escrow arrangement.
 * This contract allows users to deposit tokens which are then locked for a specified duration.
 * The recipient can release the tokens after the lock period has expired.
 */
contract UntrustedEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Mapping of recipient addresses to their respective token timelocks
    mapping(address => TokenTimelock[]) public timelocks;

    /**
     * @dev Receives ERC20 tokens from the sender and creates a timelock for the specified recipient.
     * The sender must have previously approved the contract to spend the specified amount of tokens.
     *
     * @param tokenAddress The address of the ERC20 token contract from which tokens will be transferred.
     * @param amount The amount of tokens to receive and lock.
     * @param recipient The address that will receive the locked tokens after the timelock expires.
     *
     * @notice This function requires that the recipient is not the zero address and cannot be a contract address.
     * @notice Emits a TokenTimelock for the recipient after receiving the tokens.
     * @dev Reverts if the allowance of the sender for this contract is less than the specified amount.
     */
    function receiveTokens(address tokenAddress, uint256 amount, address seller, address recipient) external {
        require(recipient != address(0), "Invalid recipient: zero address");
        require(
            IERC20(tokenAddress).allowance(seller, address(this)) >= amount,
            "The escrow contract does not have sufficient allowance for the transfer"
        );
        IERC20(tokenAddress).safeTransferFrom(seller, address(this), amount);
        TokenTimelock timelock = new TokenTimelock(IERC20(tokenAddress), recipient, block.timestamp + 3 days);
        IERC20(tokenAddress).safeTransfer(address(timelock), amount);
        timelocks[recipient].push(timelock);
    }

    /**
     * @notice Allows the user to release their locked tokens after the lock period has passed.
     *
     * @dev This function can be called by the recipient to release all their locked tokens.
     * It iterates through all of the recipient's timelocks, releasing the tokens that are past their release time.
     * If a timelock is released, it is removed from the user's list of timelocks.
     * This function is protected against reentrancy attacks by using the nonReentrant modifier.
     *
     * @dev Reverts if the caller has no timelocks or if the lock period has not yet expired for all timelocks.
     */
    function releaseTokens() external nonReentrant {
        TokenTimelock[] storage userTimelocks = timelocks[msg.sender];
        for (uint256 i = 0; i < userTimelocks.length; ) {
            TokenTimelock timelock = userTimelocks[i];
            if (block.timestamp >= timelock.releaseTime()) {
                timelock.release();
                // Remove the released timelock from the array
                userTimelocks[i] = userTimelocks[userTimelocks.length - 1];
                userTimelocks.pop();
            } else {
                i++;
            }
        }
    }
    /**
     * @notice Returns the balance of tokens held in the timelock contract for a given address.
     * @param user The address of the user for whom the timelock balance is queried.
     * @return The balance of tokens held by the timelock contract for the user.
     */
    function getTimelockBalance(address user) external view returns (uint256) {
        uint256 balance = 0;

        // Loop through the timelocks of the user
        for (uint256 i = 0; i < timelocks[user].length; i++) {
            TokenTimelock timelock = timelocks[user][i];

            // Use the token() function to get the token address from the TokenTimelock
            address tokenAddress = address(timelock.token());

            // Get the balance of tokens held in this specific timelock
            balance += IERC20(tokenAddress).balanceOf(address(timelock));
        }

        return balance;
    }
}
