// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts@v5.0.0/access/Ownable.sol";
import {Math} from "@openzeppelin/contracts@v5.0.0/utils/math/Math.sol";

error Escrow_EscrowTimeNotPassed();

/// @title Escrow contract
/// @author YieldDev
/// @notice Buyer can deposit funds for a 3 day escrow period 
contract Escrow {
    using SafeERC20 for IERC20;
//    mapping (address => mapping(address => mapping(address => mapping(uint256 => uint256)))) public deposits;
    mapping (address => mapping(address => mapping(address => uint256))) public deposits;
    mapping (address => mapping(address => mapping(address => uint256))) public escrowStarts;
    constructor() {}

    /// @dev buyer deposits funds for a 3 day escrow period
    /// @param amount amount of funds to deposit
    /// @param forSeller the seller that will be able to withdraw the funds
    /// @param currency the currency to deposit
    function buyerDeposit(uint256 amount, address forSeller, address currency) public { 
        deposits[msg.sender][forSeller][currency] += amount;
        escrowStarts[msg.sender][forSeller][currency]= block.timestamp;
        IERC20(currency).safeTransferFrom(msg.sender, address(this), amount);
    }
    /// @dev Seller withdraws funds after 3 day escrow period
    /// @param buyer the buyer that deposited the funds
    /// @param currency the currency to withdraw
    function sellerWithdraw(address buyer, address currency) public {
        if(block.timestamp < escrowStarts[buyer][msg.sender][currency] + 3 days) {
            revert Escrow_EscrowTimeNotPassed(); 
        }
        uint256 amount = deposits[buyer][msg.sender][currency];
        IERC20(currency).safeTransfer(msg.sender, amount);

    }
}