pragma circom 2.1.8;

include "../common.circom";

// Create a circuit that takes an array of signals `in[n]` and
// a signal k. The circuit should return 1 if `k` is in the list
// and 0 otherwise. This circuit should work for an arbitrary
// length of `in`.

template HasAtLeastOne(n) {
    assert(n > 0);

    signal input in[n];
    signal input k;
    signal output out;

    signal products[n + 1];

    products[0] <== 1;
    for (var i = 0; i < n; i++) {
        products[i + 1] <== products[i] * (in[i] - k);
    }

    component isZero = IsZero();
    isZero.in <== products[n];
    out <== isZero.out;
}

component main = HasAtLeastOne(4);

/* INPUT = {"in": [1,2,3,4], "k": 2} */
