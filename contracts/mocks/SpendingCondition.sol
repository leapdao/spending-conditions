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
    uint constant value = 0;
    uint constant mainNetNonce = 12345;
    address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;

    function fulfil(
    bytes32 _nonce,   // 
    uint _gasPrice,
    uint _gasLimit,
    address _to,
    bytes _data,
    bytes32 _r,
    bytes32 _s,
    uint8 _v) public {
        // check signature
        // if we are on plasma, 'this' is injected sigHash as here: https://github.com/leapdao/leap-node/blob/388aa6c698719e53bf7dee715fe4368c069b6db1/src/tx/applyTx/checkSpendCond.js#L165
        // if on main-net, the address off the deployed contract needs to be signed.
        // if on main-net, no replay protection after first signature. so spending condition should be emptied with first tx
        if (_nonce != this) {
          require(_nonce == mainNetNonce);
        }
        bytes32 hash = keccak256(_nonce, _gasPrice, _gasLimit, value, _to, _data);
        address signer = ecrecover(hash, _v, _r, _s);
        require(signer == spenderAddr);

        // todo: check gasPrice and gasLimit
        uint transferAmount = uint(_data); // pseudocode
        uint balance = _tokenAddr.balanceOf(this);
        require(balance - (_gasPrice * _gasLimit) == transferAmount);
        
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