#!/usr/bin/env node

const ethUtil = require('ethereumjs-util');
const ethers = require('ethers');
const { Tx, Outpoint, Input, Output } = require('leap-core');

const provider = new ethers.providers.JsonRpcProvider(process.env['RPC_URL'] || 'https://testnet-node1.leapdao.org');

const RECEIVER_PLACEHOLDER = '1111111111111111111111111111111111111111';
const TOKEN_PLACEHOLDER = '2222222222222222222222222222222222222222';

async function main() {
  let tokenAddr;
  let msgSender;
  let abi;
  let codeBuf;
  let codeHash;
  let spAddr;
  let msgData;
  let spendingCondition;

  try {
    spendingCondition = require('./../build/contracts/HashLockCondition.json');
  } catch (e) {
    console.error('Please run `npm run compile:contracts` first. 😉');
    return;
  }

  if (process.argv.length < 4) {
    console.log(
      'Usage: <token address> <message sender address>\n' +
      'Example:' +
      '\n\t0x91c0E6801f148B77C118494ff944290999f67656 0x9D4F8216808F7dFbB919cF5e579c1894a1E197C3' +
      '\nEnvironment Variables:' +
      '\n\tRPC_URL'
    );

    process.exit(0);
  }

  tokenAddr = process.argv[2];
  msgSender = process.argv[3];
  abi = new ethers.utils.Interface(spendingCondition.abi);
  codeBuf = spendingCondition.deployedBytecode
    .replace(RECEIVER_PLACEHOLDER, msgSender.replace('0x', '').toLowerCase())
    .replace(TOKEN_PLACEHOLDER, tokenAddr.replace('0x', '').toLowerCase());

  codeHash = ethUtil.ripemd160(codeBuf);
  spAddr = '0x' + codeHash.toString('hex');
  msgData = abi.functions.fulfill.encode(['Hello, Spending Condition']);

  console.log(`Please send some tokens to ` + spAddr);

  let txs;

  while (true) {
    const done = await new Promise(
      async (resolve, reject) => {
        // check every 3 seconds
        setTimeout(async () => {
          console.log(`Calling: plasma_unspent [${spAddr}]`);

          let res = await provider.send('plasma_unspent', [spAddr]);

          if (res.length) {
            if (!txs) {
              txs = res.map(t => t.outpoint);
              resolve(false);
              return;
            }

            [newTxHash] = res.filter(t => txs.indexOf(t.outpoint) < 0);
            if (newTxHash) {
              txHash = newTxHash.outpoint.substring(0, 66);
              console.log(`found new unspent UTXO(${txHash})`);
              resolve(true);
              return;
            }
          }
          resolve(false);
        }, 3000);
      }
    );

    if (done) {
      break;
    }
  }

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

function onException (e) {
  console.error(e);
  process.exit(1);
}

process.on('uncaughtException', onException);
process.on('unhandledRejection', onException);
main();
