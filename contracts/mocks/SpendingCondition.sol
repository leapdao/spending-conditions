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
  uint256 constant nonce = 1234;    // nonce, so that signatures can not be replayed
  address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;

  function fulfil(bytes32 _r, bytes32 _s, uint8 _v,      // signature
    address _tokenAddr,                               // inputs
    address _receiver, uint256 _amount) public {  // outputs
    // check signature
    address contractAddr = address(this);
    address signer = ecrecover(bytes32(bytes20(contractAddr)), _v, _r, _s);
    require(signer == spenderAddr);
    // do transfer
    IERC20 token = IERC20(_tokenAddr);
    uint256 diff = token.balanceOf(contractAddr) - _amount;
    token.transfer(_receiver, _amount);
    if (diff > 0) {
      token.transfer(contractAddr, diff);
    }
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