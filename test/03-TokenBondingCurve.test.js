const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")
const AMOUNT_OF_ETH_FIRST_2_TOKENS = ethers.parseEther("0.01")
const AMOUNT_OF_ETH_SECOND_2_TOKENS = ethers.parseEther("0.03")
describe("3- Token with bonding curve", async () => {
    let deployer, tokenUser1, tokenUser2, tokenWithBondingCurve, tokenWithBondingCurveAddress, user1, user2
    beforeEach(async () => {
        const namedAccounts = await getNamedAccounts()
        deployer = namedAccounts.deployer
        user1 = namedAccounts.user1
        user2 = namedAccounts.user2
        const deployerSigner = await ethers.getSigner(deployer)
        const user1Signer = await ethers.getSigner(user1)
        const user2Signer = await ethers.getSigner(user2)
        await deployments.fixture(["all"])
        tokenWithBondingCurveAddress = (await deployments.get("TokenBondingCurve")).address
        tokenWithBondingCurve = await ethers.getContractAt(
            "TokenBondingCurve",
            tokenWithBondingCurveAddress,
            deployerSigner
        )

        tokenUser1 = tokenWithBondingCurve.connect(user1Signer)
        tokenUser2 = tokenWithBondingCurve.connect(user2Signer)
    })
    describe("Mint the first 2 tokens at 0.01 ETH, the second 2 tokens at 0.03 ETH, and then burn the second 2 tokens", () => {
        it("should mint tokens, account for gas fees, and then burn tokens", async () => {
            //---------------------------------------
            // First user buys 0.01 ETH worth of tokens
            //---------------------------------------
            const totalSupply0 = await tokenWithBondingCurve.totalSupply()
            const user1EthBalanceBefore = await ethers.provider.getBalance(user1)

            // Mint tokens (first 2 tokens for 0.01 ETH)
            const txMint1 = await tokenUser1.mint({ value: AMOUNT_OF_ETH_FIRST_2_TOKENS })
            const receiptMint1 = await txMint1.wait()
            const gasUsedMint1 = receiptMint1.gasUsed
            const gasPriceMint1 = receiptMint1.effectiveGasPrice || txMint1.gasPrice
            const gasCostMint1 = gasUsedMint1 * gasPriceMint1

            // Increase time and mine block to allow token release
            await ethers.provider.send("evm_increaseTime", [5000])
            await ethers.provider.send("evm_mine")

            // Release tokens (for first mint)
            const txRelease1 = await tokenUser1.releaseTokens()
            const receiptRelease1 = await txRelease1.wait()
            const gasUsedRelease1 = receiptRelease1.gasUsed
            const gasPriceRelease1 = receiptRelease1.effectiveGasPrice || txRelease1.gasPrice
            const gasCostRelease1 = gasUsedRelease1 * gasPriceRelease1

            // Calculate final balances for user1
            const user1EthBalanceAfter = await ethers.provider.getBalance(user1)
            const user1TokenBalance = await tokenWithBondingCurve.balanceOf(user1)
            const totalSupply1 = await tokenWithBondingCurve.totalSupply()

            // Expectations for first mint
            expect(totalSupply0).to.equal(0)
            expect(user1EthBalanceBefore - user1EthBalanceAfter - gasCostMint1 - gasCostRelease1).to.equal(
                AMOUNT_OF_ETH_FIRST_2_TOKENS
            )
            expect(user1TokenBalance).to.equal(ethers.parseEther("2"))
            expect(totalSupply1).to.equal(ethers.parseEther("2"))

            //---------------------------------------
            // Second user buys 0.03 ETH worth of tokens
            //---------------------------------------
            const user2EthBalanceBefore = await ethers.provider.getBalance(user2)

            // Mint tokens (second 2 tokens for 0.03 ETH)
            const txMint2 = await tokenUser2.mint({ value: AMOUNT_OF_ETH_SECOND_2_TOKENS })
            const receiptMint2 = await txMint2.wait()
            const gasUsedMint2 = receiptMint2.gasUsed
            const gasPriceMint2 = receiptMint2.effectiveGasPrice || txMint2.gasPrice
            const gasCostMint2 = gasUsedMint2 * gasPriceMint2

            // Get the balance of the timelock before the release (user2)
            const timeLockBalance = await tokenWithBondingCurve.getTimelockBalance(user2)

            // Increase time and mine block to allow token release
            await ethers.provider.send("evm_increaseTime", [5000])
            await ethers.provider.send("evm_mine")

            // Release tokens (for second mint)
            const txRelease2 = await tokenUser2.releaseTokens()
            const receiptRelease2 = await txRelease2.wait()
            const gasUsedRelease2 = receiptRelease2.gasUsed
            const gasPriceRelease2 = receiptRelease2.effectiveGasPrice || txRelease2.gasPrice
            const gasCostRelease2 = gasUsedRelease2 * gasPriceRelease2

            // Calculate final balances for user2
            const user2EthBalanceAfter = await ethers.provider.getBalance(user2)
            const user2TokenBalance = await tokenWithBondingCurve.balanceOf(user2)
            const totalSupply2 = await tokenWithBondingCurve.totalSupply()

            // Check expected balances and supply for user2
            expect(timeLockBalance).to.equal(ethers.parseEther("2"))
            expect(totalSupply2).to.equal(ethers.parseEther("4"))
            expect(user2EthBalanceBefore - user2EthBalanceAfter).to.equal(
                AMOUNT_OF_ETH_SECOND_2_TOKENS + gasCostMint2 + gasCostRelease2
            )
            expect(user2TokenBalance).to.equal(ethers.parseEther("2"))

            //---------------------------------------
            // Second user burns the 2 tokens
            //---------------------------------------
            const txBurn2 = await tokenUser2.burn(ethers.parseEther("2"))
            const receiptBurn2 = await txBurn2.wait()
            const gasUsedBurn2 = receiptBurn2.gasUsed
            const gasPriceBurn2 = receiptBurn2.effectiveGasPrice || txBurn2.gasPrice
            const gasCostBurn2 = gasUsedBurn2 * gasPriceBurn2

            // Final balances for user2
            const user2TokenBalanceFinal = await tokenWithBondingCurve.balanceOf(user2)
            const user2EthBalanceFinal = await ethers.provider.getBalance(user2)
            const contractBalance = await ethers.provider.getBalance(tokenWithBondingCurveAddress)

            // Expectations for burn
            expect(contractBalance).to.equal(AMOUNT_OF_ETH_FIRST_2_TOKENS)
            expect(user2EthBalanceFinal - user2EthBalanceAfter).to.equal(AMOUNT_OF_ETH_SECOND_2_TOKENS - gasCostBurn2)
            expect(user2EthBalanceBefore - user2EthBalanceFinal).to.equal(gasCostMint2 + gasCostRelease2 + gasCostBurn2)
        })
    })

    describe("sqrt", () => {
        it("should compute the squre root of 4*10**36", async () => {
            const result = await tokenWithBondingCurve.computeSquareRoot(ethers.parseUnits("4", 36))
            expect(result).to.equal(ethers.parseUnits("2", 18))
        })
    })
})
