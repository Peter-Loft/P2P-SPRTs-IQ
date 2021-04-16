pragma solidity >=0.5.0 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";

// @title This contract is the basic Bet creation tool
// @author Dirgeguy
// @notice This contract is intended to track, make, and payout bets created by users. 
// @dev Currently, the deployment blockchain has not been chosen, so the contract will contain basic 
//  infrastructure to support Loom, ETH, or other solidity accepting chains.

contract BetMaker is Ownable {
    
    using SafeMath for uint256;
    
    // This event is to be used should we allow bets to be created w/o a contra party, so we would only need to track the 
    // event BetIssued(address issuer, uint betId, uint bag);
    event BetMade(address issuer, address taker, uint betId, uint bag, uint8 sport, uint8 winCondition);
    
    
    mapping (uint => address) public betToOwner;
    mapping (address => uint) makerBetCount;
    
    struct Bet {
        address issuer;
        address taker;
        uint bag;
        uint8 sport;
        uint8 winCondition;
    } 
    
    Bet[] public bets;
    
    // @dev This function's main intention is to accept parameters from a front-end interface and lock all conditions onto
    //      the chain. This function will create a separate contract holding a payload (value of total bet, i.e. _bag) and
    //      and have functionality to then, upon the completion of the bet (_winCondition is met or failed) the bag (minus 
    //      the fee levied by us) is distributed to the winner. 
    function _Bet(address _issuer, address _taker, uint _bag, uint8 _sport, uint8 _winCondition) public {
        
        
        // This is all the information we would need to create a full record of the bet transaction.
        uint id = bets.push(Bet(_issuer, _taker, _bag, _sport, _winCondition)) - 1;
        betToOwner[id] = msg.sender;
        makerBetCount[msg.sender] = makerBetCount[msg.sender].add(1);
        emit BetMade(_issuer, _taker, id, _bag, _sport, _winCondition);
    }
    
    
    
    // This function will be used to query the Oracles and verify the outcome of the sport and winCondition to determine 
    // who receives the bag
    function _payout() internal {
        
    }
}
