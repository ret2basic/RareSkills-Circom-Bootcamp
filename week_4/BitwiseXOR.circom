pragma circom 2.1.6;

include "../common.circom";

template BitwiseXOR(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n];

    // For each bit:
    // 0 xor 0 = 0
    // 0 xor 1 = 1
    // 1 xor 0 = 1
    // 1 xor 1 = 0
    
    // a + b - 2ab
    component inputBits[2][n];
    component outputBits[n];

    for (var i = 0; i < n; i++) {
        inputBits[0][i] = AssertBinary();
        inputBits[1][i] = AssertBinary();
        outputBits[i] = AssertBinary();

        inputBits[0][i].in <== in[0][i];
        inputBits[1][i].in <== in[1][i];
        out[i] <== in[0][i] + in[1][i] - 2 * in[0][i] * in[1][i];
        outputBits[i].in <== out[i];
    }
    
}

component main = BitwiseXOR(4);

/* INPUT = {
    "in": [[0,0,0,1], [1,0,1,0]]
} */