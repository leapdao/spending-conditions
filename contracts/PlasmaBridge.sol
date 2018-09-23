pragma solidity ^0.4.24;
import "./TxLib.sol";
import "./Reflectable.sol";
import "./PlasmaInterface.sol";


contract PlasmaBridge is PlasmaInterface {
  using TxLib for TxLib.Outpoint;
  using TxLib for TxLib.Output;
  using Reflectable for address;

  event ExitQueueMock(bytes32 txHash);
    
  function startExit(bytes32[] _proof, uint _oindex) {
    bytes32 txHash;
    bytes memory txData;
    (, txHash, txData) = TxLib.validateProof(32, _proof);
    // parse tx and use data
    TxLib.Output memory out = TxLib.parseTx(txData).outs[_oindex];
    // check that caller is owner
    if (msg.sender != out.owner) {
        // or caller code hashes to owner
        require(bytes20(out.owner) == ripemd160(msg.sender.bytecode()));
    }
    emit ExitQueueMock(txHash);
  }
  
}