// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "./TokenBondingCurve.sol";

contract FuzzTokenBondingCurve is TokenBondingCurve {
    event BondingCurveIsReversible(uint256 ethAmountIn, uint256 ethAmountOut, uint256 tokenAmount);
    event BondingCurveIsReversible2(uint256 tokenAmountIn, uint256 tokenAmountOut, uint256 ethAmount);
    constructor() TokenBondingCurve("token", "TK", 10) {}
    function bonding_curve_is_reversible(uint256 ethAmountIn) public {
        uint256 minValue = 0.0001 ether;
        uint256 maxValue = 10000 ether;
        ethAmountIn = minValue + (ethAmountIn % (maxValue - minValue + 1));
        uint256 tokenAmount = getMintedTokenAmountEquivalentToETHAmount(ethAmountIn);
        uint256 ethAmountOut = getEthAmountEquivalentToBurnedTokenAmount(tokenAmount);
        emit BondingCurveIsReversible(ethAmountIn, ethAmountOut, tokenAmount);
        assert(ethAmountIn == ethAmountOut);
    }
    function bonding_curve_is_reversible2(uint256 tokenAmountIn) public {
        uint256 minValue = 0.0001 ether;
        uint256 maxValue = 10000 ether;
        tokenAmountIn = minValue + (tokenAmountIn % (maxValue - minValue + 1));
        uint256 ethAmount = getEthAmountEquivalentToBurnedTokenAmount(tokenAmountIn);
        uint256 tokenAmountOut = getMintedTokenAmountEquivalentToETHAmount(ethAmount);
        emit BondingCurveIsReversible2(tokenAmountIn, tokenAmountOut, ethAmount);
        assert(tokenAmountIn == tokenAmountOut);
    }
}
