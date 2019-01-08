
/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

import EVMRevert from './helpers/EVMRevert';
import chai from 'chai';
import ethUtil from 'ethereumjs-util';
const CounterCondition = artifacts.require('./CounterCondition.sol');
const SimpleToken = artifacts.require('SimpleToken');
const StorageToken = artifacts.require('./StorageToken.sol');
const PatriciaTree = artifacts.require('./PatriciaTree.sol');

const should = chai
  .use(require('chai-as-promised'))
  .should();


contract('CounterCondition', (accounts) => {
  const alice = accounts[0];
  const alicePriv = '0x278a5de700e29faae8e40e366ec5012b5ec63d36ec77e8a2417154cc1d25383f';
  const name = 'Non-Fungible Storage Token';
  const symbol = 'NFT';
  const firstTokenId = 1234;
  let token;
  let condition;
  let storage;
  let pt;

  before(async () => {
    token = await SimpleToken.new();
    condition = await CounterCondition.new();
    // initialize contract
    token.transfer(condition.address, 1000);

    pt = await PatriciaTree.new();
    storage = await StorageToken.new(pt.address);
    await storage.mint(condition.address, firstTokenId);
  });

  it('should allow to fulfil condition', async () => {
    await condition.fulfil('0x00', '0x00', 0, [token.address, storage.address], condition.address, 995).should.be.fulfilled;
    let count = await storage.read(firstTokenId);
    assert.equal(Buffer.from(count.replace('0x', ''), 'hex').readIntBE(0, 32), 1);

    await condition.fulfil('0x00', '0x00', 0, [token.address, storage.address], condition.address, 995).should.be.fulfilled;
    count = await storage.read(firstTokenId);
    assert.equal(Buffer.from(count.replace('0x', ''), 'hex').readIntBE(0, 32), 2);

    await condition.fulfil('0x00', '0x00', 0, [token.address, storage.address], condition.address, 995).should.be.fulfilled;
    count = await storage.read(firstTokenId);
    assert.equal(Buffer.from(count.replace('0x', ''), 'hex').readIntBE(0, 32), 3);

    await condition.fulfil('0x00', '0x00', 0, [token.address, storage.address], condition.address, 995).should.be.fulfilled;
    count = await storage.read(firstTokenId);
    assert.equal(Buffer.from(count.replace('0x', ''), 'hex').readIntBE(0, 32), 4);

    await condition.fulfil('0x00', '0x00', 0, [token.address, storage.address], accounts[2], 995).should.be.fulfilled;
  });

});
