// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

// 0xe4eb04Ab3986671e5c090FCA5555071ef1AD93d3

/* Errors */
error Raffle__NotEnoughEthEntered();
error Raffle__TransferFailed();
error Raffle__NotOpen();
error Raffle__UpkeepNotNeeded(
    uint256 currentBalance,
    uint256 numPlayers,
    uint256 raffleState
);

/**
 * @title  A Raffle Contract
 * @author Okhamena azeez
 * @notice This contract is for creating an untamperable dencentralized Raffle smart contract
 * @dev    This implements ChainLink VRF v2 and ChainLink Keepers
 */
contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /* Types Declaration */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /* State Variables */
    uint256 private immutable i_entranceFee; // The entrance fee for the contract
    address payable[] private s_players; // The payable address for the players in the raffle
    VRFCoordinatorV2Interface private immutable i_vrfCordinator; // The dynamic address
    bytes32 private immutable i_gasLane; // The max amount of the transcation in wei
    uint64 private immutable i_subscriptionId; // The sub Id that will be funded by our wallet
    uint16 private constant REQUEST_CONFIRMATIONS = 3; //The max amount block confirmations to wait for
    uint32 private immutable i_callbackGasLimit; //  The max gasLimit we capped for the transaction
    uint32 private constant NUM_WORDS = 1; // The number of verifiable random number we want
    RaffleState private s_raffleState; // The state of the Raffle
    uint256 private s_lastTimeStamp; // The timestamp of the smart contract
    uint256 private immutable i_interval; // The interval needed to checkUpKeep

    /* Lottery Variables */
    address private s_recentWinner;

    /* Events */
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCordinator = VRFCoordinatorV2Interface(vrfCordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    /**
     * @dev The conditions to meet to before you can enter Raffle
     *     1. The amount funded from the wallet (hardhatNetwork||localhost||testnets or mainet) must be greater than entranceFee
     *        2. The Raffle must be in open state
     */
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthEntered();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    /**
     * @dev 1. This is the function the ChainLink Keeper calls
     *      2. They loop for the Upkeep needed to return true
     *      3. The following has to be true before it will perform Upkeep
     *            1. our time interval should have passed
     *            2. The lottery should have atleast 1 player and have some eth
     *            3. our subsciption is funded with link
     *            4. The lottery should be in a open state
     *      4. If it returns true they perform Upkeep on the intended function
     *
     */
    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        override
        returns (
            bool upKeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = (RaffleState.OPEN == s_raffleState); //checks to if the lottery is an open state
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval); //To check if time has pass
        bool hasPlayers = (s_players.length > 0); // To check if the players in the array is greater than 0
        bool hasBalance = address(this).balance > 0; // To check if the contract balance is greater than 0
        upKeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        return (upKeepNeeded, "0x0");
    }

    /**
     * @dev  1. The following conditions must be satisfied before it can performUpkeep
     *             1.  The checkupKeep must return true unless it will revert it
     *             2.  The Vrf contract get subscription from our walllet
     *             3.  The Chainlink Vrf then takes our request  with our values
     *             4.  After, if it's successful return randomwords depending specified randomWords
     */
    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upKeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upKeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        // Quiz... is this redundant?
        emit RequestedRaffleWinner(requestId);
    }

    /**
     * @dev  1. Returns the randomWords
     *       2. Then a modulo perform on it e.g (102 % 10) = returns the remainder 2 refer down to see implementation
     *       3  The modulo operation is then used to assign get the random player
     *       4. The recent winner is then assigned
     *       5. The players array is then reset to empty array
     *       6. The funds transferred to the owner || or reverts if the transfer failed
     *
     */
    function fulfillRandomWords(
        uint256, /*requestId*/
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    /* View/Pure functions */
    /**
     * @return
     *      1. The entranceFee for the raffle
     */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    /**
     * @return
     *    1. The player at the index specified
     */
    function getPlayers(uint256 _index) public view returns (address) {
        return s_players[_index];
    }

    /**
     * @return
     *     1.The recent winner of the raffle
     */
    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    /**
     * @return
     *     1.The raffle state
     */
    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    /**
     * @return
     *     1.The interval needed for upkeep
     */
    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    /**
     * @return
     *     1.number of times randomwords is returned
     */
    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    /**
     * @return
     *     1.The number of players in the raffle
     */
    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    /**
     * @return
     *     1.The latest timestamp
     */
    function getLatestTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    /**
     * @return
     *     1.The number of confirmations the Vrf should wait
     */
    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    /**
     * @return
     *     1. How the modulo operation works works
     */
    function performModulo(uint256 num1, uint256 num2)
        public
        pure
        returns (uint256)
    {
        return num1 % num2;
    }
     /**
     * @return
     *     1. Returns the max amount of gas capped for the VRFCoordinator 
     */
    function getCallBackGasLimit() public view returns(uint256){
         return  i_callbackGasLimit;
    }

    /**
     * @return
     *     1. Returns the Subscription Id
     */
    function getSubScriptionId() public view returns(uint256){
         return i_subscriptionId;
    }

    
}
