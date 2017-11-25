pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract StagedCrowdsale is Ownable {

  using SafeMath for uint;

  uint public price;

  struct Stage {
    uint period;
    uint hardCap;
    uint discount;
    uint invested;
    uint closed;
  }

  uint public constant STAGES_PERCENT_RATE = 100;

  uint public start;

  uint public totalPeriod;

  uint public totalHardCap;
 
  uint public invested;

  Stage[] public stages;

  function stagesCount() public constant returns(uint) {
    return stages.length;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function addStage(uint period, uint hardCap, uint discount) public onlyOwner {
    require(period > 0 && hardCap > 0);
    stages.push(Stage(period, hardCap, discount, 0, 0));
    totalPeriod = totalPeriod.add(period);
    totalHardCap = totalHardCap.add(hardCap);
  }

  function removeStage(uint8 number) public onlyOwner {
    require(number >=0 && number < stages.length);

    Stage storage stage = stages[number];
    totalHardCap = totalHardCap.sub(stage.hardCap);    
    totalPeriod = totalPeriod.sub(stage.period);

    delete stages[number];

    for (uint i = number; i < stages.length - 1; i++) {
      stages[i] = stages[i+1];
    }

    stages.length--;
  }

  function changeStage(uint8 number, uint period, uint hardCap, uint discount) public onlyOwner {
    require(number >= 0 && number < stages.length);

    Stage storage stage = stages[number];

    totalHardCap = totalHardCap.sub(stage.hardCap);    
    totalPeriod = totalPeriod.sub(stage.period);    

    stage.hardCap = hardCap;
    stage.period = period;
    stage.discount = discount;

    totalHardCap = totalHardCap.add(hardCap);    
    totalPeriod = totalPeriod.add(period);    
  }

  function insertStage(uint8 numberAfter, uint period, uint hardCap, uint discount) public onlyOwner {
    require(numberAfter < stages.length);


    totalPeriod = totalPeriod.add(period);
    totalHardCap = totalHardCap.add(hardCap);

    stages.length++;

    for (uint i = stages.length - 2; i > numberAfter; i--) {
      stages[i + 1] = stages[i];
    }

    stages[numberAfter + 1] = Stage(period, hardCap, discount, 0, 0);
  }

  function clearStages() public onlyOwner {
    for (uint i = 0; i < stages.length; i++) {
      delete stages[i];
    }
    stages.length -= stages.length;
    totalPeriod = 0;
    totalHardCap = 0;
  }

  function lastSaleDate() public constant returns(uint) {
    require(stages.length > 0);
    uint lastDate = start;
    for(uint i=0; i < stages.length; i++) {
      if(stages[i].invested >= stages[i].hardCap) {
        lastDate = stages[i].closed;
      } else {
        lastDate = lastDate.add(stages[i].period * 1 days);
      }
    }
    return lastDate;
  }

  function currentStage() public constant returns(uint) {
    require(now >= start);
    uint previousDate = start;
    for(uint i=0; i < stages.length; i++) {
      if(stages[i].invested < stages[i].hardCap) {
        if(now >= previousDate && now < previousDate + stages[i].period * 1 days) {
          return i;
        }
        previousDate = previousDate.add(stages[i].period * 1 days);
      } else {
        previousDate = stages[i].closed;
      }
    }
    revert();
  }

  function updateStageWithInvested(uint stageIndex, uint investedInWei) internal {
    invested = invested.add(investedInWei);
    Stage storage stage = stages[stageIndex];
    stage.invested = stage.invested.add(investedInWei);
    if(stage.invested >= stage.hardCap) {
      stage.closed = now;
    }
  }


}

