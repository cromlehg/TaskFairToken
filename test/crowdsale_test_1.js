
import ether from './helpers/ether'
import {advanceBlock} from './helpers/advanceToBlock'
import {increaseTimeTo, duration} from './helpers/increaseTime'
import latestTime from './helpers/latestTime'
import EVMThrow from './helpers/EVMThrow'

const BigNumber = web3.BigNumber

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const Token = artifacts.require('TaskFairToken')

const Mainsale = artifacts.require('ICO')

const Presale = artifacts.require('Presale')

contract('Crowdsale', function(wallets) {

  before(async function() {
    await advanceBlock()
  })
  
  beforeEach(async function () {
    this.token = await Token.new()
    this.presale = await Presale.new()
    this.mainsale = await Mainsale.new()
    await this.token.setSaleAgent(this.presale.address)
    await this.presale.setToken(this.token.address)
    await this.mainsale.setToken(this.token.address)
    await this.presale.setNextSaleAgent(this.mainsale.address)
  })	 
  
  it('Integration test', async function () {

    const owner = wallets[0]

    const defInvestor = wallets[1]
 
    const extInvestorPresale = wallets[2]

    const defInvestor1 = wallets[3]

    const extInvestorPresale1 = wallets[4]

    const defInvestor2 = wallets[5]

    const extInvestorPresale2 = wallets[6]

    const defInvestor3 = wallets[7]

    const extInvestorPresale3 = wallets[8]

    const defValue = ether(3)

    const jumpValue = ether(5)

    const jumpValue1 = ether(5000)

    var masterWallet = "0xb8600b335332724df5108fc0595002409c2adbc6"

    var secWallet = "0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f"

    var devWallet = "0xc56b0d5bbc2bf9b760ebd797dacd3a683cb8498f"

    const masterWalletK = new BigNumber(0.97)

    const secWalletK = new BigNumber(0.01)

    const devWalletK = new BigNumber(0.02)

    console.log('Rejects before start presale')
    await this.presale.sendTransaction({from: defInvestor, value: defValue}).should.be.rejectedWith(EVMThrow)
    await this.presale.directMint(defInvestor, defValue, {from: owner}).should.be.rejectedWith(EVMThrow)

    console.log('Increase time to presale')
    const presaleStart = 1512133200
    await increaseTimeTo(presaleStart)

    console.log('Invest 3 ether')
    await this.presale.sendTransaction({from: defInvestor, value: defValue}).should.be.fulfilled

    console.log('Check presale investor balance')
    const presalePrice1 = new BigNumber(325 + 325*0.4)
    var minted = defValue.mul(presalePrice1)
    var balanceOf = await this.token.balanceOf(defInvestor)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary presale minted')
    var summaryMinted = minted
    var totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted) 

    console.log('Check contract balance')
    var contractBalance = defValue
    var curContractBalance = await web3.eth.getBalance(this.presale.address)
    curContractBalance.should.be.bignumber.equal(contractBalance)

    console.log('Check softcap not achieved')
    var achieved = await this.presale.softcapAchieved()
    achieved.should.equal(false)

    console.log('Reject widthraw')
    await this.presale.widthraw().should.be.rejectedWith(EVMThrow)

    console.log('Direct mint to take softcap')
    const toTakeSoftcap = ether(40)
    await this.presale.directMint(extInvestorPresale, toTakeSoftcap, {from: owner}).should.be.fulfilled

    console.log('Check external investor balance')
    var minted = toTakeSoftcap.mul(presalePrice1)
    var balanceOf = await this.token.balanceOf(extInvestorPresale)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary presale minted')
    var summaryMinted = summaryMinted.add(minted)
    var totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted) 

    console.log('Check softcap achieved')
    var achieved = await this.presale.softcapAchieved()
    achieved.should.equal(true)

    console.log('Check contract balance')
    var curContractBalance = await web3.eth.getBalance(this.presale.address)
    curContractBalance.should.be.bignumber.equal(contractBalance)

    console.log('Check widthraw works')
    await this.presale.widthraw().should.be.fulfilled

    console.log('Check master wallet')
    var curMasterBalance = await web3.eth.getBalance(masterWallet)
    var localMasterBalance = contractBalance.mul(masterWalletK)
    curMasterBalance.should.be.bignumber.equal(curMasterBalance)

    console.log('Check sec wallet')
    var curSecBalance = await web3.eth.getBalance(secWallet)
    var localSecBalance = contractBalance.mul(secWalletK)
    curSecBalance.should.be.bignumber.equal(curSecBalance)

    console.log('Check sec wallet')
    var curSecBalance = await web3.eth.getBalance(secWallet)
    var localSecBalance = contractBalance.mul(secWalletK)
    curSecBalance.should.be.bignumber.equal(curSecBalance)

    contractBalance = ether(0)
    console.log('Check contract balance')
    var curContractBalance = await web3.eth.getBalance(this.presale.address)
    curContractBalance.should.be.bignumber.equal(contractBalance)
// TODO:
    console.log('Increase time to next bonus')
    const presaleStart = 1512133200
    await increaseTimeTo(presaleStart)


/*
    console.log('Presale direct mint')
    await this.presale.directMint(extInvestorPresale, defValue, {from: owner}).should.be.fulfilled

    console.log('Check external investor balance')
    minted = defValue.mul(presalePrice)
    balanceOf = await this.token.balanceOf(extInvestorPresale)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary presale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted) 

    console.log('Check rejection of transfer operation during presale')
    const transferredK = new BigNumber(0.5)
    var transferredValue = minted.mul(transferredK)
    await this.token.transfer(defInvestor, transferredValue, {from: extInvestorPresale}).should.be.rejectedWith(EVMThrow)

    console.log('Increase time to end of presale')
    const day = 60 * 60 * 24
    const presaleEnd = presaleStart + 30*day
    await increaseTimeTo(presaleEnd)
   
    console.log('Check invest rejection during time between presale and ICO')
    await this.presale.sendTransaction({from: defInvestor, value: defValue}).should.be.rejectedWith(EVMThrow)

    console.log('Check external invest rejection during time between presale and ICO')
    await this.presale.directMint(extInvestorPresale, defValue, {from: owner}).should.be.rejectedWith(EVMThrow)

    console.log('Check transfer rejection during time between presale and ICO')
    await this.token.transfer(defInvestor, transferredValue, {from: extInvestorPresale}).should.be.rejectedWith(EVMThrow)

    console.log("Finishing presale")
    await this.presale.finishMinting().should.be.fulfilled

    console.log('Check invest rejection during time between presale and ICO')
    await this.presale.sendTransaction({from: defInvestor, value: defValue}).should.be.rejectedWith(EVMThrow)

    console.log('Check external invest rejection during time between presale and ICO')
    await this.presale.directMint(extInvestorPresale, defValue, {from: owner}).should.be.rejectedWith(EVMThrow)

    console.log('Check transfer rejection during time between presale and ICO')
    await this.token.transfer(defInvestor, transferredValue, {from: extInvestorPresale}).should.be.rejectedWith(EVMThrow)

    console.log('Increase time to start of ICO')
    const mainsaleStart = 1525352400
    await increaseTimeTo(mainsaleStart)

    console.log('Invest 3 ether')
    await this.mainsale.sendTransaction({from: defInvestor1, value: defValue}).should.be.fulfilled
    
    console.log('Check mainsale investor balance')
    const mainsale1Price = new BigNumber(200)
    minted = defValue.mul(mainsale1Price)
    balanceOf = await this.token.balanceOf(defInvestor1)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)
    
    console.log('Check master wallet')
    curMasterBalance = await web3.eth.getBalance(masterWallet)
    localMasterBalance = localMasterBalance.add(defValue.mul(masterWalletK))
    curMasterBalance.should.be.bignumber.equal(curMasterBalance)

    console.log('Check slave wallet')
    curSlaveBalance = await web3.eth.getBalance(slaveWallet)
    localSlaveBalance = localSlaveBalance.add(defValue.mul(slaveWalletK))
    curSlaveBalance.should.be.bignumber.equal(curSlaveBalance)

    console.log('Presale direct mint')
    await this.mainsale.directMint(extInvestorPresale1, defValue, {from: owner}).should.be.fulfilled

    console.log('Check external investor balance')
    minted = defValue.mul(mainsale1Price)
    balanceOf = await this.token.balanceOf(extInvestorPresale1)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)

    console.log('Check rejection of transfer operation during mainsale 1')
    transferredValue = minted.mul(transferredK)
    await this.token.transfer(defInvestor1, transferredValue, {from: extInvestorPresale1}).should.be.rejectedWith(EVMThrow)

    console.log('Invest 5 ether')
    await this.mainsale.sendTransaction({from: defInvestor2, value: jumpValue}).should.be.fulfilled
    
    console.log('Check mainsale investor balance')
    minted = jumpValue.mul(mainsale1Price)
    balanceOf = await this.token.balanceOf(defInvestor2)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)
    
    console.log('Check master wallet')
    curMasterBalance = await web3.eth.getBalance(masterWallet)
    localMasterBalance = localMasterBalance.add(jumpValue.mul(masterWalletK))
    curMasterBalance.should.be.bignumber.equal(curMasterBalance)

    console.log('Check slave wallet')
    curSlaveBalance = await web3.eth.getBalance(slaveWallet)
    localSlaveBalance = localSlaveBalance.add(jumpValue.mul(slaveWalletK))
    curSlaveBalance.should.be.bignumber.equal(curSlaveBalance)

    console.log('Presale direct mint')
    await this.mainsale.directMint(extInvestorPresale2, jumpValue1, {from: owner}).should.be.fulfilled

    console.log('Check external investor balance')
    minted = jumpValue1.mul(mainsale1Price)
    balanceOf = await this.token.balanceOf(extInvestorPresale2)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)

    console.log('Check rejection of transfer operation during mainsale 1')
    transferredValue = minted.mul(transferredK)
    await this.token.transfer(defInvestor2, transferredValue, {from: extInvestorPresale2}).should.be.rejectedWith(EVMThrow)

    console.log('Invest 3 ether secnd stage')
    await this.mainsale.sendTransaction({from: defInvestor3, value: defValue}).should.be.fulfilled
    
    console.log('Check mainsale investor balance')
    const mainsale2Price = new BigNumber(180)
    minted = defValue.mul(mainsale2Price)
    balanceOf = await this.token.balanceOf(defInvestor3)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)
    
    console.log('Check master wallet')
    curMasterBalance = await web3.eth.getBalance(masterWallet)
    localMasterBalance = localMasterBalance.add(defValue.mul(masterWalletK))
    curMasterBalance.should.be.bignumber.equal(curMasterBalance)

    console.log('Check slave wallet')
    curSlaveBalance = await web3.eth.getBalance(slaveWallet)
    localSlaveBalance = localSlaveBalance.add(defValue.mul(slaveWalletK))
    curSlaveBalance.should.be.bignumber.equal(curSlaveBalance)

    console.log('Presale direct mint')
    await this.mainsale.directMint(extInvestorPresale3, defValue, {from: owner}).should.be.fulfilled

    console.log('Check external investor balance')
    minted = defValue.mul(mainsale2Price)
    balanceOf = await this.token.balanceOf(extInvestorPresale3)
    balanceOf.should.be.bignumber.equal(minted)

    console.log('Check summary mainsale minted')
    summaryMinted = summaryMinted.add(minted)
    totalSupply = await this.token.totalSupply()
    totalSupply.should.be.bignumber.equal(summaryMinted)

    console.log('Check rejection of transfer operation during mainsale 3')
    transferredValue = minted.mul(transferredK)
    await this.token.transfer(defInvestor3, transferredValue, {from: extInvestorPresale3}).should.be.rejectedWith(EVMThrow)

    console.log("Finishing mainsale")
    await this.mainsale.finishMinting().should.be.fulfilled

    console.log('Check invest rejection after ICO')
    await this.presale.sendTransaction({from: defInvestor, value: defValue}).should.be.rejectedWith(EVMThrow)

    console.log('Check external invest rejection after ICO')
    await this.presale.directMint(extInvestorPresale, defValue, {from: owner}).should.be.rejectedWith(EVMThrow)

    console.log('Check transfer rejection during after ICO')
    await this.token.transfer(defInvestor, transferredValue, {from: extInvestorPresale}).should.be.fulfilled*/

  })

})
