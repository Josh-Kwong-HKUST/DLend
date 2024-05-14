// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HKDcoin is ERC20 {
    constructor() ERC20("HKDcoin", "HKDC") {
        _mint(msg.sender, formatAmount(1000));
    }
    
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function formatAmount(uint amount) private pure returns (uint256){
        return amount* 10**uint256(decimals());
    }

    function mintToken(uint amount) public{
        _mint(msg.sender, formatAmount(amount));
    }
}
