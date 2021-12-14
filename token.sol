// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DogZVerseToken is Ownable, ERC20 {
    
    using SafeMath for uint256;
    address public devAddress;
    address public externalFarm;
    uint256 public maxSupply = 50_000_000 * (10 ** 18);
    uint256 public taxFee = 5;

    mapping(address => bool) private _isExcludedFromFee;

    constructor() ERC20("DogZVerse Token", "DGZV") {
        _mint(_msgSender(), maxSupply);
        _isExcludedFromFee[_msgSender()] = true;
        externalFarm = _msgSender();
        devAddress = _msgSender();
    }

    function _transfer(address sender, address recipient, uint256 amount
    ) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool takeFee = true;
        if (
            _isExcludedFromFee[sender] || (_isExcludedFromFee[recipient] && recipient != externalFarm)
        ) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 _taxFee = amount.mul(taxFee).div(1000);
            super._transfer(sender, devAddress, _taxFee);
            amount = amount.sub(_taxFee);
        }
        super._transfer(sender, recipient, amount);
    }

    function setFarm(address _farm) external onlyOwner {
        externalFarm = _farm;
    }

    function setFeeAmount(uint256 _taxFee) public onlyOwner {
        taxFee = _taxFee;
    }

    function updateDevAddress(address _devAddress) public onlyOwner returns (bool)
    {
        _isExcludedFromFee[devAddress] = false;
        devAddress = _devAddress;
        _isExcludedFromFee[devAddress] = true;
        return true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
}