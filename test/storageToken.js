const StorageToken = artifacts.require('./StorageToken.sol');

contract('StorageToken', (accounts) => {
  const name = 'Non-Fungible Storage Token';
  const symbol = 'NFT';
  const firstTokenId = 100;
  const creator = accounts[0];
  const anyone = accounts[9];
  let storageToken;

  beforeEach(async () => {
    this.token = await StorageToken.new(name, symbol, { from: creator });
    await this.token.mint(creator, firstTokenId, { from: creator });
  });

  it('some test', async () => {
    // initialize contract
    await this.token.write(firstTokenId, web3.utils.toHex('key'), web3.utils.toHex('value'), { from: creator });
    const rsp = await this.token.read(firstTokenId, web3.utils.toHex('key'));
    assert.equal(web3.utils.hexToString(rsp), 'value');
  });

});