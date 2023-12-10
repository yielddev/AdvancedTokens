// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import {ERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/ERC20.sol";
// import {Ownable2Step} from "@openzeppelin/contracts@v5.0.0/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts@v5.0.0/access/Ownable.sol";

error SanctionToken_ZeroAddress();
error SanctionToken_SanctionedAddress(address account);

/// @title Sanction Token
/// @author Yielddev
/// @notice extend ERC20 token to allow for sanctioning of accounts
/// @dev Utilizes basic ERC20 implementation from OpenZeppelin and overrides _update to check if the sender or receiver is sanctioned
contract SanctionToken is ERC20, Ownable{
   mapping(address => bool) public sanctioned;

    constructor(address god) ERC20("SanctionToken", "SANCT") Ownable(god) {

    }

    /// @notice sanction an account
    /// @dev only owner can sanction an account
    /// @dev cannot sanction the zero address
    /// @param account address to be sanctioned
    function sanction(address account) public onlyOwner {
        if (account == address(0)) revert SanctionToken_ZeroAddress();
        sanctioned[account] = true;
    }

    function unsanction(address account) public onlyOwner {
        sanctioned[account] = false;
    }

    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }

    /// @inheritdoc ERC20
    function _update(address from, address to, uint256 value) internal override {
        if (sanctioned[from]) {
            revert SanctionToken_SanctionedAddress(from);
        } else if (sanctioned[to]) {
            revert SanctionToken_SanctionedAddress(to);
        }

        super._update(from, to, value);
    }
}