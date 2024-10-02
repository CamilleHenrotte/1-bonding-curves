const { network, ethers } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = ["tokenWithSanction", "T1"]
    await deploy("TokenWithSanction", {
        from: deployer,
        args: args,
        log: true,
        gasLimit: 3000000,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    log("TokenWithSanction Deployed!")
    log("----------------------------------------------------")
    log("----------------------------------------------------")
}
module.exports.tags = ["all", "tokenWithSanction"]
