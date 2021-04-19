pragma solidity >=0.5.0 <0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";
import "./Bet.sol";

contract HouseKeeper is BetMaker {
    
    using SafeMath for uint256;
    
    function getBetsbyMaker(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](makerBetCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < bets.length; i = i.add(1)) {
          if (betToOwner[i] == _owner) {
            result[counter] = i;
            counter = counter.add(1);
          }
        }
    }
        
}
