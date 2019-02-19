import EVMRevert from './helpers/EVMRevert';
import { Period, Block, Tx, Input, Output, Outpoint } from 'leap-core';
import ethUtil from 'ethereumjs-util';
import chai from 'chai';
const PlasmaBridge = artifacts.require('./PlasmaBridge.sol');
const PatriciaTree = artifacts.require('./PatriciaTree.sol');
const SpendingCondition = artifacts.require('./SpendingCondition.sol');

const should = chai
  .use(require('chai-as-promised'))
  .should();

contract('PlasmaBridge', (accounts) => {
  const alice = accounts[0];
  const alicePriv = '0x278a5de700e29faae8e40e366ec5012b5ec63d36ec77e8a2417154cc1d25383f';
  const someHash = alicePriv;

  it('should allow to register condition for exit', async () => {
    let bridge = await PlasmaBridge.new();
    let condition = await SpendingCondition.new();
    const codeBuf = Buffer.from(condition.constructor._json.deployedBytecode.replace('0x', ''), 'hex')
    const codeHash = ethUtil.ripemd160(codeBuf);
    let transfer = Tx.transfer(
      [new Input(new Outpoint(someHash, 0))],
      [new Output(50, `0x${codeHash.toString('hex')}`)]
    );
    transfer = transfer.sign([alicePriv]);
    let block = new Block(32).addTx(transfer);
    let period = new Period(someHash, [block]);
    const proof = period.proof(transfer);
    
    const hash = Buffer.alloc(32);
    codeHash.copy(hash);
    const sig = ethUtil.ecsign(
      hash,
      Buffer.from(alicePriv.replace('0x', ''), 'hex'),
    );
    // withdraw output
    const event = await condition.exitProxy(`0x${sig.r.toString('hex')}`, `0x${sig.s.toString('hex')}`, sig.v, bridge.address, proof, 0);
    assert.equal(event.receipt.rawLogs[0].data, transfer.hash());
  });
});