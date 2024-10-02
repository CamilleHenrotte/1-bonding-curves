const { network, ethers } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = ["tokenWithGodMode", "T3"]
    await deploy("TokenWithGodMode", {
        from: deployer,
        args: args,
        log: true,
        gasLimit: 3000000,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    log("TokenWithGodMode Deployed!")
    log("----------------------------------------------------")
    log("----------------------------------------------------")
}
module.exports.tags = ["all", "tokenWithGodMode"]
