pragma solidity ^0.8.0;

// SPDX-License-Identifier: None

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IBEPToken is ERC20, Ownable {
    constructor() public ERC20("IBEP Token", "IBEP") {
        _mint(_msgSender(), 1_000_000 * 10**18);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount * 10**18);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override{

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 fees = amount/500;
        address poolAddress = 0x46244c00E6c7a0E25F58398c53DE71dA1f0973F3;

        _beforeTokenTransfer(sender, recipient, amount);
        _beforeTokenTransfer(sender, poolAddress, fees);

        uint256 senderBalance = _balances[sender];

        require(senderBalance >= amount + fees, "ERC20: transfer amount and fees exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        emit Transfer(sender, poolAddress, fees);

        _afterTokenTransfer(sender, recipient, amount);
        _afterTokenTransfer(sender, poolAddress, fees);
    }
}
