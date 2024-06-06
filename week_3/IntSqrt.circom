pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit that is satisfied if
// in[0] is the floor of the integer
// sqrt of in[1]. For example:
// 
// int[2, 5] accept
// int[2, 5] accept
// int[2, 9] reject
// int[3, 9] accept
//
// If b is the integer square root of a, then
// the following must be true:
//
// (b - 1)(b - 1) < a
// (b + 1)(b + 1) > a
// 
// be careful when verifying that you 
// handle the corner case of overflowing the 
// finite field. You should validate integer
// square roots, not modular square roots

template IntSqrt(n) {
    signal input in[2];

    // Condition 1: if b is sqrt(a), then floor(b) <= a and ceiling(b) > a
    signal term1;
    signal term2;
    
    term1 <-- in[0] * in[0];
    term2 <-- (in[0] + 1) * (in[0] + 1);

    component lessEqThan = LessEqThan(n);
    lessEqThan.in[0] <== term1;
    lessEqThan.in[1] <== in[1];
    lessEqThan.out === 1;

    component greaterThan = GreaterThan(n);
    greaterThan.in[0] <== term2;
    greaterThan.in[1] <== in[1];
    greaterThan.out === 1;

    // Condition 2: overflow check
    component lessThan = LessThan(n);
    lessThan.in[0] <== in[0];
    // Computed in sage: int(sqrt(21888242871839275222246405745257275088548364400416034343698204186575808495617))
    lessThan.in[1] <== 147946756881789319005730692170996259609;
    lessThan.out === 1;
}

component main = IntSqrt(252);