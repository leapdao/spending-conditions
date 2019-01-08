const StorageToken = artifacts.require('./NaiveStorageToken.sol');

contract('NaiveStorageToken', (accounts) => {
  const name = 'Non-Fungible Storage Token';
  const symbol = 'NFT';
  const firstTokenId = 100;
  const creator = accounts[0];
  const anyone = accounts[9];
  let storageToken;

  beforeEach(async () => {
    storageToken = await StorageToken.new({ from: creator });
    await storageToken.mint(creator, firstTokenId, { from: creator });
  });

  it('naive key-value store', async () => {
    // initialize contract
    await storageToken.write(firstTokenId, web3.utils.toHex('key'), web3.utils.toHex('value'), { from: creator });
    const rsp = await storageToken.read(firstTokenId, web3.utils.toHex('key'));
    assert.equal(web3.utils.hexToString(rsp), 'value');
  });

});