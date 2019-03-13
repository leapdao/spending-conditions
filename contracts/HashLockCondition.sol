pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract SpendingCondition {
    // leap-token
    address constant TOKEN_ADDR = 0xD2D0F8a6ADfF16C2098101087f9548465EC96C98;
    // sha3(0xbadbeef)
    // 0xc0ffebabe
    //
    bytes32 constant COND_HASH = 0x36ac47a22fb15eb18d90d1c3cf47d46a87e176452e345fa3efeb685c44dff315;

    function fulfill (string memory preImage) public {
        bytes32 condHash = keccak256(abi.encodePacked(preImage));
        require(condHash == COND_HASH);

        IERC20 token = IERC20(TOKEN_ADDR);
        uint balance = token.balanceOf(address(this));

        token.transfer(msg.sender, balance);
    }

    function exit () public {
        // bridge ? ;)
    }
}
