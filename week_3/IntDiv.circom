pragma circom 2.1.8;

include "../common.circom";

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

    component denominatorIsPositive = LessThan(n);
    denominatorIsPositive.in[0] <== 0;
    denominatorIsPositive.in[1] <== denominator;
    denominatorIsPositive.out === 1;

    component lessThan = LessThan(n);
    lessThan.in[0] <== remainder;
    lessThan.in[1] <== denominator;
    lessThan.out === 1;

    component productCheck = LongMulAddEq(n);
    productCheck.a <== quotient;
    productCheck.b <== denominator;
    productCheck.c <== remainder;
    productCheck.d <== numerator;
}

component main = IntDiv(252);
