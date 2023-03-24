//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import ".deps/npm/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vesting {
    IERC20 token;
    address _benificiary;
    // uint256 _totalTokens;
    // uint256 _startTime; 
    // uint256 _cliff;
    // uint256 _vestingPeriod;
    // uint256 _slicePeriod;
    // address public owner;
    // uint256 public vestedTokens;
    // uint256 public _elaspTime;
    // uint256 _relesedTokens;

    mapping(address=>uint256) vestedAmount;
    mapping(address=>uint256) public withdrawableAmount;
  

    // mapping(address=>uint256) _totalTokens;
    // mapping(address=>uint256) _startTime;
    // mapping(address=>uint256) _cliff;
    // mapping(address=>uint256) _vestingPeriod;
    // mapping(address=>uint256) _slicePeriod;




    constructor(address _token) {
        token = IERC20(_token);
        // owner = msg.sender;
    }

    struct VestingSchedule {
    uint256 _startTime;
    uint256 _cliff;
    uint256 _vestingPeriod;
    uint256 _slicePeriod;
    uint256 _totalTokens;
    uint256 _releasedTokens;
    uint256 _vestedTokens;
    uint256 _elaspTime;
}
mapping(address => VestingSchedule) public vestingSchedules;



    function addAmountToVest(address benificiary,uint256 totalTokens, uint256 startTime,uint256 cliff,uint256 vestingPeriod,uint256 slicePeriod) public payable {
        
        vestingSchedules[benificiary] = VestingSchedule({
        _startTime : startTime,
        _cliff : cliff ,
        _vestingPeriod : vestingPeriod,
        _slicePeriod : slicePeriod,
        _totalTokens : totalTokens,
        _releasedTokens : 0,
        _vestedTokens : 0 ,
        _elaspTime : 0
        });

        // _totalTokens[benificiary]=totalTokens;
        // _startTime[benificiary]=startTime;
        // _cliff[benificiary]=cliff;
        // _vestingPeriod[benificiary]=vestingPeriod;
        // _slicePeriod[benificiary]=slicePeriod;


    } 

    function checkBalance(address account) view public returns(uint256){
        return token.balanceOf(account);
    }

    function release() public returns(uint256) {
        withdrawableAmount[_benificiary]+=calculateVestedAmount();
        return withdrawableAmount[_benificiary];
    }

    function calculateVestedAmount() public returns(uint256) {
        require(vestingSchedules[_benificiary]._startTime+vestingSchedules[_benificiary]._slicePeriod <= block.timestamp,"No Token vested yet");
        
        uint256 intervals = (vestingSchedules[_benificiary]._vestingPeriod) / (vestingSchedules[_benificiary]._slicePeriod);
        uint256 tokensInInterval = vestingSchedules[_benificiary]._totalTokens /intervals;

        uint256 currentTime = block.timestamp;   
        if(currentTime >= (vestingSchedules[_benificiary]._startTime)+(vestingSchedules[_benificiary]._vestingPeriod)){
            currentTime = (vestingSchedules[_benificiary]._startTime)+(vestingSchedules[_benificiary]._vestingPeriod);
        }                 
        vestingSchedules[_benificiary]._elaspTime = currentTime - vestingSchedules[_benificiary]._startTime;
        uint256 intervalElasped = vestingSchedules[_benificiary]._elaspTime/ intervals;
        
        vestingSchedules[_benificiary]._vestedTokens = (intervalElasped * tokensInInterval)-vestingSchedules[_benificiary]._releasedTokens;
        vestingSchedules[_benificiary]._releasedTokens += vestingSchedules[_benificiary]._vestedTokens;
        vestedAmount[_benificiary]+=vestingSchedules[_benificiary]._vestedTokens;

        return vestingSchedules[_benificiary]._vestedTokens;
    }

    function withdraw(uint256 withdrawAmount) public {
        require(_benificiary == msg.sender,"Only benificiar can withdraw");
        require(withdrawableAmount[_benificiary]>0,"No amount to be withdrawn");
        withdrawableAmount[_benificiary]-=withdrawAmount;
        token.transferFrom(address(this),_benificiary,withdrawAmount);       

    }


    // function currentTime() public view returns(uint256){
    //     return block.timestamp;
    // }
    

}