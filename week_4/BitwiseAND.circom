pragma circom 2.1.6;

template BitwiseAND(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n];

    // For each bit:
    // 0 and 0 = 0
    // 0 and 1 = 0
    // 1 and 0 = 0
    // 1 and 1 = 1
    
    // a * b
    for (var i = 0; i < n; i++) {
        out[i] <== in[0][i] * in[1][i];
    }
}

component main = BitwiseAND(4);

/* INPUT = {
    "in": [[1,0,0,1], [1,0,1,0]]
} */