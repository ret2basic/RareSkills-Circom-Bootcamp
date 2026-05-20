pragma circom 2.1.8;

include "../common.circom";

// Use the same constraints from IntDiv, but this
// time assign the quotient in `out`. You still need
// to apply the same constraints as IntDiv

template IntDivOut(n) {
    signal input numerator;
    signal input denominator;
    signal output out;

    signal remainder;

    out <-- numerator \ denominator;
    remainder <-- numerator % denominator;

    component denominatorIsPositive = LessThan(n);
    denominatorIsPositive.in[0] <== 0;
    denominatorIsPositive.in[1] <== denominator;
    denominatorIsPositive.out === 1;

    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;

    component productCheck = LongMulAddEq(n);
    productCheck.a <== out;
    productCheck.b <== denominator;
    productCheck.c <== remainder;
    productCheck.d <== numerator;
}

component main = IntDivOut(252);
