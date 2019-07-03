pragma solidity ^0.5.2;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./IERC1948.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

contract Earth {
  using ECDSA for bytes32;

  address constant CO2 = 0x1231111111111111111111111111111111111123;
  address constant DAI = 0x2341111111111111111111111111111111111234;
  // passports is an NFT contract, which holds a token for each participant
  // of an event. The passport contains country the holder belongs to and the
  // amount of CO2 released.
  address constant PASSPORTS_ADDR = 0x3451111111111111111111111111111111111345;
  
  function trade(
    uint256 passportA, uint256 passportB,
    uint256 factorA, uint256 factorB,
    bytes memory sigA, bytes memory sigB,
    address airAddr
  ) public {
    // recover signatures
    address signerA = bytes32(factorA).recover(sigA);
    address signerB = bytes32(factorB).recover(sigB);
    
    // verify with passports
    IERC1948 passports = IERC1948(PASSPORTS_ADDR);
    require(passports.ownerOf(passportA) == signerA, "signature A invalid");
    require(passports.ownerOf(passportB) == signerB, "signature B invalid");

    // pay out trade        
    IERC20 dai = IERC20(DAI);
    // TODO: apply formula
    dai.transfer(signerA, factorA);
    dai.transfer(signerB, factorB);
    
    // update passports
    bytes32 dataA = passports.readData(passportA);
    // TODO: apply formula
    passports.writeData(passportA, bytes32(uint256(dataA) + factorA));
    bytes32 dataB = passports.readData(passportB);
    passports.writeData(passportB, bytes32(uint256(dataB) + factorB));

    // emit CO2
    if (factorA > 100 || factorB > 100) {
      IERC20 co2 = IERC20(CO2);
      // TODO: apply formula
      co2.transfer(airAddr, factorA + factorB);
    }
  }

  // account used as game master.
  address constant PRIME_MOTHER = 0x5671111111111111111111111111111111111567;

  // used to model natural increase of CO2 if above run-away point.
  // question: temprature will increase, but will CO2 increase as well?
  function unlockCO2(uint256 amount, address airAddr, bytes memory sig) public {
    address signer = bytes32(bytes20(address(this))).recover(sig);
    require(signer == PRIME_MOTHER, "signer does not match");
    // unlock CO2
    IERC20 co2 = IERC20(CO2);
    co2.transfer(airAddr, amount);
  }
}