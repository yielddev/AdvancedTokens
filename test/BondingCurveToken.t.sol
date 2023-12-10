// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BondingCurveToken} from "../src/BondingCurveToken.sol";
import {GodToken} from "../src/GodToken.sol";
import {Math} from "@openzeppelin/contracts@v5.0.0/utils/math/Math.sol";
contract BondingCurveTokenTest is Test {
    using Math for uint256;
    BondingCurveToken public token;
    GodToken public reserveToken;
    address public OwnerWallet;
    address public UserWallet;
    address public UserWallet2;
    uint256 constant public SLOPE = 2;
    error BondingCurveToken_ZeroAmountInvalid();
    error BondingCurveToken_ReserveTokenPaymentFailed();
    error BondingCurveToken_MaxCostExceeded();
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error BondingCurveToken_MinProceedsExceeded();
    function setUp() public {
        OwnerWallet = address(69);
        UserWallet = address(420);
        UserWallet2 = address(666);
        reserveToken = new GodToken(address(OwnerWallet));
        token = new BondingCurveToken("Pumping MEME", "PMEME", address(reserveToken));
        vm.startPrank(OwnerWallet);
        reserveToken.mint(UserWallet, 100000 ether);
        reserveToken.mint(UserWallet2, 100000 ether);
        vm.stopPrank();
    }
    function calculate_buy_cost(uint256 amount, uint256 supply) public pure returns (uint256) {
        return ( (amount * SLOPE) * ( supply + ( amount/ 2) ) ) / 1 ether;
    }
    function calculate_sell_cost(uint256 amount, uint256 supply) public pure returns (uint256) {
        return ( (amount * SLOPE) * ( supply - (amount / 2) ) ) / 1 ether;
    }

    function test_buy() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(1 ether, calculate_buy_cost(1 ether, 0));

        assertEq(token.balanceOf(UserWallet), 1 ether);
        assertEq(reserveToken.balanceOf(address(token)), 1 ether);
        assertEq(reserveToken.balanceOf(address(token)), calculate_buy_cost(1 ether, 0));
    }
    function test_buy_two_after_ten() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(10 ether, calculate_buy_cost(10 ether, 0));
        vm.stopPrank();
        vm.startPrank(UserWallet2);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(2 ether, calculate_buy_cost(2 ether, 10 ether));
        assertEq(token.balanceOf(UserWallet2), 2 ether);
        assertEq(reserveToken.balanceOf(address(token)), calculate_buy_cost(2 ether, 10 ether) + calculate_buy_cost(10 ether, 0));
    }
    function test_sell() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token), 1000 ether);
        token.buy(1 ether, calculate_buy_cost(1 ether, 0));
        token.sell(1 ether, calculate_sell_cost(1 ether, 1 ether));
        assertEq(token.balanceOf(UserWallet), 0);
        assertEq(reserveToken.balanceOf(address(token)), 0);
    }
    function test_sell_two_after_ten() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token),  UINT256_MAX);
        token.buy(10 ether, calculate_buy_cost(10 ether, 0));
        vm.stopPrank();

        vm.startPrank(UserWallet2);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(2 ether, calculate_buy_cost(2 ether, 10 ether));
        uint256 prevBalance = reserveToken.balanceOf(address(token));
        token.sell(2 ether, calculate_sell_cost(2 ether, 12 ether));
        assertEq(token.balanceOf(UserWallet2), 0);
        assertEq(reserveToken.balanceOf(address(token)), prevBalance - calculate_sell_cost(2 ether, 12 ether));
        vm.stopPrank();

        assertEq(reserveToken.balanceOf(address(token)), 100 ether);
    }
    function test_sell_ten_after_ten() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token), 1000 ether);
        token.buy(10 ether, calculate_buy_cost(10 ether, 0));
        reserveToken.approve(address(token), 1000 ether);
        token.sell(10 ether, calculate_sell_cost(10 ether, 10 ether));
        assertEq(token.balanceOf(UserWallet), 0 ether);
        assertEq(reserveToken.balanceOf(address(token)), 0);
    }


    // test sandwhich attack
    function test_getting_frontrun() public {
        vm.prank(UserWallet);
        reserveToken.approve(address(token), UINT256_MAX);

        // attacker tx goes in first
        vm.startPrank(UserWallet2);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(1 ether, calculate_buy_cost(1 ether, 0));
        vm.stopPrank();

        // victim tx goes in second and gets reverted from front run
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken_MaxCostExceeded.selector));
        vm.startPrank(UserWallet);
        token.buy(10 ether, calculate_buy_cost(10 ether, 0));

    }

    // test frontrun attack on sellside 
    function test_getting_frontrun_on_sell() public {
        vm.startPrank(UserWallet);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(10 ether, calculate_buy_cost(10 ether, 0));
        vm.stopPrank();
        // attacker tx goes in first
        vm.startPrank(UserWallet2);
        reserveToken.approve(address(token), UINT256_MAX);
        token.buy(1 ether, calculate_buy_cost(1 ether, 10 ether));
        token.sell(1 ether, calculate_sell_cost(1 ether, 11 ether));
        vm.stopPrank();

        // victim tx goes in second and gets reverted from front run
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken_MinProceedsExceeded.selector));
        vm.startPrank(UserWallet);
        token.sell(10 ether, calculate_sell_cost(10 ether, 11 ether));
    }

}