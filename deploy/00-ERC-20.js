const { network, ethers } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = ["standardToken", "T0", 1]
    await deploy("StandardToken", {
        from: deployer,
        args: args,
        log: true,
        gasLimit: 3000000,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    log("StandardToken Deployed!")
    log("----------------------------------------------------")
    log("----------------------------------------------------")
}
module.exports.tags = ["all", "standardToken"]
