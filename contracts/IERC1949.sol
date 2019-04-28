
/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import "./IERC1948.sol";

contract IERC1949 is IERC1948 {

  function breed(uint256 _queenId, address _to, bytes32 _workerData) public;

}