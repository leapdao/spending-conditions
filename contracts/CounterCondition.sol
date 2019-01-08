/**
 * Copyright (c) 2017-present, Parsec Labs (parseclabs.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */
 
pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./StorageTokenInterface.sol";
import "./Reflectable.sol";

contract CounterCondition is Reflectable {
    uint256 constant tokenId = 1234;
    address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;
    
    function fulfil(bytes32 _r, bytes32 _s, uint8 _v,   // signature
        address[] memory _tokenAddr,                           // inputs
        address _receiver, uint256 _amount) public {    // outputs

        // check signature
        address signer = ecrecover(bytes32(ripemd160(bytecode(address(this)))), _v, _r, _s);
        //require(signer == spenderAddr);

        // update counter
        StorageTokenInterface stor = StorageTokenInterface(_tokenAddr[1]);
        uint256 count = uint256(stor.read(tokenId));
        stor.write(tokenId, bytes32(count + 1));
        
        // do transfer
        ERC20 token = ERC20(_tokenAddr[0]);
        if (count < 4) {
            require(_receiver == address(this));
        }
        token.transfer(address(_receiver), _amount);
    }
}