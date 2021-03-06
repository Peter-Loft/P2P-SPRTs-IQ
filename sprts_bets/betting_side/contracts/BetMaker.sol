pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";

/* 
* @title This contract is the basic Bet creation tool
* @author Dirgeguy
* @notice This contract is intended to track, make, and payout bets created by users. 
* @dev This file will contain the bet factory used to as a portal to transcribe user bets from the front-end to the
* blockchain itself. This way, every bet will be secured and trackable on-chain. Still need to implement several aspects,
* specifically the tracking of new/open bet contracts, and then find a reasonably easy way to delete them from our front-end
* and free up space on the chain, if possible.
*/ 

contract BetMaker is Ownable {
    
    using SafeMath for uint256;
    
    // This event is to be used as an alert to front-end new bet has been created and to make it viewable 
    event BetMade(address betContract, address issuer, address taker, uint betId, uint16 sport, uint16 winCondition);
    
    mapping (uint => address) public betToOwner;
    mapping (address => uint) makerBetCount;
    
    mapping (uint => address) public betToTaker;
    mapping (address => uint) takerBetCount;
    
    address payable banker;
    address _bAddress;
    
    struct BetArray {
        address betContract;
        address issuer;
        address taker;
        uint16 sport;
        uint16 winCondition;
    } 
    address[] public liveBets;
    BetArray[] public bets;
    
    /* @dev This function's main intention is to accept parameters from a front-end interface and lock all conditions onto
    *      the chain. This function will create a separate contract holding a payload (value of total bet, i.e. _bag) and
    *      and have functionality to then, upon the completion of the bet (_winCondition is met or failed) the bag (minus 
    *      the fee levied by us) is distributed to the winner.
    */
    
    // Currently this aspect of the contract is not working and there seems to be an issue with the mapping. 
    function getBetsByMaker(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](makerBetCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < bets.length; i = i.add(1)) {
          if (betToOwner[i] == _owner) {
            result[counter] = i;
            counter = counter.add(1);
          }
        }
    }
    
    
    function _commitBet(address payable _issuer, address payable _taker, uint16 _sport, uint16 _winCondition) public onlyOwner returns (address) {
        Bet _b = new Bet(_issuer, _taker, banker, _sport, _winCondition);
        _bAddress = address(_b);
        uint id = bets.push(BetArray(_bAddress, _issuer, _taker, _sport, _winCondition)) - 1;
        betToOwner[id] = _issuer;
        makerBetCount[_issuer] = makerBetCount[_issuer].add(1);
        liveBets.push(_bAddress);
        emit BetMade(_bAddress, _issuer, _taker, id, _sport, _winCondition);
        return _bAddress;
    }
    
    function newBet() external view returns (address) {
        return _bAddress;
    }
    
    function _setbank(address payable _bank) public onlyOwner {
        banker = _bank;
    }

}


contract Bet {
    
    using SafeMath for uint256;
    
    address payable _issuer;
    address payable _taker;
    address payable _banker;
    uint16 _sport;
    uint16 _winCondition;
    
    
    constructor(
        address payable issuer,
        address payable taker,
        address payable banker,
        uint16 sport,
        uint16 winCondition
        ) 
        public {
            _issuer = issuer;
            _taker = taker;
            _banker = banker;
            _sport = sport;
            _winCondition = winCondition;
    }
    
    function _bet(uint _bag) external payable {
        require(_bag > 4999999999999);
        require(msg.value == _bag, "Not enough money, dumba$$");
    }
    
    
    // This is currently a simple implementation that should allow a trusted banking contract to disperse the funds.
    // Ideally will eventual replace with a trusted Oracle integration.
    function _winnerWinner(bool _issuerWin) external {
        require(_banker == msg.sender, "You are not authorized for this function");
            if(_issuerWin == true) {
                _issuer.transfer(address(this).balance.sub(address(this).balance.div(100)));
                _banker.transfer(address(this).balance);
            } else {
                _taker.transfer(address(this).balance.sub(address(this).balance.div(100)));
                _banker.transfer(address(this).balance);
            }
    }
    
    
    
}