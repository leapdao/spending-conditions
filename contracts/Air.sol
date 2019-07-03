pragma solidity ^0.5.2;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./IERC1948.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

contract Air {
    using ECDSA for bytes32;

    address constant CO2 = 0x1231111111111111111111111111111111111123;
    address constant DAI = 0x2341111111111111111111111111111111111234;
    // passports is an NFT contract, which holds a token for each participant
    // of an event. The passport contains country the holder belongs to and the
    // amount of CO2 released.
    address constant PASSPORTS_ADDR = 0x3451111111111111111111111111111111111345;
    
    function plantTree(
      uint256 passport,
      uint256 amount,
      bytes memory sig,
      address earthAddr
    ) public {
        // recover signatures
        address signer = bytes32(amount).recover(sig);
        
        // verify with passports
        IERC1948 passports = IERC1948(PASSPORTS_ADDR);
        require(passports.ownerOf(passport) == signer, "signature invalid");
        
        // read the country's treasury address from the passport
        address countryTreasury = address(bytes20(passports.readData(passport)));

        // pay out trade        
        IERC20 dai = IERC20(DAI);
        dai.transferFrom(signer, countryTreasury, amount);
        
        // update passports
        bytes32 data = passports.readData(passport);
        passports.writeData(passport, bytes32(uint256(data) - amount));

        // lock CO2
        IERC20 co2 = IERC20(CO2);
        co2.transfer(earthAddr, amount);
    }
}