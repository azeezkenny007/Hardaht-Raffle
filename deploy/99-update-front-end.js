const { ethers, network } = require("hardhat")
const fs= require("fs")
const { json } = require("hardhat/internal/core/params/argumentTypes")

const FRONT_END_CONTRACT_ADDRESS_FILE =
    "../nextjs-smartcontract-lottery/constants/contractAddress.json"

const FRONT_END_ABI_FILE =
    "../nextjs-smartcontract-lottery/constants/abi.json"

module.exports= async function() {
   if(process.env.UPDATE_FRONT_END){
    console.log("updating front end")
        updateContractAddresses()
        updateAbi()
   }
}

async function updateAbi(){
   const raffle =await ethers.getContract("Raffle")
   await fs.writeFileSync(FRONT_END_ABI_FILE,raffle.interface.format(ethers.utils.FormatTypes.json))
}

async function updateContractAddresses(){
     const raffle= await ethers.getContract("Raffle")
     const currentAddresses =JSON.parse(fs.readFileSync(FRONT_END_CONTRACT_ADDRESS_FILE,"utf8"))
     const chainId =network.config.chainId.toString()
     if(chainId in currentAddresses){
         if(!currentAddresses[chainId].includes(currentAddresses)){
              currentAddresses[chainId].push(raffle.address)
         }
     }
     else{
         currentAddresses[chainId] = [raffle.address]
     }
        fs.writeFileSync(FRONT_END_CONTRACT_ADDRESS_FILE,JSON.stringify(currentAddresses))
}

module.exports.tags= ["all","frontend"]