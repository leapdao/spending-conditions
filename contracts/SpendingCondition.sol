pragma solidity ^0.5.2;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SpendingCondition {
  address constant tokenAddr = 0x1111111111111111111111111111111111111111;
  address constant spenderAddr = 0xF3beAC30C498D9E26865F34fCAa57dBB935b0D74;

  function fulfil(
    bytes32 _r,        // signature
    bytes32 _s,        // signature
    uint8 _v,          // signature
    address _receiver, // output
    uint256 _amount    // output
  ) public {
    // check signature
    address signer = ecrecover(bytes32(bytes20(address(this))), _v, _r, _s);
    require(signer == spenderAddr);

    // do transfer
    IERC20 token = IERC20(tokenAddr);
    uint256 diff = token.balanceOf(address(this)) - _amount;
    token.transfer(_receiver, _amount);
    if (diff > 0) {
      token.transfer(address(this), diff);
    }
  }
}
