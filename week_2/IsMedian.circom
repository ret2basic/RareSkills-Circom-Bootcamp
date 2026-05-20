pragma circom 2.1.8;

include "../common.circom";

// Create a circuit that takes private input of 5 variables as an array and a public input k.
// Your goal is to prove that k is the median of the list without showing the list.
// That means, you prove the list is sorted (use exercise 1), and that the middle signal equals k.
// Deploy and verify this as a smart contract on whatever chain you prefer and show a transaction that it works.

template IsSorted() {
    signal input in[5];

    component lessEqThan[4];

    for (var i = 0; i < 4; i++) {
        lessEqThan[i] = LessEqThan(252);
        lessEqThan[i].in[0] <== in[i];
        lessEqThan[i].in[1] <== in[i+1];
        lessEqThan[i].out === 1;
    }
}

template IsMedian() {
    signal input in[5];
    signal input k;

    component isSorted = IsSorted();
    for (var i = 0; i < 5; i++) {
        isSorted.in[i] <== in[i];
    }

    in[2] === k;

}

component main {public [k]} = IsMedian();

/* INPUT = { "in": [1,2,3,4,5], "k": 3 } */