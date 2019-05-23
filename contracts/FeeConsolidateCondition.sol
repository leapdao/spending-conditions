pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./IExitHandler.sol";

contract FeeConsolidateCondition {
  address constant tokenAddr = 0x1231111111111111111111111111111111111111;

  function consolidate() public {
    IERC20 token = IERC20(tokenAddr);
    token.transfer(address(this), token.balanceOf(address(this)));
  }

  // startExit 
  // triggers the exit of all funds to a contract on mainnet
  // only used on mainnet 
  address constant bridgeAddr = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
  address constant multisig = 0x1232222222222222222222222222222222222222;

  // startExit 
  // triggers the exit of funds to a contract on parent chain
  function startExit(
    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,
    uint8 _outputIndex, uint8 _inputIndex, address _handlerAddr
  ) public {
    require(msg.sender == multisig, "only multisig");
    IExitHandler exitHandler = IExitHandler(_handlerAddr);
    exitHandler.startExit(_youngestInputProof, _proof, _outputIndex, _inputIndex);
  }

  // withdraw exited funds on parent chain
  function withdraw() public {
    require(msg.sender == multisig, "only multisig");
    IERC20 token = IERC20(tokenAddr);
    token.transfer(multisig, token.balanceOf(address(this)));
  }
}