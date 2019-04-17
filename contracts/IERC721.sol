
/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

contract IERC721 {

  function ownerOf(uint256 tokenId) public view returns (address owner);

  function transferFrom(address from, address to, uint256 tokenId) public;

}