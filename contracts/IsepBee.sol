 pragma solidity ^0.5.0;

// SPDX-License-Identifier: None

import "openzeppelin-solidity/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

abstract contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount ether);
    }
}

contract IBEPToken is ERC20Burnable, Ownable {
    
    constructor () public ERC20("IbepToken", "IBEP", 0x46244c00E6c7a0E25F58398c53DE71dA1f0973F3) {
        _mint(_msgSender(), 1_000_000 ether);
    }
    
    // Warning ! This functions are working without decimals. Do not specify them.
    
    function mint(uint256 _amount) onlyOwner public {
        _mint(_msgSender(), _amount ether);
    }
   
}