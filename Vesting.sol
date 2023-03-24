//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import ".deps/npm/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vesting {
    IERC20 token;
    address _benificiary;
    uint256 _totalTokens;
    uint256 _startTime; 
    uint256 _cliff;
    uint256 _vestingPeriod;
    uint256 _slicePeriod;
    address public owner;
    uint256 public vestedTokens;
    uint256 public _elaspTime;
    uint256 _relesedTokens;

    mapping(address=>uint256) vestedAmount;
    mapping(address=>uint256) public withdrawableAmount;
  

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function addAmountToVest(address benificiary,uint256 totalTokens, uint256 startTime,uint256 cliff,uint256 vestingPeriod,uint256 slicePeriod) public payable {
        _benificiary = benificiary;
        _totalTokens = totalTokens;
        require(token.approve(address(this),totalTokens), "Approval failed");
        token.transferFrom(_benificiary,address(this),totalTokens);
        _startTime = startTime + cliff;
        _cliff = cliff;
        _vestingPeriod = vestingPeriod;
        _slicePeriod = slicePeriod;
    } 

    function checkBalance(address name) view public returns(uint256){
        return token.balanceOf(name);
    }

    function release() public returns(uint256) {
        withdrawableAmount[_benificiary]+=calculateVestedAmount();
        return withdrawableAmount[_benificiary];
    }

    function calculateVestedAmount() public returns(uint256) {
        require(_startTime+_slicePeriod <= block.timestamp,"No Token vested yet");
        
        uint256 intervals = _vestingPeriod / _slicePeriod;
        uint256 tokensInInterval = _totalTokens /intervals;

        uint256 currentTime = block.timestamp;   
        if(currentTime >= _startTime+_vestingPeriod){
            currentTime = _startTime+_vestingPeriod;
        }            
        _elaspTime = currentTime - _startTime;
        uint256 intervalElasped = _elaspTime/ intervals;
        
        vestedTokens = (intervalElasped * tokensInInterval)-_relesedTokens;
        _relesedTokens += vestedTokens;
        vestedAmount[_benificiary]+=vestedTokens;

        return vestedTokens;
    }

    function withdraw(uint256 withdrawAmount) public {
        require(_benificiary == msg.sender,"Only benificiar can withdraw");
        require(withdrawableAmount[_benificiary]>0,"No amount to be withdrawn");
        withdrawableAmount[_benificiary]-=withdrawAmount;
        token.transfer(_benificiary,withdrawAmount);       

    }


    // function currentTime() public view returns(uint256){
    //     return block.timestamp;
    // }
    

}