pragma circom 2.1.8;
include "../node_modules/circomlib/circuits/comparators.circom";

// Write a circuit that constrains the 4 input signals to be
// sorted. Sorted means the values are non decreasing starting
// at index 0. The circuit should not have an output.

template IsSorted() {
    signal input in[4];

    component lessEqThan[3];
    component isEqual[3];

    for (var i = 0; i < 3; i++) {
        lessEqThan[i] = LessEqThan(252);
        isEqual[i] = IsEqual();

        lessEqThan[i].in[0] <== in[i];
        lessEqThan[i].in[1] <== in[i+1];
        isEqual[i].in[0] <== lessEqThan[i].out;
        isEqual[i].in[1] <== 1;
        isEqual[i].out === 1;
    }
}

component main = IsSorted();

/* INPUT = {"in": [1,2,3,4]} */
