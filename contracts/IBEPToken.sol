pragma solidity ^0.8.0;

// SPDX-License-Identifier: None

// For IBEPTOKEN contract

import "@openzeppelin/contracts/access/Ownable.sol";

// For ERC20 contract

import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

//ERC20 contract must be rewritten to modify _transfer due to private _balances
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _poolAddress;
    uint256 _fees;

    constructor(string memory name_, string memory symbol_, address poolAddress_, uint256 fees_) {
        _name = name_;
        _symbol = symbol_;
        _poolAddress = poolAddress_;
        _fees = fees_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function fees() public view virtual returns (uint256) {
        return _fees;
    }

    function poolAddress() public view virtual returns (address){
        return _poolAddress;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // Function modified from openzeppelin contract
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {

        uint256 feesAmount;

        if(_fees != 0){
            feesAmount = amount/_fees;
        }
        else{
            feesAmount = 0;
        }
        
        uint256 senderBalance = _balances[sender];

        require(senderBalance >= amount + feesAmount, "ERC20: transfer amount and fees exceeds local balance");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        

        _beforeTokenTransfer(sender, recipient, amount);
        _beforeTokenTransfer(sender, _poolAddress, feesAmount);

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        emit Transfer(sender, _poolAddress, feesAmount);

        _afterTokenTransfer(sender, recipient, amount);
        _afterTokenTransfer(sender, _poolAddress, feesAmount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from,address to,uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from,address to,uint256 amount) internal virtual {}

    function _changePoolAddress(address newPoolAddress) internal virtual {
        _poolAddress = newPoolAddress;
    }

    function _changeFeeRate(uint256 newRate) internal virtual {
        _fees = newRate;
    }
}

contract IBEPToken is ERC20, Ownable {
    
    constructor() ERC20("IBEP Token", "IBEP", 0x46244c00E6c7a0E25F58398c53DE71dA1f0973F3, 0) {
        _mint(_msgSender(), 1_000_000 * 10**18);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount * 10**18);
    }

    function changePoolAddress(address newPoolAddress) public onlyOwner {
        _changePoolAddress(newPoolAddress);
    }

    function changeFeeRate(uint256 newRate) public onlyOwner {
        _changeFeeRate(newRate);
    }
}
