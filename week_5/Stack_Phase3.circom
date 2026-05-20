pragma circom 2.1.8;

include "../common.circom";

template Stack(maxStackHeight, maxSteps) {
    signal input pushValues[maxSteps];
    signal input opcodes[maxSteps]; // push = 1, pop = -1, nop = 0
    signal input index;
    signal input value;

    signal stack[maxSteps + 1][maxStackHeight];
    signal depth[maxSteps + 1];
    signal tempProduct[maxSteps];
    signal isPush[maxSteps];
    signal isPop[maxSteps];
    signal isNop[maxSteps];
    signal pushFlag[maxSteps][maxStackHeight];
    signal popFlag[maxSteps][maxStackHeight];
    signal pushDelta[maxSteps][maxStackHeight];
    signal popDelta[maxSteps][maxStackHeight];

    component pushBit[maxSteps];
    component popBit[maxSteps];
    component nopBit[maxSteps];
    component hasRoom[maxSteps];
    component hasItem[maxSteps];
    component isPushSlot[maxSteps * maxStackHeight];
    component isPopSlot[maxSteps * maxStackHeight];

    depth[0] <== 0;
    for (var j = 0; j < maxStackHeight; j++) {
        stack[0][j] <== 0;
    }

    for (var i = 0; i < maxSteps; i++) {
        tempProduct[i] <== (opcodes[i] - 1) * (opcodes[i] + 1);
        tempProduct[i] * opcodes[i] === 0;

        isPush[i] <== opcodes[i] * (opcodes[i] + 1) / 2;
        isPop[i] <== opcodes[i] * (opcodes[i] - 1) / 2;
        isNop[i] <== 1 - opcodes[i] * opcodes[i];
        isPush[i] + isPop[i] + isNop[i] === 1;

        pushBit[i] = AssertBinary();
        popBit[i] = AssertBinary();
        nopBit[i] = AssertBinary();
        pushBit[i].in <== isPush[i];
        popBit[i].in <== isPop[i];
        nopBit[i].in <== isNop[i];

        hasRoom[i] = LessThan(252);
        hasRoom[i].in[0] <== depth[i];
        hasRoom[i].in[1] <== maxStackHeight;
        isPush[i] * (hasRoom[i].out - 1) === 0;

        hasItem[i] = LessThan(252);
        hasItem[i].in[0] <== 0;
        hasItem[i].in[1] <== depth[i];
        isPop[i] * (hasItem[i].out - 1) === 0;

        depth[i + 1] <== depth[i] + isPush[i] - isPop[i];

        for (var j = 0; j < maxStackHeight; j++) {
            isPushSlot[i * maxStackHeight + j] = IsEqual();
            isPushSlot[i * maxStackHeight + j].in[0] <== depth[i];
            isPushSlot[i * maxStackHeight + j].in[1] <== j;

            isPopSlot[i * maxStackHeight + j] = IsEqual();
            isPopSlot[i * maxStackHeight + j].in[0] <== depth[i];
            isPopSlot[i * maxStackHeight + j].in[1] <== j + 1;

            pushFlag[i][j] <== isPush[i] * isPushSlot[i * maxStackHeight + j].out;
            popFlag[i][j] <== isPop[i] * isPopSlot[i * maxStackHeight + j].out;
            pushDelta[i][j] <== pushFlag[i][j] * (pushValues[i] - stack[i][j]);
            popDelta[i][j] <== popFlag[i][j] * (0 - stack[i][j]);
            stack[i + 1][j] <== stack[i][j] + pushDelta[i][j] + popDelta[i][j];
        }
    }

    component indexInDepth = LessThan(252);
    indexInDepth.in[0] <== index;
    indexInDepth.in[1] <== depth[maxSteps];
    indexInDepth.out === 1;

    component selector = Select(maxStackHeight);
    for (var j = 0; j < maxStackHeight; j++) {
        selector.values[j] <== stack[maxSteps][j];
    }
    selector.index <== index;
    value === selector.out;
}

component main = Stack(4, 4);

/* INPUT = {
    "pushValues": [3, 5, 0, 0],
    "opcodes": [1, 1, -1, 0],
    "index": "0",
    "value": "3"
} */