pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import './PatriciaTree.sol';
import './StorageTokenInterface.sol';

contract StorageToken is ERC721Token, StorageTokenInterface {
  
  mapping(uint256 => bytes32) public data;

  function read(uint256 _tokenId) public view returns (bytes32) {
    return data[_tokenId];
  }

  function verify(
    uint256 _tokenId,     // the token holding the storage root
    bytes _key,           // key used to do lookup in storage trie
    bytes _value,         // value expected to be returned
    uint _branchMask,     // position of value in trie
    bytes32[] _siblings   // proof of inclusion
  ) public view returns (bool) {
    require(exists(_tokenId));
    return tree.verifyProof(data[_tokenId], _key, _value, _branchMask, _siblings);
  }

  function write(uint256 _tokenId, bytes32 _newRoot) public {
    require(msg.sender == ownerOf(_tokenId));
    data[_tokenId] = _newRoot;
  }

  PatriciaTree tree;

  constructor(string name, string symbol, address _treeLibAddr) public ERC721Token(name, symbol) {
    tree = PatriciaTree(_treeLibAddr);
  }

  function mint(address _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

  function setTokenURI(uint256 _tokenId, string _uri) public {
    super._setTokenURI(_tokenId, _uri);
  }
  
  function _removeTokenFrom(address _from, uint256 _tokenId) public {
    super.removeTokenFrom(_from, _tokenId);
  }

}