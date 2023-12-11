// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";
import {GodToken} from "../src/GodToken.sol";
contract EscrowTest is Test {
    GodToken public token;
    Escrow public escrow;
    address public OwnerWallet;
    address public sellerWallet;
    address public buyerWallet;
    function setUp() public {
        OwnerWallet = address(69);
        sellerWallet = address(420);
        buyerWallet = address(666);
        token = new GodToken(address(OwnerWallet));
        vm.startPrank(OwnerWallet);
        //token.mint(sellerWallet, 100000 ether);
        token.mint(buyerWallet, 100000 ether);
        escrow = new Escrow();
        vm.stopPrank();
    }

    // happy path
    function test_buy_deposit() public {
        vm.startPrank(buyerWallet);
        token.approve(address(escrow), 1 ether);
        escrow.buyerDeposit(1 ether, sellerWallet, address(token));
        assertEq(token.balanceOf(address(escrow)), 1 ether); 
        vm.stopPrank();
        uint256 start = block.timestamp;
        vm.warp(start + 3 days);
        vm.startPrank(sellerWallet);
        escrow.sellerWithdraw(buyerWallet, address(token));
        vm.stopPrank();
        assertEq(token.balanceOf(sellerWallet), 1 ether);
    }

    function test_refund() public {
        vm.startPrank(buyerWallet);
        token.approve(address(escrow), 1 ether);
        escrow.buyerDeposit(1 ether, sellerWallet, address(token));
        assertEq(token.balanceOf(address(escrow)), 1 ether); 
        escrow.buyerRefund(sellerWallet, address(token));
        vm.stopPrank();
        assertEq(token.balanceOf(buyerWallet), 100000 ether);
        assertEq(token.balanceOf(address(escrow)), 0);
    }

    function test_withdraw_twice() public {
        vm.startPrank(buyerWallet);
        token.approve(address(escrow), 1 ether);
        escrow.buyerDeposit(1 ether, sellerWallet, address(token));
        assertEq(token.balanceOf(address(escrow)), 1 ether); 
        vm.stopPrank();
        uint256 start = block.timestamp;
        vm.warp(start + 3 days);
        vm.startPrank(sellerWallet);
        escrow.sellerWithdraw(buyerWallet, address(token));
        vm.stopPrank();
        assertEq(token.balanceOf(sellerWallet), 1 ether);
        escrow.sellerWithdraw(buyerWallet, address(token));
        assertEq(token.balanceOf(sellerWallet), 1 ether);
    }

}