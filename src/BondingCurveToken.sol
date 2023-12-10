// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts@v5.0.0/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts@v5.0.0/access/Ownable.sol";
import {Math} from "@openzeppelin/contracts@v5.0.0/utils/math/Math.sol";


error BondingCurveToken_ZeroAmountInvalid();
error BondingCurveToken_ReserveTokenPaymentFailed();
error BondingCurveToken_MaxCostExceeded();
error BondingCurveToken_MinProceedsExceeded();
/// @title Bonding Curve Token
/// @author YieldDev
/// @notice Implements a bonding curve sale for a token with a curve of y = 2x

contract BondingCurveToken is ERC20 {
    using Math for uint256;
    address public reserveToken;
    uint256 constant public SLOPE = 2;

    constructor(
        string memory name_,
        string memory symbol_,
        address _reserveToken
    ) ERC20(name_, symbol_) {
        reserveToken = _reserveToken;
    }

    /// @dev buy tokens from the bonding curve
    /// @param amount amount of tokens to buy
    function buy(uint256 amount, uint256 maxCost) public {
        if(amount == 0) revert BondingCurveToken_ZeroAmountInvalid();
        uint256 cost = getBuyCost(amount);
        if(cost > maxCost) revert BondingCurveToken_MaxCostExceeded();
        // potentially unnecessary check
        if(
            IERC20(reserveToken).allowance(_msgSender(), address(this)) < cost || 
            !IERC20(reserveToken).transferFrom(_msgSender(), address(this), cost)
        ) {
            revert BondingCurveToken_ReserveTokenPaymentFailed();
        }
        _mint(_msgSender(), amount);

    }
    /// @dev sell tokens to the bonding curve
    /// @param amount amount of tokens to sell
    function sell(uint256 amount, uint256 minProceeds) public {
        if(amount == 0) revert BondingCurveToken_ZeroAmountInvalid();
        uint256 proceeds = getSellPrice(amount);
        if(proceeds < minProceeds) revert BondingCurveToken_MinProceedsExceeded();
        _burn(_msgSender(), amount);
        require(IERC20(reserveToken).transfer(_msgSender(), proceeds));
    }
    /// @dev get the current instantaneous price to buy tokens
    /// @return price to buy 1 token
    function getInstantPrice() external view returns (uint256) {
        return SLOPE * totalSupply(); 
    }
    /// @dev get the cost to buy a certain amount of tokens
    /// @param amount amount of tokens to buy
    function getBuyCost(uint256 amount) private view returns (uint256) {
        return ( (amount * SLOPE) * ( totalSupply() + ( amount/ 2) ) ) / 1 ether;
    }
    /// @dev get the proceeds from selling a certain amount of tokens
    /// @param amount amount of tokens to sell
    function getSellPrice(uint256 amount) private view returns (uint256) {
        return ( (amount * SLOPE) * ( totalSupply() - (amount / 2) ) ) / 1 ether;
    }

}