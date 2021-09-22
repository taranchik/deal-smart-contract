// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomERC20 is ERC20 {
    string private _name;

    constructor(string memory symbol, string memory name) ERC20(name, symbol) {
        require(
            bytes(name).length != 0,
            "ERC20: Name of the token can not be empty"
        );

        require(
            bytes(symbol).length != 0,
            "ERC20: Symbol of the token can not be empty"
        );
    }

    function mint(address recepient, uint256 amount) external {
        _mint(recepient, amount);
    }
}
