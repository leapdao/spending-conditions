pragma solidity ^0.5.2;
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";

contract NftUnCondition {
  address constant tokenAddr = 0x1111111111111111111111111111111111111111;

  function fulfil(address _receiver, uint256 _tokenId) public {
    IERC721 token = IERC721(tokenAddr);
    token.transferFrom(address(this), _receiver, _tokenId);
  }
}
