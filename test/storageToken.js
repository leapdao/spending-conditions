const StorageToken = artifacts.require('./StorageToken.sol');
const PatriciaTree = artifacts.require('./PatriciaTree.sol');
import EVMRevert from './helpers/EVMRevert';
import chai from 'chai';

const should = chai
  .use(require('chai-as-promised'))
  .should();

contract('StorageToken', (accounts) => {
  const name = 'Non-Fungible Storage Token';
  const symbol = 'NFT';
  const firstTokenId = 100;
  const creator = accounts[0];
  const anyone = accounts[9];
  let storageToken;
  let pt;

  beforeEach(async () => {
    pt = await PatriciaTree.new();
    storageToken = await StorageToken.new(name, symbol, pt.address, { from: creator });
    await storageToken.mint(creator, firstTokenId, { from: creator });
  });

  it('key-value store with one element', async () => {
    // init partricia tree with 1 pair
    const key = web3.utils.toHex('testkey');
    const value = web3.utils.toHex('testvalue');
    let rootHash;
    let proof;
    await pt.insert(key, value);
    rootHash = await pt.getRootHash();
    proof = await pt.getProof(key);

    // store the root
    await storageToken.write(firstTokenId, rootHash, { from: creator });
    // verify a key/value pair
    const rsp = await storageToken.verify(
      firstTokenId,                 // tokenId
      key,  // key
      value,  // value
      proof[0],                     // branchMask
      proof[1],                     // siblings
    );
    assert.equal(rsp, true);
  });

  it('key-value store with invalid element', async () => {
    // init partricia tree with 1 pair
    const key = web3.utils.toHex('testkey');
    const value = web3.utils.toHex('testvalue');
    let rootHash;
    let proof;
    await pt.insert(key, value);
    rootHash = await pt.getRootHash();
    proof = await pt.getProof(key);

    // initialize contract
    await storageToken.write(firstTokenId, rootHash, { from: creator });
    const rsp = await storageToken.verify(
      firstTokenId,                 // tokenId
      key,  // key
      web3.utils.toHex('testvalue2'),  // value
      proof[0],                     // branchMask
      proof[1],                     // siblings
    ).should.be.rejectedWith(EVMRevert);
  });

  it('key-value store with multiple elements', async () => {
    // init partricia tree with multiple pairs
    await pt.insert(web3.utils.toHex('testkey'), web3.utils.toHex('testvalue'));
    await pt.insert(web3.utils.toHex('testkey2'), web3.utils.toHex('testvalue2'));
    await pt.insert(web3.utils.toHex('testkey3'), web3.utils.toHex('testvalue3'));
    await pt.insert(web3.utils.toHex('testkey4'), web3.utils.toHex('testvalue4'));
    await pt.insert(web3.utils.toHex('testkey5'), web3.utils.toHex('testvalue5'));
    const rootHash = await pt.getRootHash();
    const proof = await pt.getProof(web3.utils.toHex('testkey4'));
    // store the root
    await storageToken.write(firstTokenId, rootHash, { from: creator });
    // verify a key/value pair
    const rsp = await storageToken.verify(
      firstTokenId,                   // tokenId
      web3.utils.toHex('testkey4'),   // key
      web3.utils.toHex('testvalue4'), // value
      proof[0],                       // branchMask
      proof[1],                       // siblings
    );
    assert.equal(rsp, true);
  });

});