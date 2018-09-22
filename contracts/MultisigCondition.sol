pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "./StorageTokenInterface.sol";

contract MultisigCondition {
    uint256 constant alice = 123;   // storage token owned by alice
    uint256 constant bob = 456;     // storage token owned by bob
    uint256 constant charlie = 789; // storage token owned by charlie
    uint256 constant threshold = 2;
    
    function fulfil(address[] _tokenAddr,               // inputs
        address _receiver, uint256 _amount) public {    // outputs

        // check condition
        uint256 haveAgreed = 0;
        StorageTokenInterface stor = StorageTokenInterface(_tokenAddr[1]);
        haveAgreed += address(stor.read(alice)) == _receiver ? 1 : 0;
        haveAgreed += address(stor.read(bob)) == _receiver ? 1 : 0;
        haveAgreed += address(stor.read(charlie)) == _receiver ? 1 : 0;
        require(haveAgreed >= threshold);
        
        // do transfer
        ERC20Basic token = ERC20Basic(_tokenAddr[0]);
        token.transfer(address(_receiver), _amount);
    }
}