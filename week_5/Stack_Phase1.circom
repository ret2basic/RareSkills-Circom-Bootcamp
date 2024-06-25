pragma circom 2.1.6;

include "circomlib/multiplexer.circom";
include "circomlib/comparators.circom";

template Stack(maxStackHeight, maxSteps) {
    signal input pushValues[maxSteps];
    signal input opcodes[maxSteps]; // push = 1, pop = -1, nop = 0
    signal input index;
    signal input value;

    var stack[maxStackHeight];
    // stack pointer
    // let stack pointer start from -1 to avoid handling i = 0 special case
    var sp = -1;
    // program counter
    var pc = 0;

    // opcodes must be 1, -1 or 0
    signal tempProduct[maxSteps];
    for (var i = 0; i < maxSteps; i++) {
        tempProduct[i] <== (opcodes[i] - 1) * (opcodes[i] + 1);
        tempProduct[i] * opcodes[i] === 0;
    }

    var opcode;
    var pushValue;

    // parse each opcode
    for (var i = 0; i < maxSteps; i++) {
        opcode = opcodes[pc];
        
        if (opcode == 1) {
            // PUSH
            // stack pointer can't exceed stack size limit
            if(sp + 1 < maxStackHeight) {
                pushValue = pushValues[pc];
                sp += 1;
                stack[sp] = pushValue;
                pc += 1;
            }
        }
    }

    component multiplexer = Multiplexer(1, maxStackHeight);
    for(var i = 0; i < maxStackHeight; i++) {
        multiplexer.inp[i] <-- [stack[i]];
    }
    multiplexer.sel <== index;

    // Check if the value is correct
    value === multiplexer.out[0];
}

component main = Stack(4, 4);

/* INPUT = {
    "pushValues": [3, 5, 7, 11],
    "opcodes": [1, 1, 1, 1],
    "index": "2",
    "value": "7"
} */