/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../PlasmaInterface.sol";
import "../Reflectable.sol";

contract SpendingCondition is Reflectable {
    address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;

    function fulfil(
    bytes32 _nonce,
    uint _gasPrice,
    uint _gasLimit,
    address _to,
    bytes _data,
    bytes32 _r,
    bytes32 _s,
    uint8 _v) public {
        
        // check signature
        require(_nonce == this); // this is injected as here: https://github.com/leapdao/leap-node/blob/388aa6c698719e53bf7dee715fe4368c069b6db1/src/tx/applyTx/checkSpendCond.js#L165
        bytes32 hash = keccak256(_nonce, _gasPrice, _gasLimit, _to, _data);
        address signer = ecrecover(hash, _v, _r, _s);
        require(signer == spenderAddr);

        // todo: check gasPrice and gasLimit
        
        // do transfer
        _tokenAddr.call(_data);
    }

    function exitProxy(
        bytes32 _r, bytes32 _s, uint8 _v,   // authorization to start exit
        address _bridgeAddr,                // address of Plasma bridge
        bytes32[] memory _proof, uint _oindex      // tx-data, proof and output index
    ) public {
        address signer = ecrecover(ripemd160(bytecode(address(this))), _v, _r, _s);
        require(signer == spenderAddr);
        PlasmaInterface bridge = PlasmaInterface(_bridgeAddr);
        bridge.startExit(_proof, _oindex);
    }

}