## Why does the SafeERC20 program exist and when should it be used?

---

### Token inconstitencies

ERC-20 standard may not have been specific enough. The common practise to implement transfer function is to revert on failure and return true if the transfer succeeded. However tokens that do not revert on failure, but instead return false are still compliant with the standard. Others are missing return values. In other to insure constitencies in the dealing with all these different token implementations, oppenzeppelin offers a solution SafeERC20. SafeERC20 defines wrapper function safeTransfer, safeTransferFrom and safeApprove that insures that if the call to the trasfer function succeeds it returns true otherwise it reverts.

### Safer allowances

The approve function could potentially lead to vulnerabilities. If an allowance is set then updated, a malicious actor who watches the mempool for new transactions, could quickly acts before the update is applied and double spend the allowance. IncreaseAllowance and decreaseAllowance enables to mitigate this risk. SafeERC20 increaseAllowance and decreaseAllowance also prevent underflows and overflows.
