pragma circom 2.1.6;

include "circomlib/comparators.circom";

template HasAtLeastOne(n) {
    signal input in[n];
    signal input k;
    signal output out;

    signal temp1;
    signal temp2;
    signal temp3;
    signal temp4;
    signal result;

    // just works for array of length 6 for now
    temp1 <== (in[0] - k) * (in[1] - k);
    temp2 <== (in[2] - k) * (in[3] - k);
    temp3 <== (in[4] - k) * (in[5] - k);
    temp4 <== temp1 * temp2;
    result <== temp4 * temp3;
    out <-- result != 0 ? 0 : 1;
    // (out=1, result=0) or (out=0,result!=0)
    out * result === 0;
    out * (out - 1) === 0;
}

template Max(n) {

  signal input in[n];
  signal output out;

  var currentMax = 0;
  for (var i = 0; i < n; i++) {
      if (in[i] > currentMax) {
          currentMax = in[i];
      }
  }

  out <-- currentMax;

  // it is true that out >= in[0] and out >= in[1] and out >= in[2]...
  component greaterEqThan[n];
  for (var i = 0; i < n; i++) {
      greaterEqThan[i] = GreaterEqThan(252);
      greaterEqThan[i].in[0] <== out;
      greaterEqThan[i].in[1] <== in[i];
      greaterEqThan[i].out === 1;
  }

  // is is true that out === in[0] or out === in[1] or out === in[2]...
  component hasAtLeastOne = HasAtLeastOne(n);
  for (var i = 0; i < n; i++) {
      hasAtLeastOne.in[i] <== in[i];
  }
  
  hasAtLeastOne.k <== out;
  hasAtLeastOne.out === 1;
 
}

component main = Max(6);

/* INPUT = {
    "in": ["0", "1", "3", "55", "8", "16"]
} */