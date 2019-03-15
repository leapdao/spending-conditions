pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./PlasmaBridge.sol";
import "./StorageTokenInterface.sol";


// LimitOrderCondition
// the order is funded by
// 1. compiling the code
// 2. hashing the code to 20 bytes (ripemd160)
// 3. sending funds to the hash
//
// sellerTXO   funding         limitOrderUTXO
// +-------+        +--------+   +---------+
// |colorA |     <--+prevOut |   |colorA   |
// |seller |        |sig     +---+condHash |
// |amount |        +--------+   |amount   |
// +-------+                     +---------+
contract LimitOrderWithStateCondition {
  address constant sellTokenAddr = 0x1111111111111111111111111111111111111111;
  address constant buyTokenAddr = 0x2222222222222222222222222222222222222222;
  address constant kycNftAddr = 0x3333333333333333333333333333333333333333;
  uint256 constant limitPrice = 5;

  address constant seller = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;


  // +---------+      +--------+     +-------+
  // |colorA   |   <--+prevOut |     |colorA |
  // |condHash |      |msgData +--+--+buyer  |
  // |amount   |      |script  |  |  |amount |
  // +---------+      +--------+  |  +-------+
  //                              |
  // +---------+      +--------+  |  +-------+
  // |colorB   |   <--+prevOut |  |  |colorB |
  // |buyer    |      |sig     +--+--+seller |
  // |amount   |      +--------+  |  |amount |
  // +---------+                  |  +-------+
  //                              |
  // +---------+      +--------+  |
  // |nftColor |   <--+prevOut +--+
  // |owner    |      |readOnly|
  // |nftId    |      +--------+
  // |root     |
  // +---------+
  function fill(
    uint256 _country,
    uint256 _branchMask1,
    bytes32[] memory _siblings1,
    uint256 _branchMask2,
    bytes32[] memory _siblings2
  ) public {
    // check that buyer is authorized to hold token
    StorageTokenInterface kycNft = StorageTokenInterface(kycNftAddr);
    // verify country of buyer
    uint256 tokenId = 0;
    bytes32 key = bytes32(bytes20(msg.sender));
    bytes32 value = bytes32(_country);
    kycNft.verify(tokenId, key, value, _branchMask1, _siblings1);
    // verify that token is whitelisted in buyer's country
    tokenId = _country;
    key = bytes32(bytes20(sellTokenAddr));
    value = bytes32(uint256(1));
    kycNft.verify(tokenId, key, value, _branchMask2, _siblings2);

    // setup
    IERC20 sellToken = IERC20(sellTokenAddr);
    uint256 orderSize = sellToken.balanceOf(address(this));
    address buyer = msg.sender;

    // do buyToken transfer
    IERC20 buyToken = IERC20(buyTokenAddr);
    uint256 buyerBalance = buyToken.balanceOf(buyer);
    buyToken.transferFrom(buyer, seller, orderSize * limitPrice);
    // spend utxo in full
    uint256 rest = buyerBalance - orderSize * limitPrice;
    buyToken.transferFrom(buyer, buyer, rest);

    // do sellToken transfer
    sellToken.transfer(buyer, orderSize);
  }

  // used on mainnet or plasma to cancel order
  // +---------+      +--------+     +-------+
  // |colorA   |   <--+prevOut |     |colorA |
  // |condHash |      |msgData +-----+seller |
  // |amount   |      |script  |     |amount |
  // +---------+      +--------+     +-------+
  function cancel() public {
    if (msg.sender == seller) {
      IERC20 token = IERC20(sellTokenAddr);
      token.transfer(seller, token.balanceOf(address(this)));
    }
  }

  // startExit 
  // triggers the exit of all funds to a contract on mainnet
  // only used on mainnet 
  address constant bridgeAddr = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  function startExit(bytes32[] memory _proof, uint _oindex) public {
    if (msg.sender == seller) {
      PlasmaBridge bridge = PlasmaBridge(bridgeAddr);
      bridge.startExit(_proof, _oindex);
    }
  }
}