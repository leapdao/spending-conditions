pragma solidity ^0.4.24;

import "./StorageToken.sol";

contract Multisig {
    address constant storageAddr = 0x0;
    uint constant aliceStorage = 1;
    uint constant bobStorage = 2;
    function spend() public {
        ERC721Basic stor = ERC721Basic(storageAddr);
        address bob = stor.ownerOf(bobStorage);
        if (stor.ownerOf(aliceStorage) == bob) {
            bob.transfer(address(this).balance);
            // +--------+
            // | amount |     +------+
            // | script |  <--+ data +-+
            // +--------+     +------+ |
            //                         |
            //   +-----+     +------+ |
            //   |NFT 1|  <--+ read +-+ +-------+
            //   +-----+     +------+ | | amount|
            //                        +-+ Bob   |
            //   +-----+     +------+ | +-------+
            //   |NFT 2|  <--+ read +-+
            //   +-----+     +------+ |
            //                         |
            //   +-----+     +------+ |
            //   |UTXO |  <--+ spend+-+
            //   +-----+     +------+
        } else {
            throw;
            // transaction fails
            // +--------+
            // | amount | X X +------+
            // | script |  X--+ data +-+
            // +--------+ X X +------+ |
            //                         |
            //   +-----+     +------+ |
            //   |NFT 1|  <--+ read +-+ +-------+
            //   +-----+     +------+ | | amount|
            //                        +-+ Bob   |
            //   +-----+     +------+ | +-------+
            //   |NFT 2|  <--+ read +-+
            //   +-----+     +------+
        }
    }
}