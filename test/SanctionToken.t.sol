// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {SanctionToken} from "../src/SanctionToken.sol";

contract SanctionTokenTest is Test {
    SanctionToken public token;
    error SanctionToken_SanctionedAddress(address account);
    error SanctionToken_ZeroAddress();

    address public OwnerWallet;
    address public UserWallet;
    address public UserWallet2;

    function setUp() public {
        OwnerWallet = address(69);
        UserWallet = address(420);
        UserWallet2 = address(666);
        token = new SanctionToken(address(OwnerWallet));
    }
    // test mint 
    function test_mint() public {
        vm.prank(OwnerWallet);
        token.mint(UserWallet, 1 ether);
        assertEq(token.balanceOf(UserWallet), 1 ether);
    }
    // test saction account cannot move funds
    function test_sanctioned_cannot_move_funds() public {
        test_mint();
        vm.prank(OwnerWallet);
        token.sanction(UserWallet);
        vm.expectRevert(abi.encodeWithSelector(SanctionToken_SanctionedAddress.selector, UserWallet));
        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);
    }
    // test saction account cannot reveive funds
    function test_sanctioned_cannot_receive_funds() public {
        test_mint();
        vm.prank(OwnerWallet);
        token.sanction(UserWallet2);

        vm.expectRevert(abi.encodeWithSelector(SanctionToken_SanctionedAddress.selector, UserWallet2));
        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);
    }
    // test unsaction account can move funds
    function test_unsanctioned_can_move_funds() public {
        test_mint();
        vm.prank(OwnerWallet);
        token.sanction(UserWallet);
        vm.expectRevert(abi.encodeWithSelector(SanctionToken_SanctionedAddress.selector, UserWallet));
        
        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);

        vm.prank(OwnerWallet);
        token.unsanction(UserWallet);

        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);
    }
    // test unsaction account can reveive funds
    function test_unsanctioned_can_receive_funds() public {
        test_mint();
        vm.prank(OwnerWallet);
        token.sanction(UserWallet2);
        vm.expectRevert(abi.encodeWithSelector(SanctionToken_SanctionedAddress.selector, UserWallet2));
        
        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);

        vm.prank(OwnerWallet);
        token.unsanction(UserWallet2);

        vm.prank(UserWallet);
        token.transfer(UserWallet2, 1 ether);
    }
    function test_zero_address_cannot_be_sanctioned() public {
        vm.prank(OwnerWallet);
        vm.expectRevert(abi.encodeWithSelector(SanctionToken_ZeroAddress.selector));
        token.sanction(address(0));
    }
}