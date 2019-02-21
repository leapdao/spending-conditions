pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract RedEnvelope {
  uint256 constant envelopeId = 1234; // nonce, so that signatures can not be replayed
  uint256 constant numClaimants = 4;  // number of claimants

  function fulfil(bytes32 _r, bytes32 _s, uint8 _v, address _tokenAddr) public {
    
    // check signature
    address signer = ecrecover(bytes32(bytes20(address(this))) >> 96, _v, _r, _s);
    
    // do transfer
    IERC20 token = IERC20(_tokenAddr);
    address spAddr = address(this);
    uint256 amount = token.balanceOf(spAddr) / numClaimants;
    uint256 rest = token.balanceOf(spAddr) - amount;
    token.transfer(signer, amount);
    if (rest > 0 ) {
      token.transfer(spAddr, rest);
    }
  }

}