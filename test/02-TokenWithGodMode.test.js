const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")
const AMOUNT_OF_TOKENS = ethers.parseEther("1")
describe("2- Token with god mode", async () => {
    let deployer, tokenUser1, tokenUser2, tokenWithGodMode, user1, user2
    beforeEach(async () => {
        const namedAccounts = await getNamedAccounts()
        deployer = namedAccounts.deployer
        user1 = namedAccounts.user1
        user2 = namedAccounts.user2
        const deployerSigner = await ethers.getSigner(deployer)
        const user1Signer = await ethers.getSigner(user1)
        const user2Signer = await ethers.getSigner(user2)
        await deployments.fixture(["all"])
        const tokenWithGodModeAddress = (await deployments.get("TokenWithGodMode")).address
        tokenWithGodMode = await ethers.getContractAt("TokenWithGodMode", tokenWithGodModeAddress, deployerSigner)
        await tokenWithGodMode.transfer(user1, AMOUNT_OF_TOKENS)
        tokenUser1 = tokenWithGodMode.connect(user1Signer)
        tokenUser2 = tokenWithGodMode.connect(user2Signer)
    })
    describe("transferWithGodMode", () => {
        it("should revert if it is not called by the owner", async () => {
            await expect(tokenUser2.transferWithGodMode(user1, user2, AMOUNT_OF_TOKENS)).to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })
        it("should tranfer money frop user1 to user2 without approval", async () => {
            const balanceUser1Before = await tokenUser1.balanceOf(user1)
            const balanceUser2Before = await tokenUser1.balanceOf(user2)
            await tokenWithGodMode.transferWithGodMode(user1, user2, AMOUNT_OF_TOKENS)
            const balanceUser1After = await tokenUser1.balanceOf(user1)
            const balanceUser2After = await tokenUser1.balanceOf(user2)
            expect(balanceUser1Before).to.equal(AMOUNT_OF_TOKENS)
            expect(balanceUser2Before).to.equal(0)
            expect(balanceUser1After).to.equal(0)
            expect(balanceUser2After).to.equal(AMOUNT_OF_TOKENS)
        })
    })
})
