pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./PlasmaBridge.sol";
import "./StorageTokenInterface.sol";


// RoyaltyCondition
// the condition is funded by
// 1. compiling the code
// 2. hashing the code to 20 bytes (ripemd160)
// 3. sending funds to the hash
//
// viewerTXO   funding         royaltyUTXO
// +-------+        +--------+   +---------+
// |color  |     <--+prevOut |   |color    |
// |viewer |        |sig     +---+condHash |
// |amount |        +--------+   |amount   |
// +-------+                     +---------+
contract RoyaltyCondition {
  address constant tokenAddr = 0x1111111111111111111111111111111111111111;
  address constant licenseNftAddr = 0x3333333333333333333333333333333333333333;
  bytes32 constant subject = 0x4444444444444444444444444444444444444444444444444444444444444444;

  address constant whiteRabbit = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;


  // +---------+      +--------+     +-------+
  // |color    |   <--+prevOut |     |color  |
  // |condHash |      |msgData +--+--+partner|
  // |amount   |      |script  |  |  |amount |
  // +---------+      +--------+  |  +-------+
  //                              |
  // +---------+      +--------+  |
  // |nftColor |   <--+prevOut +--+
  // |wr       |      |readOnly|
  // |nftId    |      +--------+
  // |root     |
  // +---------+
  function claim(
    uint256 _branchMask,
    bytes32[] memory _siblings
  ) public {
    // check that partner is authorized to claim token
    StorageTokenInterface licenseNft = StorageTokenInterface(licenseNftAddr);
    
    bytes32 key = bytes32(uint256(1));
    bytes32 value = bytes32(bytes20(msg.sender));
    licenseNft.verify(uint256(subject), key, value, _branchMask, _siblings);

    // do transfer
    IERC20 token = IERC20(tokenAddr);
    uint256 all = token.balanceOf(address(this));
    token.transfer(msg.sender, all);
  }

  // used to consolidate 
  // +---------+      +--------+     +---------+
  // |color    |   <--+prevOut |     |color    |
  // |condHash |      |msgData +--+--+condHash |
  // |amount   |      |script  |  |  |amount   |
  // +---------+      +--------+  |  +---------+
  //                              |
  // +---------+      +--------+  |
  // |color    |   <--+prevOut +--+
  // |condHash |      +--------+
  // |amount   |
  // +---------+
  function consolidate() public {
    if (msg.sender == whiteRabbit) {
      IERC20 token = IERC20(tokenAddr);
      token.transfer(address(this), token.balanceOf(address(this)));
    }
  }

  // startExit 
  // triggers the exit of all funds to a contract on mainnet
  // only used on mainnet 
  address constant bridgeAddr = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  function startExit(bytes32[] memory _proof, uint _oindex) public {
    if (msg.sender == whiteRabbit) {
      PlasmaBridge bridge = PlasmaBridge(bridgeAddr);
      bridge.startExit(_proof, _oindex);
    }
  }
}