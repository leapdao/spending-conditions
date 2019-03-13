/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./StorageTokenInterface.sol";

contract MultisigCondition {
    uint256 constant alice = 123;   // storage token owned by alice
    uint256 constant bob = 456;     // storage token owned by bob
    uint256 constant charlie = 789; // storage token owned by charlie
    uint256 constant threshold = 2;
    
    function fulfil(address[] memory _tokenAddr,        // inputs
        address _receiver, uint256 _amount) public {    // outputs

        // check condition
        uint256 haveAgreed = 0;
        StorageTokenInterface stor = StorageTokenInterface(_tokenAddr[1]);
        haveAgreed += address(uint160(uint256(stor.read(alice)))) == _receiver ? 1 : 0;
        haveAgreed += address(uint160(uint256(stor.read(bob)))) == _receiver ? 1 : 0;
        haveAgreed += address(uint160(uint256(stor.read(charlie)))) == _receiver ? 1 : 0;
        require(haveAgreed >= threshold);
        
        // do transfer
        ERC20 token = ERC20(_tokenAddr[0]);
        token.transfer(address(_receiver), _amount);
    }
}
