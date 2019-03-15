pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./PlasmaBridge.sol";


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
contract LimitOrderCondition {
  address constant sellTokenAddr = 0x1111111111111111111111111111111111111111;
  address constant buyTokenAddr = 0x2222222222222222222222222222222222222222;
  uint256 constant limitPrice = 5;

  address constant seller = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;
  address constant kyc =   0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;

  // spending conditions TXOs are spent if
  // 1. hash of script matches condHash
  // 2. msgData evaluates the the script to true (transfer events match outputs)
  //
  //  TXOs exchanged between seller and buyer
  // +---------+      +--------+     +-------+
  // |colorA   |   <--+prevOut |     |colorB |
  // |condHash |      |msgData +--+--+seller |
  // |amount   |      |script  |  |  |amount |
  // +---------+      +--------+  |  +-------+
  //                              |
  // +---------+      +--------+  |  +-------+
  // |colorB   |   <--+prevOut |  |  |colorA |
  // |buyer    |      |sig     +--+--+buyer  |
  // |amount   |      +--------+     |amount |
  // +---------+                     +-------+
  function fill(uint8 _v, bytes32 _r, bytes32 _s) public {
    // check that buyer is authorized to hold token
    address signer = ecrecover(keccak256(abi.encodePacked(sellTokenAddr, msg.sender)), _v, _r, _s);
    require(signer == kyc, "invalid kyc signature");

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
    sellToken.transfer(msg.sender, orderSize);
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