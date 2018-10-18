pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "./StorageTokenInterface.sol";
import "./Reflectable.sol";

contract CounterCondition {
    using Reflectable for address;
    uint256 constant tokenId = 1234;
    address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;
    
    function fulfil(bytes32 _r, bytes32 _s, uint8 _v,   // signature
        address[] _tokenAddr,                           // inputs
        address _receiver, uint256 _amount) public {    // outputs

        // check signature
        address signer = ecrecover(bytes32(ripemd160(address(this).bytecode())), _v, _r, _s);
        //require(signer == spenderAddr);

        // update counter
        StorageTokenInterface stor = StorageTokenInterface(_tokenAddr[1]);
        uint256 count = uint256(stor.read(tokenId));
        stor.write(tokenId, bytes32(count + 1));
        
        // do transfer
        ERC20Basic token = ERC20Basic(_tokenAddr[0]);
        if (count < 4) {
            require(_receiver == address(this));
        }
        token.transfer(address(_receiver), _amount);
    }
}