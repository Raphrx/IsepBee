pragma solidity ^0.8.0;

// SPDX-License-Identifier: None

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IBEPToken is ERC20 {
    
    constructor() ERC20("IBEP Coin", "IBEP") {
        _mint(_msgSender(), 1_000_000 * 10**18);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount * 10**18);
    }
}
