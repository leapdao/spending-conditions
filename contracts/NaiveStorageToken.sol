/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract NaiveStorageToken is ERC721 {
  
  mapping(uint256 => mapping(bytes32 => bytes32)) data;

  function mint(address _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

  function read(uint256 _tokenId, bytes32 _key) public view returns (bytes32) {
    require(_exists(_tokenId));
    return data[_tokenId][_key];
  }

  function write(uint256 _tokenId, bytes32 _key, bytes32 _value) public {
    require(msg.sender == ownerOf(_tokenId));
    data[_tokenId][_key] = _value;
  }

}