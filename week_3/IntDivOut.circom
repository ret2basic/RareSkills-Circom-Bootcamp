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
    out <-- quotient;

    out * denominator + remainder === numerator;

    // Condition 2: remainder must be smaller than denominator
    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;

    // Condition 3: quotient and remainder must be greater than or equal to 0
    component greaterEqThan1 = GreaterEqThan(n);
    greaterEqThan1.in[0] <== quotient;
    greaterEqThan1.in[1] <== 0;
    greaterEqThan1.out === 1;

    component greaterEqThan2 = GreaterEqThan(n);
    greaterEqThan2.in[0] <== remainder;
    greaterEqThan2.in[1] <== 0;
    greaterEqThan2.out === 1;
}

component main = IntDivOut(252);
