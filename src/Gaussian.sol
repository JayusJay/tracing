//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


contract Gaussian {
    int256 internal constant ONE = 1e18; // 18 decimal fixed-point representation of 1
    int256 internal constant HALF = 5e17; // 18 decimal fixed-point representation of 0.5
    int256 internal constant TWO = 2e18; // 18 decimal fixed-point representation of 2
    int256 internal constant SQRT_TWO = 1414213562373095049; // sqrt(2) in fixed-point 18 decimal
    int48 internal constant E12 = 1e12;

    // Polynomial approximation constants
    int256 internal constant c1 = 1000023680000000000;
    int256 internal constant c2 = 374091960000000000;
    int256 internal constant c3 = 96784180000000000;
    int256 internal constant c4 = -186288060000000000;
    int256 internal constant c5 = 278868070000000000;
    int256 internal constant c6 = -1135203980000000000;
    int256 internal constant c7 = 1488515870000000000;
    int256 internal constant c8 = -822152230000000000;
    int256 internal constant c9 = 170872770000000000;
    int256 internal constant expConst = -1265512230000000000;
    int256 internal constant TWELFTH = 83333333333333333;


     // Function to calculate the Gaussian CDF for fixed-point x, mu, sigma
     /**
     CDF formula: 0.5 * (1 + erf((x - mu) / (sigma * sqrt(2))))     

     x = mean
     mu = variance
     sigma = SD
      */
    function gaussianCDF(int256 x, int256 mu, int256 sigma) public pure returns (int256, int256) {
        int256 z = ((x - mu) * ONE) / (sigma * SQRT_TWO);
        int256 erfValue = erf(z);
        int256 erfcValue = erfc(z);
        return (((erfValue + ONE) / TWO), erfcValue / 2 );
    }

    // Function to calculate e^(-x^2/2) for fixed-point x
     function expNegHalf(int256 x) internal pure returns (int256) {
        int256 xx = (x * x) / ONE;  // x^2 / 1e18
        int256 x4 = (xx * xx) / ONE; // x^4 / 1e36

        ///@notice using Padé 2 / 2 over polynomial series to avoid looping
        ///chosing 2 / 2 over 1 / 1 for better accuracy

        // Compute numerator and denominator for the [2/2] Padé approximant
        int256 numerator = ONE - (xx / 2) + (x4 / 24);
        int256 denominator = ONE + (xx / 2) + (x4 / 24);

        // Return the result of the Padé approximant
        return numerator / denominator;
    }

    /**
     var r = t * Math.exp(-z * z - 1.26551223 + t * (1.00002368 +
            t * (0.37409196 + t * (0.09678418 + t * (-0.18628806 +
            t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 +
            t * (-0.82215223 + t * 0.17087277))))))))) */

        // Complementary error function approximation
    function erfc(int256 x) public pure returns (int256) {
        int256 z = x >= 0 ? x : -x;
        int256 t = (ONE * ONE) / (ONE + ((z * ONE) / 2 ));
       
        int256 expTerm = -z * z / ONE - 1265512230000000000;

        int256 polynomial = c1;
        polynomial = addSafe(polynomial, mulDiv(t, c2));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, c3)));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, c4))));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, c5)))));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, c6))))));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, c7)))))));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, c8))))))));
        polynomial = addSafe(polynomial, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, mulDiv(t, c9)))))))));
        int256 r = t * exp(expTerm + polynomial / ONE);

         return x >= 0 ? r : TWO - r;
    }

    // Function to calculate the error function approximation for fixed-point x
    function erf(int256 x) internal pure returns (int256) {
        int256 sign;
        if(x < 0){
            sign = -ONE;
            x = -x;
        }else{
            sign = ONE;
        }

        // Polynomial approximation constants (maximum error: 1.5×10−7)
        ///@notice used polynomial appox. constants because it would be much more expensive if trying to calculate integrals
        int256 a1 = 254829592 * 1e9;
        int256 a2 = -284496736 * 1e9;
        int256 a3 = 142141374 * 1e9;
        int256 a4 = -106122205 * 1e9;
        int256 a5 = 102112745 * 1e9;
        int256 p = 3275911 * 1e9;

        int256 t = ONE / (ONE + (p * x) / ONE);
        int256 y = (((((a5 * t) / ONE + a4) * t) / ONE + a3) * t) / ONE + a2;
        y = ((y * t) / ONE + a1) * t;
        y = (ONE - y) * expNegHalf(x);
        return sign * y;
    }

    function exp(int256 x) internal pure returns (int256) {
        int256 x2 = (x * x) / ONE;
        int256 numerator = ONE + (x / TWO) + (x2 / TWELFTH);
        int256 denominator = ONE - (x / TWO) + (x2 / TWELFTH);
        return (numerator * ONE) / denominator;
    }
   
   function addSafe(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
       // require(c >= a, "Addition overflow");
        return c;
    }

    function mulDiv(int256 a, int256 b) internal pure returns (int256) {
        return (a * b) / ONE;
    }
}