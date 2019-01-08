/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity ^0.5.2;

contract PlasmaInterface {

  function tokens(uint16 _color) public view returns (address);

  function startExit(bytes32[] memory _proof, uint256 _oindex) public;

}
