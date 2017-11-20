pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function () public payable {
    revert();
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract TaskFairToken is StandardToken, Ownable {	

  using SafeMath for uint256;

  event Mint(address indexed to, uint256 amount);

  event MintFinished();
    
  string public constant name = "Task Fair Token";
   
  string public constant symbol = "TFT";
    
  uint32 public constant decimals = 18;

  bool public mintingFinished = false;
 
  address public saleAgent;

  modifier notLocked() {
    require(msg.sender == owner || msg.sender == saleAgent || mintingFinished);
    _;
  }

  function transfer(address _to, uint256 _value) public notLocked returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address from, address to, uint256 value) public notLocked returns (bool) {
    return super.transferFrom(from, to, value);
  }

  function setSaleAgent(address newSaleAgent) public {
    require(saleAgent == msg.sender || owner == msg.sender);
    saleAgent = newSaleAgent;
  }

  function mint(address _to, uint256 _amount) public returns (bool) {
    require(!mintingFinished);
    require(msg.sender == saleAgent);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() public returns (bool) {
    require(!mintingFinished);
    require(msg.sender == owner || msg.sender == saleAgent);
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

contract CommonCrowdsale is Ownable {

  using SafeMath for uint256;

  uint public constant PERCENT_RATE = 1000;

  uint public price;

  uint public minInvestedLimit;

  uint public hardcap;

  uint public start;

  uint public end;

  uint public invested;

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

  struct Bonus {
    uint periodInDays;
    uint bonus;
  }

  Bonus[] public bonuses;

  TaskFairToken public token;

  modifier saleIsOn() {
    require(msg.value >= minInvestedLimit && now >= start && now < end && invested < hardcap);
    _;
  }

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function directMint(address to, uint investedWei) public onlyDirectMintAgentOrOwner saleIsOn {
    calculateAndTransferTokens(to, investedWei);
  }

  function setHardcap(uint newHardcap) public onlyOwner { 
    hardcap = newHardcap;
  }
 
  function setStart(uint newStart) public onlyOwner { 
    start = newStart;
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

  function setEnd(uint newEnd) public onlyOwner { 
    require(start < newEnd);
    end = newEnd;
  }

  function setToken(address newToken) public onlyOwner { 
    token = TaskFairToken(newToken);
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

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setMinInvestedLimit(uint newMinInvestedLimit) public onlyOwner {
    minInvestedLimit = newMinInvestedLimit;
  }
 
  function bonusesCount() public constant returns(uint) {
    return bonuses.length;
  }

  function addBonus(uint limit, uint bonus) public onlyOwner {
    bonuses.push(Bonus(limit, bonus));
  }

  function mintExtendedTokens() internal {
    uint extendedTokensPercent = bountyTokensPercent.add(devTokensPercent).add(advisorsTokensPercent).add(foundersTokensPercent).add(growthTokensPercent).add(securityTokensPercent);
    uint extendedTokens = minted.mul(extendedTokensPercent).div(PERCENT_RATE.sub(extendedTokensPercent));
    uint summaryTokens = extendedTokens + minted;

    uint bountyTokens = summaryTokens.mul(bountyTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(bountyTokensWallet, bountyTokens);

    uint advisorsTokens = summaryTokens.mul(advisorsTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(advisorsTokensWallet, advisorsTokens);

    uint foundersTokens = summaryTokens.mul(foundersTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(foundersTokensWallet, foundersTokens);

    uint growthTokens = summaryTokens.mul(growthTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(growthTokensWallet, growthTokens);

    uint devTokens = summaryTokens.mul(devTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(devTokensWallet, devTokens);

    uint secuirtyTokens = summaryTokens.mul(securityTokensPercent).div(PERCENT_RATE);
    mintAndSendTokens(securityTokensWallet, devTokens);
  }

  function mintAndSendTokens(address to, uint amount) internal {
    token.mint(to, amount);
    minted = minted.add(amount);
  }

  function calculateAndTransferTokens(address to, uint investorWei) internal {
    // update invested value
    invested = invested.add(investorWei);

    // calculate tokens
    uint tokens = investorWei.mul(price).div(1 ether);
    uint bonus = getBonus();
    if(bonus > 0) {
      tokens = tokens.add(tokens.mul(bonus).div(100));      
    }
    
    // transfer tokens
    mintAndSendTokens(to, tokens);
  }

  function getBonus() public constant returns(uint) {
    uint prevTimeLimit = start;
    for (uint i = 0; i < bonuses.length; i++) {
      Bonus storage bonus = bonuses[i];
      prevTimeLimit += bonus.periodInDays * 1 days;
      if (now < prevTimeLimit)
        return bonus.bonus;
    }
    return 0;
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

contract Presale is CommonCrowdsale {
  
  uint public softcap;
  
  bool public refundOn;

  bool public softcapAchieved;

  address public nextSaleAgent;

  mapping (address => uint) public balances;

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
  } 

  function createTokens() public payable saleIsOn {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    calculateAndTransferTokens(msg.sender, msg.value);
    if(!softcapAchieved && invested >= softcap) {
      softcapAchieved = true;      
    }
  } 

  function widthraw() public {
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
    } else {
      widthraw();
      mintExtendedTokens();
      token.setSaleAgent(nextSaleAgent);
    }    
  }

}

contract ICO is CommonCrowdsale {
  
  function finishMinting() public onlyOwner {
    mintExtendedTokens();
    token.finishMinting();
  }

  function createTokens() public payable saleIsOn {
    calculateAndTransferTokens(msg.sender, msg.value);
    uint devWei = msg.value.mul(devPercent).div(PERCENT_RATE);
    devWallet.transfer(devWei);
    wallet.transfer(msg.value.sub(devWei));
  } 

}

contract Deployer is Ownable {

  Presale public presale;  
 
  ICO public ico;

  TaskFairToken public token;

  function deploy() public onlyOwner {
    token = new TaskFairToken();
    
    presale = new Presale();
    presale.setToken(token);
    token.setSaleAgent(presale);
    presale.setMinInvestedLimit(1000000000000000000);  
    presale.setPrice(325000000000000000000);
    presale.setBountyTokensPercent(50);
    presale.setAdvisorsTokensPercent(20);
    presale.setDevTokensPercent(30);
    presale.setFoundersTokensPercent(50);
    presale.setGrowthTokensPercent(300);
    presale.setSecurityTokensPercent(5);
    presale.setDevPercent(20);
    presale.setSecurityPercent(10);
    
    // fix in prod
    presale.setSoftcap(40000000000000000000);
    presale.setHardcap(10000000000000000000000);
    presale.addBonus(7,40);
    presale.addBonus(7,30);
    presale.setStart(1512133200);
    presale.setEnd(1513342800);    
    presale.setWallet(0xb8600b335332724df5108fc0595002409c2adbc6);
    presale.setBountyTokensWallet(0x66ff3b89e15acb0b5e69179a2e54c494b89bdb1b);
    presale.setDevTokensWallet(0x54a67f1507deb1bfc58ba3ffa94b59fc50eb74bc);
    presale.setAdvisorsTokensWallet(0xd1bc33b2c89c93e65b0d476b8b50bfee82594847);
    presale.setFoundersTokensWallet(0xe619bcd3c4609ae269b5ebe5bf0cb7d1dc70c210);
    presale.setGrowthTokensWallet(0x39ecc9e56979c884b28d8c791890e279ab1ec5f4);
    presale.setDevWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    presale.setDirectMintAgent(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    presale.setSecurityTokensWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    presale.setSecurityWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);

    ico = new ICO();
    ico.setToken(token); 
    presale.setNextSaleAgent(ico);
    ico.setMinInvestedLimit(100000000000000000);
    ico.setPrice(325000000000000000000);
    presale.setBountyTokensPercent(50);
    presale.setAdvisorsTokensPercent(20);
    presale.setDevTokensPercent(30);
    presale.setFoundersTokensPercent(50);
    presale.setGrowthTokensPercent(300);
    presale.setSecurityTokensPercent(5);
    presale.setDevPercent(20);
    presale.setSecurityPercent(10);

    // fix in prod
    ico.setHardcap(20769000000000000000000);
    ico.addBonus(7,15);
    ico.addBonus(7,10);
    ico.setStart(1513342800);
    ico.setEnd(1514638800);
    ico.setWallet(0x67d78de2f2819dcbd47426a1ac6a23b9e9c9d300);
    ico.setBountyTokensWallet(0x772215ccf488031991f7dcc65e80a7c1fd497e75);
    ico.setDevTokensWallet(0x87f2f8a94986d9049147590e12a64ffaa9f946a8);
    ico.setAdvisorsTokensWallet(0x6bb6dbc29f8adb3a7627ea65372fe471509b7698);
    ico.setFoundersTokensWallet(0x39ecc9e56979c884b28d8c791890e279ab1ec5f4);
    ico.setGrowthTokensWallet(0x39ecc9e56979c884b28d8c791890e279ab1ec5f4);
    ico.setDevWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    ico.setDirectMintAgent(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    ico.setSecurityTokensWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    ico.setSecurityWallet(0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f);
    
    presale.transferOwnership(owner);
    ico.transferOwnership(owner);
    token.transferOwnership(owner);
  }

}

