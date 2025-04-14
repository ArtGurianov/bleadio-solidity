// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestUSD is ERC20 {
    constructor() ERC20("TestUSD", "TESTUSD") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function publicMintUSD(uint256 amountUSD) public {
        _mint(msg.sender, amountUSD * 10 ** decimals());
    }
}
