// SPDX-License-Identifier: MIT
pragma solidity =0.8.27;

import {IERC777Sender} from "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import {TokenWithSanction0} from "./TokenWithSanction0.sol";

contract TokenWithSanctionSender is IERC777Sender {
    IERC1820Registry private constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");

    TokenWithSanction0 private immutable tokenContract;
    uint256 public sentTokens;
    uint256 public lastSentAmount;
    address public lastSentOperator;
    address public lastSentFrom;

    event TokensSent(address operator, address from, address to, uint256 amount, bytes userData, bytes operatorData);

    constructor(address tokenAddress) {
        tokenContract = TokenWithSanction0(tokenAddress);
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), _TOKENS_SENDER_INTERFACE_HASH, address(this));
    }

    // tokensToSend hook implementation
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        require(!tokenContract.isAddressBanned(to), "the address of the receiver is banned");
        sentTokens += amount;
        lastSentAmount = amount;
        lastSentOperator = operator;
        lastSentFrom = from;

        emit TokensSent(operator, from, to, amount, userData, operatorData);
    }

    function getSentTokens() public view returns (uint256) {
        return sentTokens;
    }

    function getLastSentInfo() public view returns (uint256, address, address) {
        return (lastSentAmount, lastSentOperator, lastSentFrom);
    }
}
