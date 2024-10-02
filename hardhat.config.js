require("@nomicfoundation/hardhat-toolbox")
require("hardhat-deploy")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.27",
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        localhost: {
            chainId: 31337,
        },
    },
    namedAccounts: {
        deployer: {
            default: 0, // This will use the first account as the deployer
        },
        user1: {
            default: 1, // This will use the first account as the deployer
        },
        user2: {
            default: 2, // This will use the first account as the deployer
        },
    },
}
