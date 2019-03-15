/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity ^0.5.2;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './PatriciaTree.sol';
import './StorageTokenInterface.sol';

contract StorageToken is ERC721, StorageTokenInterface {
  
  mapping(uint256 => bytes32) public data;

  function read(uint256 _tokenId) public view returns (bytes32) {
    return data[_tokenId];
  }

  function verify(
    uint256 _tokenId,     // the token holding the storage root
    bytes32 _key,           // key used to do lookup in storage trie
    bytes32 _value,         // value expected to be returned
    uint256 _branchMask,     // position of value in trie
    bytes32[] memory _siblings   // proof of inclusion
  ) public view returns (bool) {
    require(_exists(_tokenId));
    return tree.verifyProof(data[_tokenId], _key, _value, _branchMask, _siblings);
  }

  function write(uint256 _tokenId, bytes32 _newRoot) public {
    require(msg.sender == ownerOf(_tokenId));
    data[_tokenId] = _newRoot;
  }

  PatriciaTree tree;

  constructor(address _treeLibAddr) public {
    tree = PatriciaTree(_treeLibAddr);
  }

  function mint(address _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

}