/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity ^0.5.2;

contract StorageTokenInterface {
  
  function read(uint256 _tokenId) public view returns (bytes32) ;

  function verify(
    uint256 _tokenId,     // the token holding the storage root
    bytes32 _key,           // key used to do lookup in storage trie
    bytes32 _value,         // value expected to be returned
    uint _branchMask,     // position of value in trie
    bytes32[] memory _siblings   // proof of inclusion
  ) public view returns (bool) ;

  function write(uint256 _tokenId, bytes32 _newRoot) public;

}