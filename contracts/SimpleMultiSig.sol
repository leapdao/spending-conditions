pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./PlasmaBridge.sol";

contract SimpleMultiSig {
  address constant alice = 0xCED6Cec7891276E58d9434426831709fcBdD0C49;
  address constant bob = 0x89C368C9bff1Cb5e374e76dE3c5b744DBc1d23Fc;
  address constant charlie = 0x2b2B598Faba3661C2e4eaA75f9E6a111d860a86D;
  uint256 constant mutliSigId = 1234; //nonce so that signatures can not be replayed

  function fulfil(
    address to,
    bytes32 _r1, 
    bytes32 _s1, 
    uint8 _v1, 
    bytes32 _r2, 
    bytes32 _s2, 
    uint8 _v2, 
    address _tokenAddr) 
  public {
    address signer1 = ecrecover(
      bytes32(bytes20(address(this))) >> 96, 
      _v1, 
      _r1, 
      _s1);

    address signer2 = ecrecover(
      bytes32(bytes20(address(this))) >> 96, 
      _v2, 
      _r2, 
      _s2);

    require(signer1 != signer2);
    require(signer1 == alice || signer1 == bob || signer1 == charlie);
    require(signer2 == alice || signer2 == bob || signer2 == charlie);

    IERC20 token = IERC20(_tokenAddr);
    address spAddr = address(this);
    uint256 amount = token.balanceOf(spAddr);
    token.transfer(to, amount);
  }

  address constant bridgeAddr = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  function startExit(bytes32[] memory _proof, uint _oindex) public {
    if (msg.sender == alice || msg.sender == bob || msg.sender == charlie) {
      PlasmaBridge bridge = PlasmaBridge(bridgeAddr);
      bridge.startExit(_proof, _oindex);
    }
  }
}