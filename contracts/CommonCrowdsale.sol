pragma solidity ^0.4.18;

import './StagedCrowdsale.sol';
import './TaskFairToken.sol';

contract CommonCrowdsale is StagedCrowdsale {

  uint public constant PERCENT_RATE = 1000;

  uint public minInvestedLimit;

  uint public minted;

  address public directMintAgent;
  
  address public wallet;

  address public devWallet;

  address public devTokensWallet;

  address public securityWallet;

  address public foundersTokensWallet;

  address public bountyTokensWallet;

  address public growthTokensWallet;

  address public advisorsTokensWallet;

  address public securityTokensWallet;

  uint public devPercent;

  uint public securityPercent;

  uint public bountyTokensPercent;

  uint public devTokensPercent;

  uint public advisorsTokensPercent;

  uint public foundersTokensPercent;

  uint public growthTokensPercent;

  uint public securityTokensPercent;

  TaskFairToken public token;

  modifier canMint(uint value) {
    require(now >= start && value >= minInvestedLimit);
    _;
  }

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  function setMinInvestedLimit(uint newMinInvestedLimit) public onlyOwner {
    minInvestedLimit = newMinInvestedLimit;
  }

  function setDevPercent(uint newDevPercent) public onlyOwner { 
    devPercent = newDevPercent;
  }

  function setSecurityPercent(uint newSecurityPercent) public onlyOwner { 
    securityPercent = newSecurityPercent;
  }

  function setBountyTokensPercent(uint newBountyTokensPercent) public onlyOwner { 
    bountyTokensPercent = newBountyTokensPercent;
  }

  function setGrowthTokensPercent(uint newGrowthTokensPercent) public onlyOwner { 
    growthTokensPercent = newGrowthTokensPercent;
  }

  function setFoundersTokensPercent(uint newFoundersTokensPercent) public onlyOwner { 
    foundersTokensPercent = newFoundersTokensPercent;
  }

  function setAdvisorsTokensPercent(uint newAdvisorsTokensPercent) public onlyOwner { 
    advisorsTokensPercent = newAdvisorsTokensPercent;
  }

  function setDevTokensPercent(uint newDevTokensPercent) public onlyOwner { 
    devTokensPercent = newDevTokensPercent;
  }

  function setSecurityTokensPercent(uint newSecurityTokensPercent) public onlyOwner { 
    securityTokensPercent = newSecurityTokensPercent;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner { 
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setGrowthTokensWallet(address newGrowthTokensWallet) public onlyOwner { 
    growthTokensWallet = newGrowthTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner { 
    bountyTokensWallet = newBountyTokensWallet;
  }

  function setAdvisorsTokensWallet(address newAdvisorsTokensWallet) public onlyOwner { 
    advisorsTokensWallet = newAdvisorsTokensWallet;
  }

  function setDevTokensWallet(address newDevTokensWallet) public onlyOwner { 
    devTokensWallet = newDevTokensWallet;
  }

  function setSecurityTokensWallet(address newSecurityTokensWallet) public onlyOwner { 
    securityTokensWallet = newSecurityTokensWallet;
  }

  function setWallet(address newWallet) public onlyOwner { 
    wallet = newWallet;
  }

  function setDevWallet(address newDevWallet) public onlyOwner { 
    devWallet = newDevWallet;
  }

  function setSecurityWallet(address newSecurityWallet) public onlyOwner { 
    securityWallet = newSecurityWallet;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function directMint(address to, uint investedWei) public onlyDirectMintAgentOrOwner canMint(investedWei) {
    calculateAndTransferTokens(to, investedWei);
  }

  function setStart(uint newStart) public onlyOwner { 
    start = newStart;
  }

  function setToken(address newToken) public onlyOwner { 
    token = TaskFairToken(newToken);
  }

  function mintExtendedTokens() internal {
    uint extendedTokensPercent = bountyTokensPercent.add(devTokensPercent).add(advisorsTokensPercent).add(foundersTokensPercent).add(growthTokensPercent).add(securityTokensPercent);
    uint allTokens = minted.mul(PERCENT_RATE).div(PERCENT_RATE.sub(extendedTokensPercent));

    uint bountyTokens = allTokens.mul(bountyTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(bountyTokensWallet, bountyTokens);

    uint advisorsTokens = allTokens.mul(advisorsTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(advisorsTokensWallet, advisorsTokens);

    uint foundersTokens = allTokens.mul(foundersTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(foundersTokensWallet, foundersTokens);

    uint growthTokens = allTokens.mul(growthTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(growthTokensWallet, growthTokens);

    uint devTokens = allTokens.mul(devTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(devTokensWallet, devTokens);

    uint secuirtyTokens = allTokens.mul(securityTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(securityTokensWallet, secuirtyTokens);
  }

  function mintAndSendTokens(address to, uint amount) internal {
    token.mint(to, amount);
    minted = minted.add(amount);
  }

  function calculateAndTransferTokens(address to, uint investedInWei) internal {
    uint stageIndex = currentStage();
    Stage storage stage = stages[stageIndex];

    // calculate tokens
    uint tokens = investedInWei.mul(price).mul(STAGES_PERCENT_RATE).div(STAGES_PERCENT_RATE.sub(stage.discount)).div(1 ether);
    
    // transfer tokens
    mintAndSendTokens(to, tokens);

    updateStageWithInvested(stageIndex, investedInWei);
  }

  function createTokens() public payable;

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(wallet, alienToken.balanceOf(this));
  }

}

