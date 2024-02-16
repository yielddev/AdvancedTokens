// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {BondingCurveToken} from "../src/BondingCurveToken.sol";
import {GodToken} from "../src/GodToken.sol";
contract SetupContract {
    address echidna = msg.sender;
    BondingCurveToken public instance;
    GodToken public reserveToken;

    constructor () {
        reserveToken = new GodToken(address(this));
        instance = new BondingCurveToken("Pumping MEME", "PMEME", address(reserveToken));
        reserveToken.mint(address(echidna), 100000 ether);
        reserveToken.mint(address(this), 100000 ether);
        reserveToken.approve(address(instance), 100000 ether);
        instance.buy(1 ether, 100 ether);

    }

    function echidna_test_balance() public view returns (bool) {
        return instance.getInstantPrice() != 0;
    } 

}