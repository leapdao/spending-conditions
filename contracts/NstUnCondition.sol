pragma solidity ^0.5.2;

import "./IERC1948.sol";
import "./IERC721.sol";
import "./PlasmaBridge.sol";

contract NstUnCondition {
  address constant nftAddr = 0x1111111111111111111111111111111111111111;

  function update(uint256 _tokenId, bytes32 _newData) public {
    IERC1948 nst = IERC1948(nftAddr);
    nst.writeData(_tokenId, _newData);
  }
}
