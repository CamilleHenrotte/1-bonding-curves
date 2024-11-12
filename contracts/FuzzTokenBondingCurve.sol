// SPDX-License-Identifier: MIT
pragma solidity =0.8.28;

import "./TokenBondingCurve.sol";

contract FuzzTokenBondingCurve is TokenBondingCurve{
    constructor()TokenBondingCurve("token", "TK", 10){

    }
    function bonding_curve_is_reversible(uint256 ethAmountIn)public view {
        uint256 tokenAmount = getMintedTokenAmountEquivalentToETHAmount( ethAmountIn);
        uint256 ethAmountOut = getEthAmountEquivalentToBurnedTokenAmount(tokenAmount);
        assert(ethAmountIn==ethAmountOut);

    }
     function bonding_curve_is_reversible2(uint256 tokenAmountIn)public view {
        uint256 ethAmount = getEthAmountEquivalentToBurnedTokenAmount(tokenAmountIn);
        uint256 tokenAmountOut = getMintedTokenAmountEquivalentToETHAmount( ethAmount);
        assert(tokenAmountIn==tokenAmountOut);

    }
}