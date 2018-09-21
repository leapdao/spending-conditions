pragma solidity ^0.4.24;

contract StorageTokenInterface {
  
  function read(uint256 _tokenId) public view returns (bytes32) ;

  function verify(
    uint256 _tokenId,     // the token holding the storage root
    bytes _key,           // key used to do lookup in storage trie
    bytes _value,         // value expected to be returned
    uint _branchMask,     // position of value in trie
    bytes32[] _siblings   // proof of inclusion
  ) public view returns (bool) ;

  function write(uint256 _tokenId, bytes32 _newRoot) public;

}