// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DLT is ERC20 {
    uint24 SUPPLY = 2000000;
    constructor() ERC20("DLendToken", "DLT") {
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function formatAmount(uint amount) private pure returns (uint256) {
        return amount * 10 ** uint256(decimals());
    }

    function mintToken(address dlend) public {
        if (SUPPLY == 0) {
            return;
        }
        _mint(dlend, formatAmount(2000000));
        SUPPLY = 0;
    }
}
