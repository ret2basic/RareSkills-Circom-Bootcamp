pragma circom 2.1.6;

template BitwiseAdd(n) {
	signal input in[2][n]; // 2 n-bit inputs
	signal output out[n]; // addition of the inputs with overflow

    // For each bit:
    // 0 + 0 = 0, carry_bit = 0
    // 0 + 1 = 1, carry_bit = 0
    // 1 + 0 = 1, carry_bit = 0
    // 1 + 1 = 0, carry_bit = 1
    //    XOR         AND

    // a + b, throw away MSB
    signal temp_result[n+1];

    var carry_bit = 0;
    for (var i = 0; i < n; i++) {
        // addition of two inputs -> XOR
        temp_result[i] <== in[0][i] + in[1][i] - 2 * in[0][i] * in[1][i];
        // addition with carry_bit -> XOR
        out[i] <-- temp_result[i] + carry_bit - 2 * temp_result[i] * carry_bit;
        out[i] * (out[i] - 1) === 0;
        // update carry_bit for next iteration
        carry_bit = in[0][i] & in[1][i];
    }

}

component main = BitwiseAdd(4);

/* INPUT = {
    "in": [[1,0,0,1], [1,0,1,1]]
} */