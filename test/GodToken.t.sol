// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {GodToken} from "../src/GodToken.sol";

contract GodTokenTest is Test {
    GodToken public token;
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    address public GodWallet;
    address public UserWallet;
    address public UserWallet2;
    function setUp() public {
        GodWallet = address(69);
        UserWallet = address(420);
        UserWallet2 = address(666);
        token = new GodToken(address(GodWallet));
    }

    function test_mint() public {
        vm.prank(GodWallet);
        token.mint(UserWallet, 1 ether);
        assertEq(token.balanceOf(UserWallet), 1 ether);
    }

    function test_god_power() public {
        test_mint();
        vm.prank(GodWallet);
        token.transferFrom(UserWallet, UserWallet2, 1 ether);
        assertEq(token.balanceOf(UserWallet2), 1 ether);
        assertEq(token.balanceOf(UserWallet), 0);
    }
    function test_god_transfers_more_than_balance() public {
        test_mint();
        vm.expectRevert(abi.encodeWithSelector(ERC20InsufficientBalance.selector, UserWallet, 1 ether, 2 ether));
        vm.prank(GodWallet);
        token.transferFrom(UserWallet, UserWallet2, 2 ether); 
    }
}