pragma solidity ^0.5.2;

import "./IERC1948.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";

contract MultiCondition {
  address constant erc20Addr1 = 0x1111111111111111111111111111111111111111;
  address constant erc20Addr2 = 0x2222222222222222222222222222222222222222;
  address constant nstAddr = 0x3333333333333333333333333333333333333333;
  address constant nftAddr = 0x5555555555555555555555555555555555555555;

  function update(uint256 _tokenId, bytes32 _newData, address _receiver) public {
    IERC1948 nst = IERC1948(nstAddr);
    nst.transferFrom(_receiver, address(this), _tokenId);

    IERC721 nft = IERC721(nftAddr);
    // address approver = nft.getApproved(_tokenId);
    nft.transferFrom(_receiver, address(this), _tokenId);

    IERC20 token1 = IERC20(erc20Addr1);
    uint allowance = token1.allowance(_receiver, address(this));
    // from > to > value
    token1.transferFrom(_receiver, address(this), allowance);

    IERC20 token2 = IERC20(erc20Addr2);
    allowance = token2.allowance(_receiver, address(this));
    token2.transferFrom(_receiver, address(this), allowance);
  }
}
