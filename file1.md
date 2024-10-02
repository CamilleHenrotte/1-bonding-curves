# ERC-777 - ERC-1363

---

### I. What problems does ERC-777 solve ?

ERC-777 is backwards compatible with ERC-20, while introducing several new functionalities.

#### 1. Hooks

ERC-777 introduces two new hooks : tokensReceived and tokensToSend. TokensReceived hook enables the recipient contract to react automatically when it receives tokens. The tokensToSend hook is called before tokens are sent from the holder’s account. These hooks are functions which checks that the transfer is abiding by some customed rules. Here are some use vases of the tokenReceived hook :

-   The tokenReceived hook prevents tokens from being locked unintentionally. In ERC-20, if a contract receives tokens without implementing the approve and transferFrom methods, it can lead to tokens being locked, whereas tokenReceived will revert the transaction if it is not implememnted correctly.
-   The tokensReceived hook allows contracts to filter and reject unwanted tokens. This feature is particularly useful for preventing spam tokens. These are tokens sent by malicious actors in phishing schemes. In contrast, the ERC-20 standard does not provide a mechanism to block or reject token transfers, making wallets vulnerable to receiving unwanted tokens, such as those airdropped without user consent. This lack of control in ERC-20 can clutter wallets and pose security risks.
-   The tokenReceived hook enables the receiving contract to automatically recognize and credit the user for a token transfer. Achieving a similar result with an ERC-20 token would be more complex. The receiving contract would first need to be approved to spend the user’s tokens, and only then could it initiate a separate transaction on behalf of the user, keeping track of the transfer amount and sender’s address. This process lacks the simplicity and efficiency that the tokenReceived hook provides.

#### 2. Operators

ERC-777 uses operators. An operator is an address authorized to send or burn tokens on behalf of a token holder. It is saved in the ERC-1820 registry. In ERC-20 authorization for an other account to send tokens only comes in the form of allowance. Meaning the other account has only a right to send limited in amount. In ERC-777 operators don't have this limit. This makes it easier, removing the need to check if the allowance is sufficient each time.

#### 3. Life cycle

ERC-777 defines a standard way to mint tokens and burn them. In ERC-20, while minting, burning tokens are possible, the standard does not explicitly define these processes. In ERC-20, you could lock tockens unintentionnaly or intentionnaly but the standard does not specify explitly a norm. The ERC-777 insures that there are no locked tokens, and that therefore that the total supply reflect accuretly the token in circulation.

#### 4. Data

ERC-777 adds a data parameter in the mint, send and burn functions. These enable to attach information to these functions. This feature was not present in ERC-20.

---

### II. What issues are there with ERC-777?

ERC-777 while solving some shortcomings of the ERC-20, raised other problems.

#### 1. Reentrancy Vulnerabilities

The tokenReceived hook from ERC-777 raises reentrancy issues. With this hook, an external function is calles. The receiving contract gets control during the transfer. If its is malicious it can potentially perform a call back into the contract before the transaction is finalized.

#### 2. Difficulty avoiding spam tokens

Using tokensReceived hook in ERC-777 promises to allows smart contracts to filter unwanted token transfers. However developers of malicious tokens can always modify their tokens or create new ones. So making a blacklist of tokens could be useless.

#### 3. Gas cost

TokensReceived and tokensToSend hooks as well as operators from ERC-777 are registered to the ERC-1820 registry. Each time there is a transfer the registry needs to be checked. This is quite expensive in gas.

---

### III. What problems does ERC-1363 solve ?

ERC-1363 like ERC-777 is backwards compatible with ERC-20. And it tries to solve the same issues than ERC-777, however it takes a different approach than ERC-777.

-   In ERC-777, the hooks tokensReceived and tokensToSend are called everytime a transfer or transferFrom. In ERC-1363 hooks onTransferReceived and onApprovalReceived are called only when either approveAndCall, transferFromAndCall or transferAndCall. This makes transfer and transferFrom not reentrant in ERC-1396 but reantrant in ERC-777. Therefore ERC-1396 may be safer since code developped using transfer and transferFrom without reentrancy in mind are still safe. Codes developped with approveAndCall, transferFromAndCall or transferAndCall which are reantrant should be taking this into consideration.
-   In ERC-777, the registry keeps track of operators to make the transferFrom process more streamline. In ERC-1363 the approveAndCall combines the approve and transferFrom in one transaction, addressing the same efficiency concerns.

In both cases, the new features of ERC-777 are maintained while removing the registry. It therefore reduces some of the gas cost and complexity of ERC-777.
