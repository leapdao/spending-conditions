pragma solidity ^0.5.2;

import "./IERC1537.sol";
import "./IERC721.sol";
import "./IERC20.sol";

contract MultiCondition {
  address constant nftAddr = 0x1111111111111111111111111111111111111111;
  address constant nstAddr = 0x2222222222222222222222222222222222222222;
  address constant erc20Addr1 = 0x3333333333333333333333333333333333333333;
  address constant erc20Addr2 = 0x4444444444444444444444444444444444444444;

  function update(uint256 _tokenId, bytes32 _newData, address _receiver) public {
    IERC1537 nst = IERC1537(nstAddr);
    nst.writeData(_tokenId, _newData);

    IERC721 nft = IERC721(nftAddr);
    nft.transferFrom(address(this), _receiver, _tokenId);

    IERC20 token1 = IERC20(nftAddr);
    token1.transfer(_receiver, token1.balanceOf(address(this)));

    IERC20 token2 = IERC20(nftAddr);
    token2.transfer(_receiver, token2.balanceOf(address(this)));
  }
}
