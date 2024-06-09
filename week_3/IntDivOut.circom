pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Use the same constraints from IntDiv, but this
// time assign the quotient in `out`. You still need
// to apply the same constraints as IntDiv

template IntDivOut(n) {
    signal input numerator;
    signal input denominator;
    signal output out;

    signal quotient;
    signal remainder;

    // Condition 1: computation is correct
    quotient <-- numerator \ denominator;
    remainder <-- numerator % denominator;
    quotient * denominator + remainder === numerator;

    // Condition 2: remainder must be smaller than denominator
    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;

    // Assign output
    out <== quotient;
}

component main = IntDivOut(252);
