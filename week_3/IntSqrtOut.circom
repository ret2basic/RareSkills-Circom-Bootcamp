pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Be sure to solve IntSqrt before solving this 
// puzzle. Your goal is to compute the square root
// in the provided function, then constrain the answer
// to be true using your work from the previous puzzle.
// You can use the Bablyonian/Heron's or Newton's
// method to compute the integer square root. Remember,
// this is not the modular square root.


function intSqrtFloor(x) {
    // compute the floor of the
    // integer square root

    // Base case
    if (x == 0 || x == 1) {
        return x;
    }

    // Do it the stupid way
    // Starting from 1, try all numbers until
    // i*i is greater than or equal to x.
    var i = 1;
    var result = 1;
    while (result <= x) {
        i += 1;
        result = i * i;
    }

    return i - 1;
}

template IntSqrtOut(n) {
    signal input in;
    signal output out;

    out <-- intSqrtFloor(in);
    // constrain out using your
    // work from IntSqrt

    // Condition 1: if b is sqrt(a), then floor(b) <= a and ceiling(b) > a
    signal term1;
    signal term2;
    
    term1 <-- out * out;
    term2 <-- (out + 1) * (out + 1);

    component lessEqThan = LessEqThan(n);
    lessEqThan.in[0] <== term1;
    lessEqThan.in[1] <== in;
    lessEqThan.out === 1;

    component greaterThan = GreaterThan(n);
    greaterThan.in[0] <== term2;
    greaterThan.in[1] <== in;
    greaterThan.out === 1;

    // Condition 2: overflow check
    component lessThan = LessThan(n);
    lessThan.in[0] <== out;
    // Computed in sage: int(sqrt(21888242871839275222246405745257275088548364400416034343698204186575808495617))
    lessThan.in[1] <== 147946756881789319005730692170996259609;
    lessThan.out === 1;
}

component main = IntSqrtOut(252);