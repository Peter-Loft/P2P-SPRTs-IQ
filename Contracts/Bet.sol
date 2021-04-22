pragma solidity >=0.5.0 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";
import "./BetMaker.sol";
import "./Housekeeping.sol";

/* @title This contract is the basic Bet creation tool
* @author Dirgeguy
* @notice This contract is intended to create bets accepts by users on the front-end and translate them into smart contracts. 
* @dev Currently, the deployment blockchain has not been chosen, so the contract will contain basic 
* infrastructure to support Loom, ETH, or other solidity accepting chains. This will also be as simplistic as possible to
* allow for BetMaker to call and create contracts for each new bet users want to create. This will be for the semi-centralized iteration
* of the decentralized P2P gambling app.
*/


contract BetContract {
    
    using SafeMath for uint256;
    
    address payable _issuer;
    address payable _taker;
    address payable _banker;
    
    constructor(
        address payable issuer,
        address payable taker,
        address payable banker
        ) 
        public {
            _issuer = issuer;
            _taker = taker;
            _banker = banker;
    }
    
    function _bet(uint _bag, uint16 _sport, uint16 _winCondition) external payable onlyOwner {
        require(msg.value == _bag);
        _betMade( _issuer, _taker, _bag, _sport, _winCondition);
    }
    
    function winnerWinner(bool _issuerWin) external onlyOwner {
        if(_issuerWin == true) {
            _issuer.transfer(address(this).balance.sub(address(this).balance.div(100)));
            _banker.transfer(address(this).balance);
        } else {
            _taker.transfer(address(this).balance.sub(address(this).balance.div(100)));
            _banker.transfer(address(this).balance);
        }
    }
    
}
