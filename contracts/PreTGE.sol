pragma solidity ^0.4.18;

import './CommonCrowdsale.sol';

contract PreTGE is CommonCrowdsale {
  
  uint public softcap;
  
  bool public refundOn;

  bool public softcapAchieved;

  address public nextSaleAgent;

  mapping (address => uint) public balances;

  event RefundsEnabled();

  event SoftcapReached();

  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function PreTGE() public {
    setMinInvestedLimit(1000000000000000000);  
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
    setSoftcap(40000000000000000000);
    
    addStage(7, 570000000000000000000, 40);
    addStage(7, 1400000000000000000000, 30);
    addStage(7, 2570000000000000000000, 20);
    
    setStart(1512392400);
    setWallet(0xb8600b335332724df5108fc0595002409c2adbc6);
    setBountyTokensWallet(0x66ff3b89e15acb0b5e69179a2e54c494b89bdb1b);
    setDevTokensWallet(0x54a67f1507deb1bfc58ba3ffa94b59fc50eb74bc);
    setAdvisorsTokensWallet(0xd1bc33b2c89c93e65b0d476b8b50bfee82594847);
    setFoundersTokensWallet(0xe619bcd3c4609ae269b5ebe5bf0cb7d1dc70c210);
    setGrowthTokensWallet(0x39ecc9e56979c884b28d8c791890e279ab1ec5f4);
    setDevWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    setDirectMintAgent(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498e);
    setSecurityTokensWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498a);
    setSecurityWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498b);
  }

  function setNextSaleAgent(address newNextSaleAgent) public onlyOwner {
    nextSaleAgent = newNextSaleAgent;
  }

  function setSoftcap(uint newSoftcap) public onlyOwner {
    softcap = newSoftcap;
  }

  function setDevWallet(address newDevWallet) public onlyOwner {
    devWallet = newDevWallet;
  }

  function refund() public {
    require(now > start && refundOn && balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
    Refunded(msg.sender, value);
  } 

  function createTokens() public payable canMint(msg.value) {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    calculateAndTransferTokens(msg.sender, msg.value);
  } 

  function calculateAndTransferTokens(address to, uint investorWei) internal {
    super.calculateAndTransferTokens(to, investorWei);
    if(!softcapAchieved && invested >= softcap) {
      softcapAchieved = true;      
      SoftcapReached();
    }
  }

  function widthraw() public onlyOwner {
    require(softcapAchieved);
    uint devWei = this.balance.mul(devPercent).div(PERCENT_RATE);
    devWallet.transfer(devWei);
    uint securityWei = this.balance.mul(securityPercent).div(PERCENT_RATE);
    securityWallet.transfer(securityWei);
    wallet.transfer(this.balance);
  } 

  function finishMinting() public onlyOwner {
    if(!softcapAchieved) {
      refundOn = true;      
      token.finishMinting();
      RefundsEnabled();
    } else {
      widthraw();
      mintExtendedTokens();
      token.setSaleAgent(nextSaleAgent);
    }    
  }

}

