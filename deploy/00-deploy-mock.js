const { network, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")

const BASE_FEE = ethers.utils.parseEther("0.25") // it 0.25 premium , it costs 0.25Link per request
const GAS_PRICE_LINK = 1e9

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    const args = [BASE_FEE, GAS_PRICE_LINK]

    if (developmentChains.includes(network.name)) {
        log("local network detected!!!! , deploying mocks please wait!")
        const VRFCoordinatorV2Mock = await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })
        log("Mocks deployed hurray!!!")
        log("---------------------------")
    }
    const e = developmentChains.includes(network.name)

    e
        ? log(`The mocks was deployed on ${network.name}`)
        : log(`This was deployment on a mainet or testnet`)
    log(`The address of the deployer or owner of the mock is ${deployer} `)

    const balance = await ethers.provider.getBalance(deployer)
    log(balance)
}

module.exports.tags = ["all", "mocks"]
