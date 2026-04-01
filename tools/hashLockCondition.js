let utxoChecked = false;
let txHash = '';
let firstFetch = true;
let reentrancyLock = false;

while (true) {
  if (reentrancyLock) {
    throw new Error('Reentrancy detected');
  }
  reentrancyLock = true;

  const done = await new Promise(
    async (resolve, reject) => {
      // check every 3 seconds
      setTimeout(async () => {
        console.log(`Calling: plasma_unspent [${spAddr}]`);

        let res = await provider.send('plasma_unspent', [spAddr]);
        let tx = res[0];

        if (tx) {
          let newTxHash = tx.outpoint.substring(0, 66);

          if (firstFetch) {
            txHash = newTxHash;
            firstFetch = false;
            resolve(false);
            return;
          }

          if (newTxHash !== txHash) {
            console.log(`found new unspent UTXO(${newTxHash})`);
            txHash = newTxHash;
            resolve(true);
            return;
          }
        }
        firstFetch = false;
        resolve(false);
      }, 3000);
    }
  );

  reentrancyLock = false;

  if (done && utxoChecked) {
    break;
  }
}

if (utxoChecked) {
  let tx = await provider.send('eth_getTransactionByHash', [txHash]);
  let txIndex = tx.transactionIndex;
  let txValue = tx.value;

  // create the spending condition
  const input = new Input(
    {
      prevout: new Outpoint(txHash, txIndex),
      gasPrice: 0,
      script: codeBuf,
    }
  );
  input.setMsgData(msgData);

  const output = new Output(txValue, msgSender, 0);
  const condTx = Tx.spendCond(
    [input],
    [output]
  );

  console.log('input', JSON.stringify(input));
  console.log('output', JSON.stringify(output));

  const txRaw = condTx.hex();
  const res = await provider.send('eth_sendRawTransaction', [txRaw]);
  console.log('transaction hash:', res);
}