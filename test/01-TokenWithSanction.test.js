const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")
const AMOUNT_OF_TOKENS = ethers.parseEther("1")
describe("1- Token with sanction", async () => {
    let deployer, tokenUser1, tokenUser2, tokenWithSanction, tokenWithSanctionAddress, user1, user2
    beforeEach(async () => {
        const namedAccounts = await getNamedAccounts()
        deployer = namedAccounts.deployer
        user1 = namedAccounts.user1
        user2 = namedAccounts.user2
        const deployerSigner = await ethers.getSigner(deployer)
        const user1Signer = await ethers.getSigner(user1)
        const user2Signer = await ethers.getSigner(user2)
        await deployments.fixture(["all"])
        tokenWithSanctionAddress = (await deployments.get("TokenWithSanction")).address
        tokenWithSanction = await ethers.getContractAt("TokenWithSanction", tokenWithSanctionAddress, deployerSigner)
        await tokenWithSanction.transfer(user1, AMOUNT_OF_TOKENS) // Corrected here
        tokenUser1 = tokenWithSanction.connect(user1Signer)
        tokenUser2 = tokenWithSanction.connect(user2Signer)
    })
    describe("addBannedAddress", () => {
        it("should revert if it is not called by the owner", async () => {
            await expect(tokenUser1.addBannedAddress(user2)).to.be.revertedWith("Ownable: caller is not the owner")
        })
        it("should revert if the address banned is the address of the contract", async () => {
            await expect(tokenWithSanction.addBannedAddress(tokenWithSanctionAddress)).to.be.revertedWith(
                "Can't ban the address of the contract"
            )
        })
        it("should add a banned address to bannedAddress array", async () => {
            const isUser1BannedBefore = await tokenWithSanction.isAddressBanned(user1)
            await tokenWithSanction.addBannedAddress(user1)
            const isUser1BannedAfter = await tokenWithSanction.isAddressBanned(user1)
            expect(isUser1BannedBefore).to.equal(false)
            expect(isUser1BannedAfter).to.equal(true)
        })
    })
    describe("transfer", () => {
        it("should transfer token from user1 to user2", async () => {
            const balanceUser1Before = await tokenUser1.balanceOf(user1)
            const balanceUser2Before = await tokenUser1.balanceOf(user2)

            await tokenUser1.transfer(user2, AMOUNT_OF_TOKENS)

            const balanceUser1After = await tokenUser1.balanceOf(user1)
            const balanceUser2After = await tokenUser1.balanceOf(user2)

            expect(balanceUser1Before).to.equal(AMOUNT_OF_TOKENS)
            expect(balanceUser2Before).to.equal(0)
            expect(balanceUser1After).to.equal(0)
            expect(balanceUser2After).to.equal(AMOUNT_OF_TOKENS)
        })
        it("user2 is now banned the transfer should revert", async () => {
            await tokenWithSanction.addBannedAddress(user2)
            await expect(tokenUser1.transfer(user2, AMOUNT_OF_TOKENS)).to.be.revertedWith(
                "the address of the receiver is banned"
            )
        })
        it("user1 is now baned the transfer should revert", async () => {
            await tokenWithSanction.addBannedAddress(user1)
            await expect(tokenUser1.transfer(user2, AMOUNT_OF_TOKENS)).to.be.revertedWith(
                "the address of the sender is banned"
            )
        })
    })
    describe("transferFrom", () => {
        it("should transfer token from user1 to user2", async () => {
            await tokenUser1.approve(user2, AMOUNT_OF_TOKENS)

            const balanceUser1Before = await tokenUser1.balanceOf(user1)
            const balanceUser2Before = await tokenUser1.balanceOf(user2)

            await tokenUser2.transferFrom(user1, user2, AMOUNT_OF_TOKENS)

            const balanceUser1After = await tokenUser1.balanceOf(user1)
            const balanceUser2After = await tokenUser1.balanceOf(user2)

            expect(balanceUser1Before).to.equal(AMOUNT_OF_TOKENS)
            expect(balanceUser2Before).to.equal(0)
            expect(balanceUser1After).to.equal(0)
            expect(balanceUser2After).to.equal(AMOUNT_OF_TOKENS)

            const allowanceAfter = await tokenUser1.allowance(user1, user2)
            expect(allowanceAfter).to.equal(0)
        })

        it("user2 is now banned; the transfer should revert", async () => {
            await tokenWithSanction.addBannedAddress(user2)
            await tokenUser1.approve(user2, AMOUNT_OF_TOKENS)
            await expect(tokenUser1.transferFrom(user1, user2, AMOUNT_OF_TOKENS)).to.be.revertedWith(
                "the address of the receiver is banned"
            )
        })

        it("user1 is now banned; the transfer should revert", async () => {
            await tokenWithSanction.addBannedAddress(user1)
            await tokenUser1.approve(user2, AMOUNT_OF_TOKENS)
            await expect(tokenUser1.transferFrom(user1, user2, AMOUNT_OF_TOKENS)).to.be.revertedWith(
                "the address of the sender is banned"
            )
        })
    })
})
