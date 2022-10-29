# 🛴  __THE HARDHAT-RAFFLE SMART-CONTRACT(BACKEND)__

<div style="margin-top:30px"></div>

__Since smart contract are deterministics in nature: They can't listen to events,actions in the outside world( anything not in the smart contract ) ,they have the__ ```ORACLE PROBLEM``` 

<div style="margin-top:30px"></div>

##  ❓ __WHAT IS THE ORACLE PROBLEM ❓__
* The smart contract are created in a way that are that don't have access to off-chain data, ```But what if i want to get price of Eth or an off-chain data ```, ```will i hardcode it , or will i have resort to a centralized server? , in that case where is the decentrality in this ? ```
* The illustration above explains the ```ORACLE PROBLEM``` is there any way to go around this ? , or is there any way to get any verifiable decentralized data into the smart contract ? , ```yes there is !!!```
* That is where ```ChainLink``` comes into play, They provide us with ```decentralized off-chain data``` that can be used in our smart contract to form what is called is a ```Hybrid smart contract```
* ```hybrid smart contract = decentralized * (on-chain + off-chain data) type of    smart contract```

<div style="margin-top:30px"></div>

## ✅  __HOW DOES CHAINLINK PROTOCOL WORK ?__
* They have ERC20-Token called ```LINK``` , which is their native token 
* The Token is used to incentive the Chainlink nodes for fetching correct offchain data in a ```Decentralized context```
*  ```Decentralized context``` - means the data fetched is submitted to the network and ```a ChainLink node is  responsible for inputing the data into the a smart contract``` which would be used to get the offchain data , if malicious activities is notice the node is cut-off from the network
* The chainlink node are called ```ORACLES```, just as Ethereum network  nodes are called ```VALIDATORS``` since they have moved from 
```POW - Proof Of Work ``` to ```POS - Proof Of Stake ```
<div style="margin-top:30px"></div>


## 🚗 __CHAINLINK VRF__
1. Connect our wallet to recieve VRF(Verifiable Random  Function)
2. The wallet is connected to pay chainlink node, the Link address can be found in [chainLink Docs]()
3. After the chainLnk subscription is created we get a subId , which we use to deploy the address
4. Then we register the ```contract address``` as a consumer address , that will get the VRF functions implementation

<div style="margin-top:30px"></div>

## ⚙ __CHAINLINK KEEPERS__
1. This ia an event triggered action from the ChainLink Protocol 
2. They check the condition specified in the ```CheckUpKeep``` function
3. They bring out execution using  ```PerformUpKeep``` function

<div style="margin-top:30px"></div>

## 🔗 __WORKING MECHANISM OF CONTRACT__
``` solidity
 enum RaffleState {
        OPEN,
        CALCULATING
    }
```
* ```RaffleState - To specify the raffle state of the contract - under the hood they return uint e.g RaffleSate.OPEN == 0 , RaffleState.CALCULATING == 1```
* ```uint256 private immutable i_entranceFee  - To set the raffle entrance fee on deploying the contract```
*  ```address payable[] private s_players -The array of address in the contract```
     * ```payable - To be able to recieve funds```
* ```VRFCoordinatorV2Interface private immutable i_vrfCordinator - The address of the chainLink Vrf to interact with```
*  ```bytes32 private immutable i_gasLane - The max amount of the transaction in wei```
*  ```uint64 private immutable i_subscriptionId - The sub Id that will be funded by our wallet ```
* ```uint16 private constant REQUEST_CONFIRMATIONS - The max amount block confirmations to wait for ```
*  ```uint32 private immutable i_callbackGasLimit -  The max gasLimit we capped for the transaction```
*  ```uint32 private constant NUM_WORDS = 1 - The number of verifiable random number we want ```
*  ``` RaffleState private s_raffleState - The state of the Raffle```
*  ``` uint256 private s_lastTimeStamp - The timestamp of the smart contract```

<div style="margin-top:30px"></div>

## 🦒🎈 __Functions Explaining The Raffle.sol Contract__
<div style="margin-top:30px"></div>

* __EnterRaffle()__ - ``` The Function to enter the Raffle Contract i.e To pay for the Raffle```
* __checkUpkeep()__ - ```Checks the condition to be satisfied by the ChainLink keepers```
* __performUpKeep()__ - ``` This is the action the ChainLink keeper will perform is the perform upkeep returns true```
* __getEntranceFee()__ - ```Returns the entrance fee for the raffle```
* __getRecentWinner()__ - ```Returns the recentwinner of the raffle```
* __getRaffleState()__ - ```Returns the current state of the raffle```
* __getInterval()__ - ```Returns the interval set before you can enter the raffle```
* __getNumWords()__ - ```Returns the number of random words requested```
* ___getNumberOfPlayers()__ - ```Returns the number of player present in the Raffle```
* __getLatestTimeStamp()__ - ```Returns the latest the time stamp ```
* __getRequestConfirmations()__ - ```Returns the number of confirmations the ChainLink VRF should wait for before returning the random number```
* __getCallBackGasLimit()__  - ```Returns the max amount of gas capped for the VRFCoordinator ```

*** <div style="margin-top:30px"></div>**

## 👩‍💻 __COMMANDS TO USE__

> * __To Compile the Contract__   - ```yarn hardhat compile```
> * __To Clear the Compile__ Contract - ```yarn hardhat clean```
> * __To Deploy the Contract on hardhat__ - ```yarn hardhat deploy```
> * __To Deploy the contract to a testnet__ - ```yarn hardhat deploy --network <network name> ```
> * __To Run Test on hardhat__  - ```yarn hardhat test ```
> * __To Run Test on a particular network__ ```yarn hardhat test --network <network name> ```
> * __To Run a paricular Test__ - ```yarn hardhat test --grep <name of the test in quote> ```
>  * __To Run a Specific Test on a Particular Network__ - ```yarn hardhat test --grep <name of the test in quote>  --network <network name> ```

```bash
   The preffered networks can be found in the hardhat config file
```
<div style="margin-top:30px"></div>

## 📱  __Contact__
- __Phone number - +2348134570701__
* __Twitter - [ken_okha](https://twitter.com/Ken_okha "ken_okha")__
* __BlockChain developer__

    
  









  
