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
  // CO2 flows from Earth to Air and maybe back. This is the address of the
  // earth contract.
  address constant EARTH_ADDR = 0x4561111111111111111111111111111111111456;
  
  function plantTree(uint256 amount, uint256 passport) public {

    // signer information
    IERC1948 passports = IERC1948(PASSPORTS_ADDR);
    address signer = passports.ownerOf(passport);
    address countryTreasury = address(bytes20(passports.readData(passport)));

    // cash in payment
    IERC20 dai = IERC20(DAI);
    uint256 allowance = dai.allowance(signer, address(this));
    require(allowance >= amount, "no funds allocated");
    dai.transferFrom(signer, countryTreasury, amount);
    
    // update passports
    bytes32 data = passports.readData(passport);
    // TODO: apply formula
    passports.writeData(passport, bytes32(uint256(data) - amount));

    // lock CO2
    IERC20 co2 = IERC20(CO2);
    co2.transfer(EARTH_ADDR, amount);
  }

  // account used as game master.
  address constant PRIME_MOTHER = 0x5671111111111111111111111111111111111567;

  // used to model natural reduction of CO2 if below run-away point
  function lockCO2(uint256 amount, bytes memory sig) public {
    address signer = bytes32(bytes20(address(this))).recover(sig);
    require(signer == PRIME_MOTHER, "signer does not match");
    // lock CO2
    IERC20 co2 = IERC20(CO2);
    co2.transfer(EARTH_ADDR, amount);
  }

  // used to combine multiple contract UTXOs into one.
  function consolidate(bytes memory sig) public {
    address signer = bytes32(bytes20(address(this))).recover(sig);
    require(signer == PRIME_MOTHER, "signer does not match");
    // lock CO2
    IERC20 co2 = IERC20(CO2);
    uint256 amount = co2.balanceOf(address(this));
    co2.transfer(EARTH_ADDR, amount);
  }
}