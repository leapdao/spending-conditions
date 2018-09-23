pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "../PlasmaInterface.sol";
import "../Reflectable.sol";

contract SpendingCondition {
    using Reflectable for address;
    uint256 constant nonce = 1234;    // nonce, so that signatures can not be replayed
    address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;

    function fulfil(bytes32 _r, bytes32 _s, uint8 _v,      // signature
        address _tokenAddr,                               // inputs
        address[] _receivers, uint256[] _amounts) public {  // outputs
        require(_receivers.length == _amounts.length);
        
        // check signature
        address signer = ecrecover(bytes32(ripemd160(address(this).bytecode())), _v, _r, _s);
        require(signer == spenderAddr);
        
        // do transfer
        ERC20Basic token = ERC20Basic(_tokenAddr);
        for (uint i = 0; i < _receivers.length; i++) {
            token.transfer(_receivers[i], _amounts[i]);
        }
    }

    function exitProxy(
        bytes32 _r, bytes32 _s, uint8 _v,   // authorization to start exit
        address _bridgeAddr,                // address of Plasma bridge
        bytes32[] _proof, uint _oindex      // tx-data, proof and output index
    ) public {
        address signer = ecrecover(ripemd160(address(this).bytecode()), _v, _r, _s);
        require(signer == spenderAddr);
        PlasmaInterface bridge = PlasmaInterface(_bridgeAddr);
        bridge.startExit(_proof, _oindex);
    }

}