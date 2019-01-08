/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import "./TxLib.sol";
import "./Reflectable.sol";
import "./PlasmaInterface.sol";


contract PlasmaBridge is PlasmaInterface, Reflectable {
  using TxLib for TxLib.Outpoint;
  using TxLib for TxLib.Output;

  event ExitQueueMock(bytes32 txHash);

  mapping(uint16 => address) tokenList;
  function tokens(uint16 _color) public view returns (address){
    return tokenList[_color];
  }
    
  function startExit(bytes32[] memory _proof, uint _oindex) public {
    bytes32 txHash;
    bytes memory txData;
    (, txHash, txData) = TxLib.validateProof(32, _proof);
    // parse tx and use data
    TxLib.Output memory out = TxLib.parseTx(txData).outs[_oindex];
    // check that caller is owner
    if (msg.sender != out.owner) {
        // or caller code hashes to owner
        require(bytes20(out.owner) == ripemd160(bytecode(msg.sender)));
    }
    emit ExitQueueMock(txHash);
  }
  
}