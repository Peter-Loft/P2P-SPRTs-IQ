pragma solidity >=0.5.0;

contract OracleInterface {

    enum MatchOutcome {
        Pending,    //match has not been fought to decision
        Underway,   //match has started & is underway
        Draw,       //anything other than a clear winner (e.g. cancelled)
        Decided     //index of participant who is the winner 
    }

    function getPendingMatches() public view returns (bytes32[] memory);

    function getAllMatches() public view returns (bytes32[] memory);

    function matchExists(bytes32 _matchId) public view returns (bool); 

    function getMatch(bytes32 _matchId) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        MatchOutcome outcome
        );

    function getMostRecentMatch(bool _pending) public view returns (
        bytes32 id,
        string memory name,
        uint8 visitor,
        uint8 home,
        uint8 winner,
        uint8 line,
        uint date, 
        MatchOutcome outcome
        );

    function testConnection() public pure returns (bool);

    function addTestData() public; 
}