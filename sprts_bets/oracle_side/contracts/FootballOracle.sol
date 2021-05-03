pragma solidity >=0.5.0;

import "./Ownable.sol";
import "./DateLib.sol";

/*
TEST: 
- testConnection 
- getAddress
- gameExists(0) 
- gameExists(1)
- declareOutcome(0, 2)
- getPendingGames()
- getAllGames()
- getGame(0)
- getMostRecentGame(true)
- addTestData()
- gameExists(0) 
- gameExists(1)
- declareOutcome(0, 2)
- getPendingGames()               
- getAllGames()                   
- getGame(0)
- getMostRecentGame(true)
- getMostRecentGame(false) 
- getGame(0x...)                   
- declareOutcome(0x..., 2)              
- getMostRecentGame(true)
- getMostRecentGame(false)
- getGame(0x...)              
- add duplicate Game      
*/

/// @title FootballOracle
/// @author Peter S. Loft (Adapted from John R. Kosinski) for American Football
/// @notice Collects and provides information on football games and their outcomes 
contract FootballOracle is Ownable {
    Game[] games; 
    mapping(bytes32 => uint) gameIdToIndex; 

    using DateLib for DateLib.DateTime;




    //defines a game along with its outcome
    struct Game {
        bytes32 id;
        string name;
        uint8 visitor;
        uint8 home;
        uint8 winner;
        uint8 line;
        uint date; 
        GameOutcome outcome;
    }

    //possible game outcomes 
    enum GameOutcome {
        Pending,    //game has not been decided
        Underway,   //game has started & is underway
        Draw,       //anything other than a clear winner (e.g. cancelled)
        Decided     //index of participant who is the winner 
    }


    /// @notice returns the array index of the game with the given id 
    /// @dev if the game id is invalid, then the return value will be incorrect and may cause error; you must call gameExists(_gameId) first!
    /// @param _gameId the game id to get
    /// @return an array index 
    function _getGameIndex(bytes32 _gameId) private view returns (uint) {
        return gameIdToIndex[_gameId]-1; 
    }


    /// @notice determines whether a game exists with the given id 
    /// @param _gameId the game id to test
    /// @return true if game exists and id is valid
    function gameExists(bytes32 _gameId) public view returns (bool) {
        if (games.length == 0)
            return false;
        uint index = gameIdToIndex[_gameId]; 
        return (index > 0); 
    }

    /// @notice puts a new pending game into the blockchain 
    /// @param _name descriptive name for the game (e.g. Seahwaks vs 49ers)
    /// @param _visitor visiting team (teams should be represented with numbers 1-32)
    /// @param _home hosting team
    /// @param _line the line for the favored team to win by for a victory
    /// @param _date date set for the game 
    /// @return the unique id of the newly created game 
    function addGame(string memory _name, uint8 _visitor, uint8 _home, uint8 _line, uint _date) onlyOwner public returns (bytes32) {

        //hash the crucial info to get a unique id 
        bytes32 id = keccak256(abi.encodePacked(_name, _visitor, _home, _date)); 

        //require that the game be unique (not already added) 
        require(!gameExists(id));
        
        //add the game 
        uint newIndex = games.push(Game(id, _name, _visitor, _home, _line, 0, _date, GameOutcome.Pending))-1; 
        gameIdToIndex[id] = newIndex+1;
        
        //return the unique id of the new game
        return id;
    }

    /// @notice sets the outcome of a predefined game, permanently on the blockchain
    /// @param _gameId unique id of the game to modify
    /// @param _outcome outcome of the game 
    function declareOutcome(bytes32 _gameId, GameOutcome _outcome, uint8 _winner) onlyOwner external {

        //require that it exists
        require(gameExists(_gameId)); 

        //get the game 
        uint index = _getGameIndex(_gameId); 
        Game storage theGame = games[index]; 

        if (_outcome == GameOutcome.Decided) 
            require(_winner >= 0); 

        //set the outcome 
        theGame.outcome = _outcome;
        
        //set the winner (if there is one)
        if (_outcome == GameOutcome.Decided) 
            theGame.winner = _winner;
    }

    /// @notice gets the unique ids of all pending games, in reverse chronological order
    /// @return an array of unique game ids
    function getPendingGames() public view returns (bytes32[] memory) {
        uint count = 0; 

        //get count of pending games 
        for (uint i = 0; i < games.length; i++) {
            if (games[i].outcome == GameOutcome.Pending) 
                count++; 
        }

        //collect up all the pending games
        bytes32[] memory output = new bytes32[](count); 

        if (count > 0) {
            uint index = 0;
            for (uint n = games.length; n > 0; n--) {
                if (games[n-1].outcome == GameOutcome.Pending) 
                    output[index++] = games[n-1].id;
            }
        } 

        return output; 
    }

    /// @notice gets the unique ids of games, pending and decided, in reverse chronological order
    /// @return an array of unique game ids
    function getAllGames() public view returns (bytes32[] memory) {
        bytes32[] memory output = new bytes32[](games.length); 

        //get all ids 
        if (games.length > 0) {
            uint index = 0;
            for (uint n = games.length; n > 0; n--) {
                output[index++] = games[n-1].id;
            }
        }
        
        return output; 
    }

    /// @notice gets the specified game 
    /// @param _gameId the unique id of the desired game 
    /// @return game data of the specified game 
    function getGame(bytes32 _gameId) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        GameOutcome outcome
        ) {
        
        //get the game 
        if (gameExists(_gameId)) {
            Game storage theGame = games[_getGameIndex(_gameId)];
            return (theGame.id, theGame.name, theGame.visitor, theGame.home, theGame.winner, theGame.line, theGame.date, theGame.outcome); 
        }
        else {
            return (_gameId, "", 0, 0, 0, 0, 0, GameOutcome.Pending); 
        }
    }

    /// @notice gets the most recent game or pending game 
    /// @param _pending if true, will return only the most recent pending game; otherwise, returns the most recent game either pending or completed
    /// @return game data 
    function getMostRecentGame(bool _pending) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        GameOutcome outcome
        ) {

        bytes32 gameId = 0; 
        bytes32[] memory ids;

        if (_pending) {
            ids = getPendingGames(); 
        } else {
            ids = getAllGames();
        }
        if (ids.length > 0) {
            gameId = ids[0]; 
        }
        
        //by default, return a null game
        return getGame(gameId); 
    }

    /// @notice can be used by a client contract to ensure that they've connected to this contract interface successfully
    /// @return true, unconditionally 
    function testConnection() public pure returns (bool) {
        return true; 
    }

    /// @notice gets the address of this contract 
    /// @return address 
    function getAddress() public view returns (address) {
        return address(this);
    }

    /// @notice for testing
    function addTestData() external onlyOwner {
        addGame("Seahawks vs. 49ers", 28, 1, 3, DateLib.DateTime(2018, 8, 13, 0, 0, 0, 0, 0).toUnixTimestamp());
        addGame("49ers vs. Seahawks", 1, 28, 6, DateLib.DateTime(2018, 8, 15, 0, 0, 0, 0, 0).toUnixTimestamp());
        addGame("Bears vs. Bengals", 2, 3, 7, DateLib.DateTime(2018, 9, 3, 0, 0, 0, 0, 0).toUnixTimestamp());
        addGame("Bengals vs. Bears", 3, 2, 10, DateLib.DateTime(2018, 9, 3, 0, 0, 0, 0, 0).toUnixTimestamp());
        // addGame("Macaque vs. Pregunto", "Macaque|Pregunto", 2, DateLib.DateTime(2018, 9, 21, 0, 0, 0, 0, 0).toUnixTimestamp());
        // addGame("Farsworth vs. Wernstrom", "Farsworth|Wernstrom", 2, DateLib.DateTime(2018, 9, 29, 0, 0, 0, 0, 0).toUnixTimestamp());
        // addGame("Fortinbras vs. Hamlet", "Fortinbras|Hamlet", 2, DateLib.DateTime(2018, 10, 10, 0, 0, 0, 0, 0).toUnixTimestamp());
        // addGame("Foolicle vs. Pretendo", "Foolicle|Pretendo", 2, DateLib.DateTime(2018, 11, 11, 0, 0, 0, 0, 0).toUnixTimestamp());
        // addGame("Parthian vs. Scythian", "Parthian|Scythian", 2, DateLib.DateTime(2018, 11, 12, 0, 0, 0, 0, 0).toUnixTimestamp());
    }
}