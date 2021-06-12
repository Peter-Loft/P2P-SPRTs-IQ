pragma solidity >=0.5.0;

import "./FootballBet.sol";
import "./SafeMath.sol";
import "./OracleInterface.sol";

/// @notice acts as the main interaction point between the oracle and users
contract BetPayout is FootballBets {

    using SafeMath for uint; 

    //constants 
    uint housePercentage = 1; 
    uint multFactor = 1000000;

    /// @notice pays out winnings to a user 
    /// @param _user the user to whom to pay out 
    /// @param _amount the amount to pay out 
    function _payOutWinnings(address _user, uint _amount) private {
        _user.transfer(_amount);
    }

    /// @notice transfers any remaining to the house (the house's cut)
    function _transferToHouse() private {
        owner.transfer(address(this).balance);
    }

    /// @notice determines whether or not the given bet is a winner 
    /// @param _outcome the game's actual outcome
    /// @param _chosenWinner the participant chosen by the bettor as the winner 
    /// @param _actualWinner the actual winner 
    /// @return true if the bet was a winner
    function _isWinningBet(OracleInterface.GameOutcome _outcome, uint8 _chosenWinner, uint8 _actualWinner) private pure returns (bool) {
        return _outcome == OracleInterface.GameOutcome.Decided && _chosenWinner >= 0 && (_chosenWinner == uint8(_actualWinner)); 
    }

    /// @notice calculates the amount to be paid out for a bet of the given amount, under the given circumstances
    /// @param _winningTotal the total monetary amount of winning bets 
    /// @param _totalPot the total amount in the pot for the game 
    /// @param _betAmount the amount of this particular bet 
    /// @return an amount in wei
    function _calculatePayout(uint _winningTotal, uint _totalPot, uint _betAmount) private view returns (uint) {
        //calculate proportion
        uint proportion = (_betAmount.mul(multFactor)).div(_winningTotal);
        
        //calculate raw share
        uint rawShare = _totalPot.mul(proportion).div(multFactor);

        //if share has been rounded down to zero, fix that 
        if (rawShare == 0) 
            rawShare = minimumBet;
        
        //take out house's cut 
        rawShare = rawShare/(100 * housePercentage);
        return rawShare;
    }

    /// @notice calculates how much to pay out to each winner, then pays each winner the appropriate amount 
    /// @param _gameId the unique id of the game
    /// @param _outcome the game's outcome
    /// @param _winner the index of the winner of the game (if not a draw)
    function _payOutForGame(bytes32 _gameId, OracleInterface.GameOutcome _outcome, uint8 _winner) private {
    
        Bet[] storage bets = gameToBets[_gameId]; 
        uint losingTotal = 0; 
        uint winningTotal = 0; 
        uint totalPot = 0;
        uint[] memory payouts = new uint[](bets.length);
        
        //count winning bets & get total 
        uint n;
        for (n = 0; n < bets.length; n++) {
            uint amount = bets[n].amount;
            if (_isWinningBet(_outcome, bets[n].chosenWinner, _winner)) {
                winningTotal = winningTotal.add(amount);
            } else {
                losingTotal = losingTotal.add(amount);
            }
        }
        totalPot = (losingTotal.add(winningTotal)); 

        //calculate payouts per bet 
        for (n = 0; n < bets.length; n++) {
            if (_outcome == OracleInterface.GameOutcome.Draw) {
                payouts[n] = bets[n].amount;
            } else {
                if (_isWinningBet(_outcome, bets[n].chosenWinner, _winner)) {
                    payouts[n] = _calculatePayout(winningTotal, totalPot, bets[n].amount); 
                } else {
                    payouts[n] = 0;
                }
            }
        }

        //pay out the payouts 
        for (n = 0; n < payouts.length; n++) {
            _payOutWinnings(bets[n].user, payouts[n]); 
        }

        //transfer the remainder to the owner
        _transferToHouse();
    }
    
    
    /// @notice check the outcome of the given game; if ready, will trigger calculation of payout, and actual payout to winners
    /// @param _gameId the id of the game to check
    /// @return the outcome of the given game 
    function checkOutcome(bytes32 _gameId) public returns (OracleInterface.GameOutcome) {
        OracleInterface.GameOutcome outcome; 
        uint8 winner;

        (,,,,winner,,,outcome) = footballOracle.getGame(_gameId); 

        if (outcome == OracleInterface.GameOutcome.Decided) {
            if (!gamePaidOut[_gameId]) {
                _payOutForGame(_gameId, outcome, winner);
            }
        } 

        return outcome; 
    }

    function refund()
}
