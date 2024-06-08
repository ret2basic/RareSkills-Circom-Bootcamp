pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if `numerator`,
// `denominator`, `quotient`, and `remainder` represent
// a valid integer division. You will need a comparison check, so
// we've already imported the library and set n to be 252 bits.
//
// Hint: integer division in Circom is `\`.
// `/` is modular division
// `%` is integer modulus

template IntDiv(n) {
    signal input numerator;
    signal input denominator;
    signal input quotient;
    signal input remainder;

    signal correct_quotient;
    signal correct_remainder;

    // Condition 1: computation is correct
    correct_quotient <-- numerator \ denominator;
    quotient === correct_quotient;

    correct_remainder <-- numerator % denominator;
    remainder === correct_remainder;

    // verify again, just to be safe
    quotient * denominator + remainder === numerator;

    // Condition 2: remainder must be smaller than denominator
    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;
}

component main = IntDiv(252);
