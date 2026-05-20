pragma circom 2.1.8;

function ceilLog2(n) {
    var bits = 0;
    var value = 1;
    while (value < n) {
        value *= 2;
        bits += 1;
    }
    return bits;
}

template AssertBinary() {
    signal input in;
    in * (in - 1) === 0;
}

template Num2Bits(n) {
    assert(n < 254);

    signal input in;
    signal output out[n];

    var lc = 0;
    var e2 = 1;
    for (var i = 0; i < n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] - 1) === 0;
        lc += out[i] * e2;
        e2 *= 2;
    }

    lc === in;
}

template RangeCheck(n) {
    signal input in;

    component bits = Num2Bits(n);
    bits.in <== in;
}

template IsZero() {
    signal input in;
    signal output out;

    signal inv;
    inv <-- in != 0 ? 1 / in : 0;
    out <== 1 - in * inv;
    in * out === 0;
}

template IsEqual() {
    signal input in[2];
    signal output out;

    component isZero = IsZero();
    isZero.in <== in[0] - in[1];
    out <== isZero.out;
}

template LessThan(n) {
    assert(n <= 252);

    signal input in[2];
    signal output out;

    component leftBits = Num2Bits(n);
    component rightBits = Num2Bits(n);
    component diffBits = Num2Bits(n + 1);

    leftBits.in <== in[0];
    rightBits.in <== in[1];
    diffBits.in <== in[0] + (1 << n) - in[1];
    out <== 1 - diffBits.out[n];
}

template LessEqThan(n) {
    signal input in[2];
    signal output out;

    component greater = LessThan(n);
    greater.in[0] <== in[1];
    greater.in[1] <== in[0];
    out <== 1 - greater.out;
}

template GreaterThan(n) {
    signal input in[2];
    signal output out;

    component less = LessThan(n);
    less.in[0] <== in[1];
    less.in[1] <== in[0];
    out <== less.out;
}

template GreaterEqThan(n) {
    signal input in[2];
    signal output out;

    component lessEq = LessEqThan(n);
    lessEq.in[0] <== in[1];
    lessEq.in[1] <== in[0];
    out <== lessEq.out;
}

template Select(n) {
    signal input values[n];
    signal input index;
    signal output out;

    component indexRange = LessThan(252);
    indexRange.in[0] <== index;
    indexRange.in[1] <== n;
    indexRange.out === 1;

    component isIndex[n];
    signal selected[n];
    signal sum[n + 1];

    sum[0] <== 0;
    for (var i = 0; i < n; i++) {
        isIndex[i] = IsEqual();
        isIndex[i].in[0] <== index;
        isIndex[i].in[1] <== i;
        selected[i] <== isIndex[i].out * values[i];
        sum[i + 1] <== sum[i] + selected[i];
    }

    out <== sum[n];
}

template LongMulAddEq(n) {
    signal input a;
    signal input b;
    signal input c;
    signal input d;

    component aBits = Num2Bits(n);
    component bBits = Num2Bits(n);
    component cBits = Num2Bits(n);
    component dBits = Num2Bits(n);

    aBits.in <== a;
    bBits.in <== b;
    cBits.in <== c;
    dBits.in <== d;

    signal partial[n][n];
    for (var i = 0; i < n; i++) {
        for (var j = 0; j < n; j++) {
            partial[i][j] <== aBits.out[i] * bBits.out[j];
        }
    }

    var carryBits = ceilLog2(n + 2) + 1;
    signal carry[2 * n + 1];
    component carryRange[2 * n + 1];

    carry[0] <== 0;
    for (var k = 0; k < 2 * n; k++) {
        carryRange[k] = Num2Bits(carryBits);
        carryRange[k].in <== carry[k];

        var column = carry[k];
        if (k < n) {
            column += cBits.out[k] - dBits.out[k];
        }

        for (var i = 0; i < n; i++) {
            if (k >= i && k - i < n) {
                column += partial[i][k - i];
            }
        }

        carry[k + 1] <== column / 2;
    }

    carryRange[2 * n] = Num2Bits(carryBits);
    carryRange[2 * n].in <== carry[2 * n];
    carry[2 * n] === 0;
}
