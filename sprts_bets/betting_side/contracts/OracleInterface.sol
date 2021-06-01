pragma solidity >=0.5.0;

contract OracleInterface {

    enum GameOutcome {
        Pending,    //game has not been fought to decision
        Underway,   //game has started & is underway
        Draw,       //anything other than a clear winner (e.g. cancelled)
        Decided     //index of participant who is the winner 
    }

    function getPendingGames() public view returns (bytes32[] memory);

    function getAllGames() public view returns (bytes32[] memory);

    function gameExists(bytes32 _matchId) public view returns (bool); 

    function getGame(bytes32 _matchId) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        GameOutcome outcome
        );

    function getMostRecentGame(bool _pending) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        GameOutcome outcome
        );

    function testConnection() public pure returns (bool);

    function addTestData() public; 
}
