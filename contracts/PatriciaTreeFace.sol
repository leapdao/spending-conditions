/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;
pragma experimental "ABIEncoderV2";

import {Data} from "./Data.sol";


/*
 * Interface for patricia trees.
 *
 * More info at: https://github.com/chriseth/patricia-trie
 */
contract PatriciaTreeFace {
    function getRootHash() public view returns (bytes32);
    function getRootEdge() public view returns (Data.Edge memory e);
    function getNode(bytes32 hash) public view returns (Data.Node memory n);
    function getProof(bytes memory key) public view returns (uint branchMask, bytes32[] memory _siblings);
    function verifyProof(bytes32 rootHash, bytes memory key, bytes memory value, uint branchMask, bytes32[] memory siblings) public view returns (bool);
    function insert(bytes memory key, bytes memory value) public;
}