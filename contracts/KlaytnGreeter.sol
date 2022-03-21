//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Mortal {
    /* 주소 타입의 소유자(owner) 변수 정의 */
    address payable owner;
    /* 이 함수는 초기화 시점에 실행되어 컨트랙트 소유자를 설정합니다 */
    constructor () public { owner = payable(msg.sender); }
    /* 컨트랙트에서 자금을 회수하는 함수 */
    function kill() public payable { if (msg.sender == owner) selfdestruct(owner); }
}

contract KlaytnGreeter is Mortal {
    /* 문자열 타입의 변수 greeting 정의 */
    string greeting;
    /* 이 함수는 컨트랙트가 실행될 때 작동합니다 */
    constructor (string memory _greeting) public {
        greeting = _greeting;
    }
    /* 주(Main) 함수 */
    function greet() public view returns (string memory) {
        return greeting;
    }
    /* 테스트를 위해 새로 추가된 함수입니다 */
    function setGreet(string memory _greeting) public {
        // 소유자(owner)만 greeting 메세지를 수정할 수 있습니다
        require(msg.sender == owner, "Only owner is allowed.");
        greeting = _greeting;
    }
}