pragma circom 2.1.6;

include "../common.circom";

template BitwiseAdd(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n]; // addition of the inputs with overflow

    // For each bit:
    // 0 + 0 = 0, carry_bit = 0
    // 0 + 1 = 1, carry_bit = 0
    // 1 + 0 = 1, carry_bit = 0
    // 1 + 1 = 0, carry_bit = 1
    //    XOR         AND

    signal xorAB[n];
    signal andAB[n];
    signal carryAndXor[n];
    signal carry[n + 1];
    component inputBits[2][n];
    component outputBits[n];
    component carryBits[n + 1];

    carry[0] <== 0;
    carryBits[0] = AssertBinary();
    carryBits[0].in <== carry[0];

    for (var i = 0; i < n; i++) {
        inputBits[0][i] = AssertBinary();
        inputBits[1][i] = AssertBinary();
        outputBits[i] = AssertBinary();
        carryBits[i + 1] = AssertBinary();

        inputBits[0][i].in <== in[0][i];
        inputBits[1][i].in <== in[1][i];

        xorAB[i] <== in[0][i] + in[1][i] - 2 * in[0][i] * in[1][i];
        andAB[i] <== in[0][i] * in[1][i];
        carryAndXor[i] <== carry[i] * xorAB[i];
        out[i] <== xorAB[i] + carry[i] - 2 * xorAB[i] * carry[i];
        carry[i + 1] <== andAB[i] + carryAndXor[i];

        outputBits[i].in <== out[i];
        carryBits[i + 1].in <== carry[i + 1];
    }

}

component main = BitwiseAdd(4);

/* INPUT = {
    "in": [[1,0,0,1], [1,0,1,1]]
} */