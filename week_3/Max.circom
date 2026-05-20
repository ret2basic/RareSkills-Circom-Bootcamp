pragma circom 2.1.6;

include "../common.circom";

template Max(n) {
  assert(n > 0);

  signal input in[n];
  signal output out;

  signal runningMax[n];
  signal selectedDiff[n - 1];
  component firstRange = RangeCheck(252);
  component greaterThan[n - 1];

  firstRange.in <== in[0];
  runningMax[0] <== in[0];

  for (var i = 1; i < n; i++) {
      greaterThan[i - 1] = GreaterThan(252);
      greaterThan[i - 1].in[0] <== in[i];
      greaterThan[i - 1].in[1] <== runningMax[i - 1];

      selectedDiff[i - 1] <== greaterThan[i - 1].out * (in[i] - runningMax[i - 1]);
      runningMax[i] <== runningMax[i - 1] + selectedDiff[i - 1];
  }

  out <== runningMax[n - 1];
 
}

component main = Max(6);

/* INPUT = {
    "in": ["0", "1", "3", "55", "8", "16"]
} */