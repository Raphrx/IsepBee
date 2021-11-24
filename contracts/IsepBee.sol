 pragma solidity ^0.8.0;

// SPDX-License-Identifier: None

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IBEPToken is ERC20, Ownable {
    
    constructor() public ERC20("IbepToken", "IBEP") {
        _mint(_msgSender(), 1_000_000*10**18);
    }
    
    // Warning ! This functions are working without decimals. Do not specify them.
    
    function mint(uint256 _amount) onlyOwner public {
        _mint(_msgSender(), _amount*10**18);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount*10**18);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 fees = amount/500; // 0,2% fees
        _transfer(_msgSender(), recipient, (amount - fees));
        _transfer(_msgSender(), 0x46244c00E6c7a0E25F58398c53DE71dA1f0973F3, fees);
        return true;
    }

    
   
}