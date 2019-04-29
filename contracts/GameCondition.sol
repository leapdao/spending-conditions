
pragma solidity ^0.5.2;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract GameCondition {

  uint256 constant HAND_SIZE = 5;

  // returns: array with 2xHAND_SIZE elements: 0-4 player hand / 5-9 house hand
  function readCards(bytes32 _cards) internal pure returns (uint256[] memory cards) {
    cards = new uint256[](HAND_SIZE * 2);
    for(uint i = 0; i < HAND_SIZE * 2; i++) {
      cards[i] = uint16(uint256(_cards) >> (16 * i));
    }
  }

  function sort(uint256[] memory data) internal pure returns(uint256[] memory) {
   // only sort player hands
   quickSort(data, int(0), int(HAND_SIZE - 1));
   return data;
  }

  function quickSort(uint256[] memory arr, int left, int right) internal pure {
    int i = left;
    int j = right;
    if(i==j) return;
    uint pivot = arr[uint(left + (right - left) / 2)];
    while (i <= j) {
      while (arr[uint(i)] < pivot) i++;
      while (pivot < arr[uint(j)]) j--;
      if (i <= j) {
        (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
        i++;
        j--;
      }
    }
    if (left < j)
      quickSort(arr, left, j);
    if (i < right)
      quickSort(arr, i, right);
  }

  function isCardsSame(uint256[] memory _handA, uint256[] memory _handB) internal pure returns (bool) {
    uint256[] memory handA = sort(_handA);
    uint256[] memory handB = sort(_handB);
    for(uint i = 0; i < HAND_SIZE; i++) {
      require(handA[i] == handB[i], "hands not same");
    }
    return true;
  }

  // 1 house wins / 2 player wins / 0 equal
  function runGame(uint256[] memory _handHouse, uint256[] memory _handPlayer) internal pure returns (uint) {
    uint256 countHouse = 0;
    uint256 countPlayer = 0;
    for(uint i = 0; i < HAND_SIZE; i++) {
      countHouse += (_handHouse[i + HAND_SIZE] > _handPlayer[i]) ? 1 : 0;
      countPlayer += (_handHouse[i + HAND_SIZE] < _handPlayer[i]) ? 1 : 0;
    }
    return (countHouse > countPlayer) ? 1 : (countHouse < countPlayer) ? 2 : 0;
  }

  address constant TOKEN_ADDR = 0x1234111111111111111111111111111111111111;
  // one card consists of 2 bytes: 1st byte suit, second byte value
  // example: 0x0000000000000000000000000105040603070208010901050206030704080409
  bytes32 constant CARD_BYTES = 0x2345222222222222222222222222222222222222222222222222222222222222;
  address constant HOUSE = 0x3456333333333333333333333333333333333333;
  address constant PLAYER = 0x4567444444444444444444444444444444444444;

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
    
  function _ecRecoverPersonal(bytes32 _cards, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
    bytes32 sigHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uint2str(32), _cards));
    return ecrecover(sigHash, _v, _r, _s);
  }

  function fulfill(bytes32 _cardsPlayer, bytes32 _r, bytes32 _s, uint8 _v) public {
    // check signature
    address signer = _ecRecoverPersonal(_cardsPlayer, _v, _r, _s);
    require(signer == PLAYER, "sig does not match");

    // check cards
    uint256[] memory cards = readCards(CARD_BYTES);
    uint256[] memory cardsPlayer = readCards(_cardsPlayer);
    require(isCardsSame(cards, cardsPlayer), "player hands not same");
    
    // pull funds
    IERC20 token = IERC20(TOKEN_ADDR);
    uint256 balance = token.balanceOf(address(this));
    token.transferFrom(PLAYER, address(this), balance / 5);
    balance = token.balanceOf(address(this));

    // find winner
    uint256 result = runGame(cards, cardsPlayer);
    if (result == 1) {
      token.transfer(HOUSE, balance);
    } else if (result == 2) {
      token.transfer(PLAYER, balance);
    } else {
      token.transfer(HOUSE, (balance / 6) * 5);
      balance = token.balanceOf(address(this));
      token.transfer(PLAYER, balance);
    }
  }
}
