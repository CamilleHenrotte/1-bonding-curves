// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MathUtils {
    /**
     * @dev Computes the square root of a given number using the Babylonian method.
     * @param x The number to compute the square root of.
     * @return The integer square root of the number.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }

        // Initial guess
        uint256 z = (x + 1) / 2;
        uint256 y = x;

        // Babylonian method loop
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        return y;
    }
}
