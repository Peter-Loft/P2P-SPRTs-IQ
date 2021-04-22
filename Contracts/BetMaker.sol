pragma solidity >=0.5.0 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";



// @title This contract is the basic Bet creation tool
// @author Dirgeguy
// @notice This contract is intended to track, make, and payout bets created by users. 
// @dev This file will contain the bet factory used to as a portal to transcribe user bets from the front-end to the
// blockchain itself. This way, every bet will be secured and trackable on-chain. Still need to implement several aspects,
// specifically the tracking of new/open bet contracts, and then find a reasonably easy way to delete them from our front-end
// and free up space on the chain, if possible. 

contract BetMaker is Ownable {
    
    using SafeMath for uint256;
    
    // This event is to be used as an alert to front-end new bet has been created and to make it viewable 
    event BetMade(address issuer, address taker, uint betId, uint bag, uint16 sport, uint16 winCondition);
    
    mapping (uint => address) public betToOwner;
    mapping (address => uint) makerBetCount;
    
    address payable banker;
    address _bAddress;
    
    struct BetArray {
        address issuer;
        address taker;
        uint bag;
        uint16 sport;
        uint16 winCondition;
    } 
    
    BetArray[] public bets;
    
    // @dev This function's main intention is to accept parameters from a front-end interface and lock all conditions onto
    //      the chain. This function will create a separate contract holding a payload (value of total bet, i.e. _bag) and
    //      and have functionality to then, upon the completion of the bet (_winCondition is met or failed) the bag (minus 
    //      the fee levied by us) is distributed to the winner.
    
    function _commitBet(address payable _issuer, address payable _taker) public onlyOwner returns (address) {
       Bet _b = new Bet(_issuer, _taker, banker);
       _bAddress = address(_b);
       return _bAddress;
    }
    
    function newBet() public view returns (address) {
        return _bAddress;
    }
    
    function _betMade(address _issuer, address _taker, uint _bag, uint16 _sport, uint16 _winCondition) internal {
        // This is all the information we would need to create a full record of the bet transaction.
        uint id = bets.push(BetArray(_issuer, _taker, _bag, _sport, _winCondition)) - 1;
        betToOwner[id] = msg.sender;
        makerBetCount[msg.sender] = makerBetCount[msg.sender].add(1);
        emit BetMade(_issuer, _taker, id, _bag, _sport, _winCondition);
    }
    
    function getContractCount() public view returns (uint contractCount) {
        return bets.length;
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
    
    function _bet(uint _bag /*, uint16 _sport, uint16 _winCondition*/) external payable {
        require(msg.value == _bag);
        // _betMade( _issuer, _taker, _bag, _sport, _winCondition);
    }
    
    function winnerWinner(bool _issuerWin) external {
        require(_banker == msg.sender, "Caller is not authorized for this function");
            if(_issuerWin == true) {
                _issuer.transfer(address(this).balance.sub(address(this).balance.div(100)));
                _banker.transfer(address(this).balance);
            } else {
                _taker.transfer(address(this).balance.sub(address(this).balance.div(100)));
                _banker.transfer(address(this).balance);
            }
    }
    
}
