pragma circom 2.1.8;

// Create a circuit that takes an array of signals `in[n]` and
// a signal k. The circuit should return 1 if `k` is in the list
// and 0 otherwise. This circuit should work for an arbitrary
// length of `in`.

template HasAtLeastOne(n) {
    signal input in[n];
    signal input k;
    signal output out;

    signal temp1;
    signal temp2;
    signal temp3;
    signal temp4;
    signal result;

    temp1 <== (in[0] - k) * (in[1] - k);
    temp2 <== (in[1] - k) * (in[2] - k);
    temp3 <== (in[2] - k) * (in[3] - k);
    temp4 <== temp1 * temp2;
    result <== temp4 * temp3;
    out <-- result != 0 ? 0 : 1;

    out * (out - 1) === 0;
}

component main = HasAtLeastOne(4);

/* INPUT = {"in": [1,2,3,4], "k": 2} */
