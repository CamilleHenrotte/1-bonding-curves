// SPDX-License-Identifier: MIT
pragma solidity =0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TokenTimelock} from "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./MathUtils.sol";

/**
 * @title TokenBondingCurve
 * @dev ERC20 token with a linear bonding curve mechanism for minting and burning.
 * The price of the token increases or decreases based on the supply and a constant coefficient.
 * Uses the bonding curve to calculate the number of tokens to mint or burn based on ETH sent or tokens burnt.
 */
contract TokenBondingCurve is ERC20, ReentrancyGuard {
    uint256 public immutable inverseCoefficient;
    mapping(address => TokenTimelock[]) public timelocks;

    /**
     * @dev Initializes the token with a name, symbol, initial supply, and bonding curve coefficient.
     * Mints the initial supply to the deployer's address.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param inverseCoefficient_ The inverse of the slope (coefficient) of the bonding curve, which determines how price changes with supply.
     */
    constructor(string memory name_, string memory symbol_, uint256 inverseCoefficient_) ERC20(name_, symbol_) {
        inverseCoefficient = inverseCoefficient_;
    }

    /**
     * @notice Mints tokens to a time-locked contract for the sender based on the amount of ETH sent.
     * @dev This function creates a TokenTimelock for the minted tokens, locking them for 1 hour,
     *  it should remove the risk of sandwich attack.
     */
    function mint() external payable {
        uint256 tokenAmount = getMintedTokenAmountEquivalentToETHAmount(msg.value);
        TokenTimelock timelock = new TokenTimelock(this, msg.sender, block.timestamp + 1 hours);
        timelocks[msg.sender].push(timelock);
        _mint(address(timelock), tokenAmount);
    }

    /**
     * @notice Burns tokens from the caller's account based on the ETH equivalent of tokens burnt.
     * The ETH equivalent of the burnt tokens is deducted from the total supply.
     */
    function burn(uint256 tokenAmount) external {
        uint256 ethAmount = getEthAmountEquivalentToBurnedTokenAmount(tokenAmount);
        _burn(msg.sender, ethAmount);
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Allows the user to release their locked tokens after the lock period has passed.
     */
    function releaseTokens() external nonReentrant {
        TokenTimelock[] storage userTimelocks = timelocks[msg.sender];
        for (uint256 i = 0; i < userTimelocks.length; ) {
            TokenTimelock timelock = userTimelocks[i];
            if (block.timestamp >= timelock.releaseTime()) {
                timelock.release();
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
        for (uint256 i; i < timelocks[user].length; i++) {
            TokenTimelock timelock = timelocks[user][i];
            balance += balanceOf(address(timelock));
        }

        return balance;
    }

    /**
     * @notice Calculates the amount of tokens a buyer would receive for a given amount of ETH.
     * @dev The calculation is based on a linear bonding curve formula: sqrt(totalSupply^2 + (2 * ethAmount / coefficient)).
     * @param ethAmount The amount of ETH the buyer wants to spend.
     * @return The amount of tokens equivalent to the ETH spent.
     */
    function getMintedTokenAmountEquivalentToETHAmount(uint256 ethAmount) public view returns (uint256) {
        return MathUtils.sqrt((totalSupply() ** 2) + ((2 * ethAmount) * inverseCoefficient)) - totalSupply();
    }

    /**
     * @notice Calculates the amount of ETH equivalent to a given amount of burned tokens.
     * @dev The calculation is based on the reverse of the linear bonding curve: sqrt(totalSupply^2 - (2 * ethAmount / coefficient)).
     * @param tokenAmount The amount of tokens to be burned.
     * @return The amount of ETH equivalent to the tokens being burned.
     */
    function getEthAmountEquivalentToBurnedTokenAmount(uint256 tokenAmount) public view returns (uint256) {
        return (totalSupply() ** 2 - (totalSupply() - tokenAmount) ** 2) / 2 / inverseCoefficient;
    }

    function computeSquareRoot(uint256 x) external pure returns (uint256) {
        return MathUtils.sqrt(x);
    }
}
