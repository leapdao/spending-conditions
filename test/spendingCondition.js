
/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

const chai = require('chai');
const ethUtil = require('ethereumjs-util');
const SpendingCondition = artifacts.require('./SpendingCondition.sol');
const SimpleToken = artifacts.require('./mocks/SimpleToken');

const should = chai
  .use(require('chai-as-promised'))
  .should();


contract('SpendingCondition', (accounts) => {
  const alice = accounts[0];
  // address = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74
  const alicePriv = '0x278a5de700e29faae8e40e366ec5012b5ec63d36ec77e8a2417154cc1d25383f';
  let token;
  let condition;

  before(async () => {
    token = await SimpleToken.new();

    // replace token address placeholder to real token address
    let tmp = SpendingCondition._json.bytecode;
    tmp = tmp.replace('1111111111111111111111111111111111111111', token.address.replace('0x', ''));
    SpendingCondition._json.bytecode = tmp;

    tmp = SpendingCondition._json.deployedBytecode;
    tmp = tmp.replace('1111111111111111111111111111111111111111', token.address.replace('0x', ''));
    SpendingCondition._json.deployedBytecode = tmp;

    condition = await SpendingCondition.new();
    // initialize contract
    await token.transfer(condition.address, 1000);
  });

  it('should allow to fulfil condition', async () => {
    const codeBuf = Buffer.from(condition.constructor._json.deployedBytecode.replace('0x', ''), 'hex')
    const codeHash = ethUtil.ripemd160(codeBuf);
    const hash = Buffer.alloc(32);
    Buffer.from(condition.address.replace('0x', ''), 'hex').copy(hash);
    const sig = ethUtil.ecsign(
      hash,
      Buffer.from(alicePriv.replace('0x', ''), 'hex'),
    );
    const data1 = await condition.contract.methods.fulfil(`0x${sig.r.toString('hex')}`, `0x${sig.s.toString('hex')}`, sig.v, accounts[1], 995).encodeABI();
    const tx = await condition.fulfil(`0x${sig.r.toString('hex')}`, `0x${sig.s.toString('hex')}`, sig.v, accounts[1], 995).should.be.fulfilled;
    // check transaction for events
    assert.equal(tx.receipt.rawLogs[0].address, token.address);
    // bytes32 anyone? :P
    assert.equal(tx.receipt.rawLogs[0].topics[1], '0x000000000000000000000000' + condition.address.replace('0x', '').toLowerCase());
    assert.equal(tx.receipt.rawLogs[0].topics[2], '0x000000000000000000000000' + accounts[1].replace('0x', '').toLowerCase());
    const remain = await token.balanceOf(condition.address);
    assert.equal(remain.toNumber(), 5);
  });

});
