
/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

const chai = require('chai');
const ethUtil = require('ethereumjs-util');
const MultisigCondition = artifacts.require('./MultisigCondition.sol');
const SimpleToken = artifacts.require('SimpleToken');
const StorageToken = artifacts.require('./StorageToken.sol');
const PatriciaTree = artifacts.require('./PatriciaTree.sol');

const should = chai
  .use(require('chai-as-promised'))
  .should();


contract('MultisigCondition', (accounts) => {
  const name = 'Non-Fungible Storage Token';
  const symbol = 'NFT';
  let token;
  let condition;
  let storage;
  let pt;

  before(async () => {
    token = await SimpleToken.new();
    condition = await MultisigCondition.new();
    // initialize contract
    token.transfer(condition.address, 1000);

    pt = await PatriciaTree.new();
    storage = await StorageToken.new(pt.address);
    await storage.mint(accounts[0], 123);
    await storage.mint(accounts[1], 456);
    await storage.mint(accounts[2], 789);
  });

  it('should allow to fulfil condition', async () => {
    await condition.fulfil([token.address, storage.address], accounts[0], 995).should.be.rejectedWith('revert');
    await storage.write(123, `0x000000000000000000000000${accounts[0].replace('0x', '')}`, {from: accounts[0]});
    await storage.write(456, `0x000000000000000000000000${accounts[0].replace('0x', '')}`, {from: accounts[1]});
    await condition.fulfil([token.address, storage.address], accounts[0], 995).should.be.fulfilled;
  });

});
