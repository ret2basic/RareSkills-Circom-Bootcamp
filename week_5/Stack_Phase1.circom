pragma circom 2.1.8;

include "../common.circom";

template Stack(maxStackHeight, maxSteps) {
    assert(maxSteps <= maxStackHeight);

    signal input pushValues[maxSteps];
    signal input opcodes[maxSteps];
    signal input index;
    signal input value;

    signal stack[maxSteps + 1][maxStackHeight];
    signal depth[maxSteps + 1];
    signal writeDelta[maxSteps][maxStackHeight];

    component hasRoom[maxSteps];
    component isWriteSlot[maxSteps * maxStackHeight];

    depth[0] <== 0;
    for (var j = 0; j < maxStackHeight; j++) {
        stack[0][j] <== 0;
    }

    for (var i = 0; i < maxSteps; i++) {
        opcodes[i] === 1;

        hasRoom[i] = LessThan(252);
        hasRoom[i].in[0] <== depth[i];
        hasRoom[i].in[1] <== maxStackHeight;
        hasRoom[i].out === 1;

        depth[i + 1] <== depth[i] + 1;

        for (var j = 0; j < maxStackHeight; j++) {
            isWriteSlot[i * maxStackHeight + j] = IsEqual();
            isWriteSlot[i * maxStackHeight + j].in[0] <== depth[i];
            isWriteSlot[i * maxStackHeight + j].in[1] <== j;

            writeDelta[i][j] <== isWriteSlot[i * maxStackHeight + j].out * (pushValues[i] - stack[i][j]);
            stack[i + 1][j] <== stack[i][j] + writeDelta[i][j];
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
    "pushValues": [3, 5, 7, 11],
    "opcodes": [1, 1, 1, 1],
    "index": "2",
    "value": "7"
} */