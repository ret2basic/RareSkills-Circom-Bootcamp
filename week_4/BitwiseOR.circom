pragma circom 2.1.6;

template BitwiseOR(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n];

    // For each bit:
    // 0 or 0 = 0
    // 0 or 1 = 1
    // 1 or 0 = 1
    // 1 or 1 = 1
    
    // a + b - ab
    for (var i = 0; i < n; i++) {
        out[i] <== in[0][i] + in[1][i] - in[0][i] * in[1][i];
    }
}

component main = BitwiseOR(4);

/* INPUT = {
    "in": [[1,0,0,1], [1,0,1,0]]
} */