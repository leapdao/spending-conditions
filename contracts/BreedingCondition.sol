pragma solidity ^0.5.2;

import "./IERC1537.sol";
import "./IERC721.sol";
import "./PlasmaBridge.sol";

contract BreedingCondition {
  address constant nftAddr = 0x1111111111111111111111111111111111111111;

  // spending conditions TXOs are spent if
  // 1. hash of script matches condHash
  // 2. msgData evaluates the the script to true (transfer events match outputs)
  //
  //  breeding as new output
  // +---------+      +--------+     +--------+
  // |counter  |   <--+prevOut |     |count+1 |
  // |condHash |      |msgData +--+--+condHash|
  // |tokenId  |      |script  |  |  |tokenId |
  // +---------+      +--------+  |  +--------+
  //                              |
  //                              |  +--------+
  //                              |  |0x00    |
  //                              +--+receiver|
  //                                 |newId   |
  //                                 +--------+
  function breed(uint256 _tokenId, uint256 _counter, address _receiver) public {
    // setup
    IERC1537 nst = IERC1537(nftAddr);
    IERC721 nft = IERC721(nftAddr);
    require(nft.ownerOf(_tokenId) == address(this));
    require(uint256(nst.readData(_tokenId)) == _counter);
    uint256 newId = uint256(keccak256(abi.encodePacked(_tokenId, _counter)));
    nst.writeData(_tokenId, bytes32(_counter + 1));
    nft.transferFrom(address(this), _receiver, newId);
  }

  // startExit 
  // triggers the exit of all funds to a contract on mainnet
  // only used on mainnet 
  address constant bridgeAddr = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
  address constant minterAddr = 0x2222222222222222222222222222222222222222;

  function startExit(bytes32[] memory _proof, uint _oindex) public {
    if (msg.sender == minterAddr) {
      PlasmaBridge bridge = PlasmaBridge(bridgeAddr);
      bridge.startExit(_proof, _oindex);
    }
  }
}