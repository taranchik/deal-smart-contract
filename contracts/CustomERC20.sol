// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomERC20 is ERC20 {
    string private _name;

    constructor(string memory symbol, string memory name) ERC20(name, symbol) {}

    function mint(address recepient, uint256 amount) external {
        _mint(recepient, amount);
    }
}
