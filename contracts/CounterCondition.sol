pragma solidity ^0.4.24;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";
import "./StorageTokenInterface.sol";

contract CounterCondition {
    uint256 constant tokenId = 1234;
    
    function fulfil(address[] _tokenAddr,               // inputs
        address _receiver, uint256 _amount) public {    // outputs

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