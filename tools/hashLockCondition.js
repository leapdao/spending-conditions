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

  let txHash = '';
  let firstFetch = true;

  while (true) {
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

    if (done) {
      break;
    }
  }

  let tx = await provider.send('eth_getTransactionByHash', [txHash]);
  let txIndex = tx.transactionIndex;
  let txValue = tx.value;

  // Get current gas price from the network
  let gasPrice;
  try {
    const feeData = await provider.getFeeData();
    gasPrice = feeData.gasPrice || feeData.maxFeePerGas || 0;
    console.log(`Using gas price: ${gasPrice.toString()}`);
  } catch (e) {
    console.warn('Failed to get fee data, using default gas price of 0');
    gasPrice = 0;
  }

  // Estimate gas limit for the transaction
  const GAS_LIMIT = 100000; // Conservative estimate for spending condition execution

  // Calculate total gas cost
  const gasCost = gasPrice * GAS_LIMIT;
  console.log(`Estimated gas cost: ${gasCost.toString()}`);

  // Adjust output value to account for gas cost
  const outputValue = txValue - gasCost > 0 ? txValue - gasCost : 0;
  if (outputValue === 0) {
    console.warn('Warning: Output value is 0 after gas deduction');
  }

  // create the spending condition
  const input = new Input(
    {
      prevout: new Outpoint(txHash, txIndex),
      gasPrice: gasPrice,
      script: codeBuf,
    }
  );
  input.setMsgData(msgData);

  const output = new Output(outputValue, msgSender, 0);
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
