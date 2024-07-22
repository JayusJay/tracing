//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Gaussian } from "../src/Gaussian.sol";
import { Math } from "../src/libraries/Math.sol";

import { Test, console2 } from "forge-std/Test.sol";

contract GaussianTest is Test {
    Gaussian public gaussianCdf;

    function setUp() public {
        gaussianCdf = new Gaussian();
    }

    function test_fuzz_calculateGaussianCDF(int256 x, int256 mu, int256 sigma) public view {
        x = bound(x, -1e23, 1e23);
        mu = bound(mu, -1e20, 1e20);
        sigma = bound(sigma, 1, 1e19);
        // require(mu >= -1e20 && mu <= 1e20, "Mu out of range");
        // require(sigma > 0 && sigma <= 1e19, "Sigma out of range");
        // require(x >= -1e23 && x <= 1e23, "x out of range");

        gaussianCdf.gaussianCDF(x, mu, sigma);
    }
}
