pragma solidity ^0.4.18;

import './CommonCrowdsale.sol';

contract TGE is CommonCrowdsale {
  
  function TGE() public {
    setMinInvestedLimit(100000000000000000);
    setPrice(4000000000000000000000);
    setBountyTokensPercent(50);
    setAdvisorsTokensPercent(20);
    setDevTokensPercent(30);
    setFoundersTokensPercent(50);
    setGrowthTokensPercent(300);
    setSecurityTokensPercent(5);
    setDevPercent(20);
    setSecurityPercent(10);

    // fix in prod
    addStage(7, 2850000000000000000000, 20);
    addStage(7, 5700000000000000000000, 10);
    addStage(7, 18280000000000000000000, 0);
    
    setStart(1514293200);
    setWallet(0x67d78de2f2819dcbd47426a1ac6a23b9e9c9d300);

    setBountyTokensWallet(0x872215ccf488031991f7dcc65e80a7c1fd497e75);
    setDevTokensWallet(0x97f2f8a94986d9049147590e12a64ffaa9f946a8);
    setAdvisorsTokensWallet(0x7bb6dbc29f8adb3a7627ea65372fe471509b7698);
    setFoundersTokensWallet(0x49ecc9e56979c884b28d8c791890e279ab1ec5f4);
    setGrowthTokensWallet(0x59ecc9e56979c884b28d8c791890e279ab1ec5f4);
    setDirectMintAgent(0xc66b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    setSecurityTokensWallet(0xc76b0d5bbc2bf9b760ebd797dacd3a683cb8498f);

    setDevWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    setSecurityWallet(0xc56b1d5bbc2bf9b760ebd797dacd3a683cb8498f);
  }

  function finishMinting() public onlyOwner {
    mintExtendedTokens();
    token.finishMinting();
  }

  function createTokens() public payable canMint(msg.value) {
    uint devWei = msg.value.mul(devPercent).div(PERCENT_RATE);
    uint securityWei = this.balance.mul(securityPercent).div(PERCENT_RATE);
    devWallet.transfer(devWei);
    securityWallet.transfer(securityWei);
    wallet.transfer(msg.value.sub(devWei).sub(securityWei));
    calculateAndTransferTokens(msg.sender, msg.value);
  } 

}

