pragma circom 2.1.8;

include "../common.circom";

// Be sure to solve IntSqrt before solving this 
// puzzle. Your goal is to compute the square root
// in the provided function, then constrain the answer
// to be true using your work from the previous puzzle.
// You can use the Bablyonian/Heron's or Newton's
// method to compute the integer square root. Remember,
// this is not the modular square root.


function intSqrtFloor(x) {
    var remainder = x;
    var root = 0;
    var bit = 1;

    for (var i = 0; i < 125; i++) {
        bit *= 4;
    }

    for (var i = 0; i < 126; i++) {
        if (remainder >= root + bit) {
            remainder -= root + bit;
            root = (root \ 2) + bit;
        } else {
            root = root \ 2;
        }
        bit = bit \ 4;
    }

    return root;
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
    
    term1 <== out * out;
    term2 <== (out + 1) * (out + 1);

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