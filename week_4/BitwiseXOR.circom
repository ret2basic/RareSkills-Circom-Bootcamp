pragma circom 2.1.6;

template BitwiseXOR(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n];

    // For each bit:
    // 0 xor 0 = 0
    // 0 xor 1 = 1
    // 1 xor 0 = 1
    // 1 xor 1 = 0
    
    // a + b - 2ab
    for (var i = 0; i < n; i++) {
        out[i] <== in[0][i] + in[1][i] - 2 * in[0][i] * in[1][i];
    }
    
}

component main = BitwiseXOR(4);

/* INPUT = {
    "in": [[0,0,0,1], [1,0,1,0]]
} */