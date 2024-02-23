// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import {ERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/ERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts@v5.0.0/access/Ownable2Step.sol";
//import {Ownable} from "@openzeppelin/contracts@v5.0.0/access/Ownable.sol";
// Add 2 step 
/// @title God Token with owner wallet able to mint and spend any balance
/// @author Yielddev
/// @notice Extended ERC 20 token for Rareskill assignment
/// @dev Utilizes basic ERC20 implementation from OpenZeppelin and overrides _spendAllowance check if the spender is the owner
contract GodToken is ERC20, Ownable2Step {
    mapping(address => bool) public sanctioned;

    constructor(address god) Ownable(god) ERC20("GodToken", "GOD") {
    }
    /// @inheritdoc ERC20
    function _spendAllowance(address owner, address spender, uint256 value) internal override {
        if(spender != this.owner()) {
            super._spendAllowance(owner, spender, value);
        }
    }
    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }
}