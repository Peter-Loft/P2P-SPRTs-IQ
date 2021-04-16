pragma solidity >=0.5.0 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";
import "./Bet.sol";


// @dev This contract is to be used in the case of bet issuances to be aggregated on a marketplace for takers to browse
//      currently, this is a possible option for implementation, if the plan is to go completely decentalized. With centralized
//      infrastructure relating to the bet making, no need to commit anything to blockchain until both sides have accepted.
contract SingleSide is Ownable, BetMaker {
    
    using SafeMath for uint256;
    
    event BetIssued(address issuer, uint betId, uint bag, uint8 sport, uint8 winCondition);
    
    Bet[] public issuerBets;
    
    // @dev this function is to take all the necessary inputs for a bet object and then create the 
    function _issuerBet(address _issuer, uint _bag, uint8 _sport, uint8 _winCondition) public {
        
        
        // This is all the information we would need to create a full record of the bet transaction.
        uint id = issuerBets.push(Bet(_issuer, _bag, _sport, _winCondition)) - 1;
        betToOwner[id] = msg.sender;
        makerBetCount[msg.sender] = makerBetCount[msg.sender].add(1);
        emit BetMade(_issuer, _taker, id, _bag, _sport, _winCondition);
        
    }
    
    // This function will be used to determine how long an unpaired bet can last on the chain until it is refunded
    // @dev currently going to rely on Orcales as confirmation of game/event conclusion. 
    function _countdown() internal {
        
    }
}
