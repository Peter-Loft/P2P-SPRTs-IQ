pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./OracleInterface.sol";

/// @title FootballBets
/// @author Peter S. Loft (Modified from John R. Kosinski for American Football)
/// @notice Takes bets and handles payouts for boxing games.
contract FootballBets is Ownable {
    
    using SafeMath for uint256;

    //mappings 
    mapping(address => bytes32[]) private userToBets;
    mapping(bytes32 => Bet[]) private gameToBets;

    //football results oracle 
    address internal footballOracleAddr;
    OracleInterface internal footballOracle = OracleInterface(footballOracleAddr);

    //constants
    uint internal minimumBet = 100000000000000;

    struct Bet {
        address user;
        bytes32 gameId;
        uint amount;
        uint8 chosenWinner;
    }

    enum GameOutcome {
        Pending,    //game has not been fought to decision
        Underway,   //game has started & is underway
        Draw,       //anything other than a clear winner (e.g. cancelled)
        Decided     //index of participant who is the winner 
    }

    /// @notice determines whether or not the user has already bet on the given game 
    /// @param _user address of a user 
    /// @param _gameId id of a game 
    /// @param _chosenWinner the index of the participant to bet on (to win) 
    /// @return true if the given user has already placed a bet on the given game 
    function _betIsValid(address _user, bytes32 _gameId, uint8 _chosenWinner) private view returns (bool) {
        
        return true;
    }

    /// @notice determines whether or not bets may still be accepted for the given game 
    /// @param _gameId id of a game 
    /// @return true if the game is bettable 
    function _gameOpenForBetting(bytes32 _gameId) private view returns (bool) {
        
        return true;
    }

 
    /// @notice gets a list ids of all currently bettable games
    /// @return array of game ids 
    function getBettableGames() public view returns (bytes32[] memory) {
        return footballOracle.getPendingGames(); 
    }

    /// @notice returns the full data of the specified game 
    /// @param _gameId the id of the desired game
    /// @return game data 
    function getGame(bytes32 _gameId) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        OracleInterface.GameOutcome outcome
        ) { 

        return footballOracle.getGame(_gameId); 
    }

    /// @notice returns the full data of the most recent bettable game 
    /// @return game data 
    function getMostRecentGame() public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        OracleInterface.GameOutcome outcome
        ) { 

        return footballOracle.getMostRecentGame(true); 
    }

    /// @notice places a non-rescindable bet on the given game 
    /// @param _gameId the id of the game on which to bet 
    /// @param _chosenWinner the index of the participant chosen as winner
    function placeBet(bytes32 _gameId, uint8 _chosenWinner) public payable {

        //bet must be above a certain minimum 
        require(msg.value >= minimumBet, "Bet amount must be >= minimum bet");

        //make sure that game exists 
        require(footballOracle.gameExists(_gameId), "Specified game not found"); 

        //require that chosen winner falls within the defined number of participants for game
        require(_betIsValid(msg.sender, _gameId, _chosenWinner), "Bet is not valid");

        //game must still be open for betting
        require(_gameOpenForBetting(_gameId), "Game not open for betting"); 

        //transfer the money into the account 
        //address(this).transfer(msg.value);

        //add the new bet 
        Bet[] storage bets = gameToBets[_gameId]; 
        bets.push(Bet(msg.sender, _gameId, msg.value, _chosenWinner))-1; 

        //add the mapping
        bytes32[] storage userBets = userToBets[msg.sender]; 
        userBets.push(_gameId); 
    }

    /// @notice sets the address of the boxing oracle contract to use 
    /// @dev setting a wrong address may result in false return value, or error 
    /// @param _oracleAddress the address of the boxing oracle 
    /// @return true if connection to the new oracle address was successful
    function setOracleAddress(address _oracleAddress) external onlyOwner returns (bool) {
        footballOracleAddr = _oracleAddress;
        footballOracle = OracleInterface(footballOracleAddr); 
        return footballOracle.testConnection();
    }

    /// @notice gets the address of the boxing oracle being used 
    /// @return the address of the currently set oracle 
    function getOracleAddress() external view returns (address) {
        return footballOracleAddr;
    }

    /// @notice for testing; tests that the boxing oracle is callable
    /// @return true if connection successful
    function testOracleConnection() public view returns (bool) {
        return footballOracle.testConnection(); 
    }
}
