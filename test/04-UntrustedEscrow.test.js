const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")
const AMOUNT_OF_TOKENS = ethers.parseEther("1")
describe("4- Untrusted Escrow", async () => {
    let deployer,
        untrustedEscrow,
        seller,
        buyer,
        standardToken,
        erc20Seller,
        escrowBuyer,
        escrowSeller,
        standardTokenAddress
    beforeEach(async () => {
        const namedAccounts = await getNamedAccounts()
        deployer = namedAccounts.deployer
        seller = namedAccounts.user1
        buyer = namedAccounts.user2
        const deployerSigner = await ethers.getSigner(deployer)
        const sellerSigner = await ethers.getSigner(seller)
        const buyerSigner = await ethers.getSigner(buyer)
        await deployments.fixture(["all"])
        const untrustedEscrowAddress = (await deployments.get("UntrustedEscrow")).address
        untrustedEscrow = await ethers.getContractAt("UntrustedEscrow", untrustedEscrowAddress, deployerSigner)
        standardTokenAddress = (await deployments.get("StandardToken")).address
        standardToken = await ethers.getContractAt("StandardToken", standardTokenAddress, deployerSigner)
        erc20Seller = standardToken.connect(sellerSigner)
        escrowSeller = untrustedEscrow.connect(sellerSigner)
        escrowBuyer = untrustedEscrow.connect(buyerSigner)
        //a seller approves the escrow contract to transfer its token
        await standardToken.transfer(seller, AMOUNT_OF_TOKENS)
        await erc20Seller.approve(untrustedEscrowAddress, AMOUNT_OF_TOKENS)
    })

    describe("receiveTokens", () => {
        it("reverts if recipient address is zero", async () => {
            expect(
                await expect(
                    untrustedEscrow.receiveTokens(
                        standardTokenAddress,
                        AMOUNT_OF_TOKENS,
                        seller,
                        "0x0000000000000000000000000000000000000000"
                    )
                ).to.be.revertedWith("Invalid recipient: zero address")
            )
        })

        it("reverts if the allowance is not sufficient", async () => {
            expect(
                await expect(
                    untrustedEscrow.receiveTokens(standardTokenAddress, ethers.parseEther("2"), seller, buyer)
                ).to.be.revertedWith("The escrow contract does not have sufficient allowance for the transfer")
            )
        })
        it("receives the token in a time lock", async () => {
            await untrustedEscrow.receiveTokens(standardTokenAddress, AMOUNT_OF_TOKENS, seller, buyer)
            const balanceOfTokenSeller = await standardToken.balanceOf(seller)
            const balanceInTimeLocked = await untrustedEscrow.getTimelockBalance(buyer)
            expect(balanceOfTokenSeller).to.equal(0)
            expect(balanceInTimeLocked).to.equal(AMOUNT_OF_TOKENS)
        })
    })
    describe("releaseTokens", () => {
        it("", async () => {
            await untrustedEscrow.receiveTokens(standardTokenAddress, AMOUNT_OF_TOKENS, seller, buyer)
            await ethers.provider.send("evm_increaseTime", [1259201])
            await ethers.provider.send("evm_mine")
            await escrowBuyer.releaseTokens()
            const balanceOfTokenBuyer = await standardToken.balanceOf(buyer)
            expect(balanceOfTokenBuyer).to.equal(AMOUNT_OF_TOKENS)
        })
    })
})
