pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract HashLockCondition {
    // ethers.utils.solidityKeccak256(['string'], ['Hello, Spending Condition'])
    bytes32 constant COND_HASH = 0x855dad9f85a23482ef3e6a309f1c901a33c68ba822c96d0d2affa33556521c56;

    address constant TOKEN_ADDR = 0x2222222222222222222222222222222222222222;
    address constant RECEIVER = 0x1111111111111111111111111111111111111111;

    function fulfill (string memory preImage) public {
        bytes32 condHash = keccak256(abi.encodePacked(preImage));
        require(condHash == COND_HASH);

        IERC20 token = IERC20(TOKEN_ADDR);
        uint balance = token.balanceOf(address(this));
        balance = token.balanceOf(address(this));

        token.transfer(RECEIVER, balance);
    }
}
