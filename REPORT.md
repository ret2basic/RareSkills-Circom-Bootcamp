# Circom Homework Security Report

Date: 2026-05-20

## Scope

Reviewed and fixed the Circom homework circuits in `week_2` through `week_5`, plus the Solidity MiMC wrapper and tests in `week_6`.

The generated verifier at `week_2/IsMedianVerifier.sol` was reviewed only as a generated artifact. It was not regenerated, because regenerating a verifier requires a fresh proving/verifying key setup for the modified `IsMedian.circom` circuit.

## Executive Summary

The original code had several proof-soundness bugs. The most important classes were:

- Outputs or intermediate values assigned with `<--` but not fully constrained.
- Compile-time `var` / `if` logic used as if it could branch on private signals.
- Missing bit and range constraints before using arithmetic as bitwise or integer comparison logic.
- Integer arithmetic checked only modulo the BN254 scalar field, allowing possible wraparound attacks.
- Stack circuits that simulated state outside the constraint system.
- A Solidity verifier wrapper that silently truncated `uint256` leaves to `uint128`.

I added a local `common.circom` helper library and rewrote the affected circuits so the witness hints that remain are backed by constraints.

## Shared Fixes

Added `common.circom` with reusable constrained templates:

- `Num2Bits` / `RangeCheck` for explicit integer ranges.
- `IsZero` / `IsEqual` for constrained equality checks.
- `LessThan`, `LessEqThan`, `GreaterThan`, `GreaterEqThan` with operand range checks.
- `Select` for constrained array selection by index.
- `LongMulAddEq` for integer-safe `a * b + c == d` without field wraparound.

This also removes the dependency on missing `node_modules/circomlib` include paths.

## Findings And Fixes

### Week 2

#### `HasAtLeastOne.circom`

Original issue:

- The circuit was hard-coded for four items despite taking `n`.
- `out <-- result != 0 ? 0 : 1` was only a witness hint.
- The only constraint on `out` was booleanity, so a malicious witness could set `out = 1` even when `k` was not in the list.

Security impact: critical underconstraint. The membership proof could be forged.

Fix:

- Replaced hard-coded temporaries with a product accumulator over all `n` elements.
- Used constrained `IsZero(product)` to bind `out` to whether any factor is zero.

#### `IsSorted.circom`

Original issue:

- The circuit depended on a missing external `circomlib` include path.
- The `IsEqual(lessEqThan.out, 1)` wrapper was unnecessary.

Security impact: no direct proof forgery found in the sortedness logic, but the circuit did not compile in this checkout without external setup.

Fix:

- Switched to local `LessEqThan(252)` and constrained each comparator output directly to `1`.

#### `IsMedian.circom`

Original issue:

- The include path pointed outside the repository layout.
- Sortedness used strict `<`, so valid median lists with duplicate adjacent values were rejected even though the spec says sorted/non-decreasing.

Security impact: primarily correctness/spec failure, not a forgery issue. However, the generated verifier is now stale after the circuit fix.

Fix:

- Updated to local helpers.
- Changed strict ordering to non-decreasing ordering.
- Kept `k` public and constrained `in[2] === k`.

### Week 3

#### `IntDiv.circom`

Original issue:

- `correct_quotient` and `correct_remainder` were witness hints, not computations enforced by constraints.
- The equation `quotient * denominator + remainder === numerator` was checked in the field, not as bounded integer arithmetic.
- Without an overflow-safe integer multiplication check, large `quotient * denominator` values could wrap modulo the field.

Security impact: high. Modular wraparound could satisfy the circuit for values that are not a valid integer division.

Fix:

- Removed fake computed intermediates.
- Added `denominator > 0`.
- Kept `remainder < denominator`.
- Added `LongMulAddEq(n)` so `quotient * denominator + remainder == numerator` is enforced bit-by-bit as an integer relation.

#### `IntDivOut.circom`

Original issue:

- `quotient` and `remainder` were hints.
- The same field-wraparound risk existed as in `IntDiv`.
- Division by zero was not explicitly ruled out as a circuit condition.

Security impact: high for the same reason as `IntDiv`.

Fix:

- Kept hints only to compute the output witness.
- Added explicit `denominator > 0`, `remainder < denominator`, and `LongMulAddEq(n)` constraints.

#### `IntSqrt.circom`

Original issue:

- `term1 <-- in[0] * in[0]` and `term2 <-- (in[0] + 1) * (in[0] + 1)` were unconstrained hints.
- A prover could choose fake square values that satisfy the comparisons.

Security impact: critical underconstraint. Incorrect square roots could be proven.

Fix:

- Replaced both hints with `<==` constraints.
- Kept the overflow guard on the root so square computations are integer-safe for the 252-bit radicand range.

#### `IntSqrtOut.circom`

Original issue:

- Same unconstrained square hints as `IntSqrt`.
- The witness computation used an unbounded linear search, which is impractical for large inputs.

Security impact: critical for the unconstrained square hints; availability/prover-performance issue for the linear search.

Fix:

- Replaced square hints with constraints.
- Replaced linear search with a fixed-iteration integer square-root routine.
- Kept constraints proving `out^2 <= in < (out + 1)^2`.

#### `Max.circom`

Original issue:

- The circuit tried to use `if (in[i] > currentMax)` on signals in compile-time `var` logic.
- `out <-- currentMax` was not a constrained computation.
- The local `HasAtLeastOne` helper was hard-coded to length 6.

Security impact: high. The intended maximum computation was not a sound signal-level circuit.

Fix:

- Rewrote `Max` as a comparator-driven running maximum.
- Each update is constrained by `GreaterThan(252)` and a signal-level selected difference.
- Removed the hard-coded membership helper.

### Week 4

#### `BitwiseAND.circom`, `BitwiseOR.circom`, `BitwiseXOR.circom`

Original issue:

- Inputs were never constrained to be bits.
- Arithmetic formulas for bitwise gates are only valid over `{0,1}` inputs.

Security impact: high if these circuits are used as bitwise primitives. Non-bit inputs could satisfy unintended arithmetic relations.

Fix:

- Added binary constraints for all input bits.
- Added output binary constraints as a defensive invariant.

#### `BitwiseAdd.circom`

Original issue:

- Inputs were not constrained to bits.
- `out[i] <-- ...` was an unconstrained output hint.
- `carry_bit` was a compile-time `var`, not a signal.
- `carry_bit = in[0][i] & in[1][i]` tried to use a bitwise operator on signals and ignored carry propagation from previous columns.

Security impact: high. The addition relation could be wrong or underconstrained.

Fix:

- Added bit constraints for inputs, outputs, and carries.
- Replaced the logic with a constrained ripple-carry full adder.
- Split multi-product carry logic into rank-1-friendly intermediate signals.

### Week 5

#### `Stack_Phase1.circom`, `Stack_Phase2.circom`, `Stack_Phase3.circom`

Original issue:

- Stack state was stored in `var` arrays, outside the witness constraint system.
- The code branched on signal-derived opcodes using `if`, which does not create runtime circuit branching.
- Multiplexer inputs used `<--` from unconstrained `var` state.
- Overflow, underflow, opcode validity, and queried index validity were incomplete.

Security impact: critical. The circuits did not soundly prove stack execution.

Fix:

- Rewrote all phases as constrained state machines with `stack[step][slot]` and `depth[step]` signals.
- Phase 1 accepts only push opcodes.
- Phase 2 accepts push/nop and rejects invalid opcodes.
- Phase 3 accepts push/nop/pop and rejects stack underflow/overflow.
- Added constrained final selection and `index < finalDepth`.

### Week 6 Solidity

#### `Homework.sol`

Original issue:

- `verify(uint256 l1, uint256 l2)` silently cast both leaves to `uint128`.
- Inputs such as `2^128 + 1234` and `1234` produced the same hash preimage.
- Production code imported `forge-std/Test.sol` only for `console.log`.
- Constructor accepted any address for the MiMC contract.

Security impact: high for applications relying on the full `uint256` inputs. Multiple different caller inputs could verify as the same leaf pair.

Fix:

- Added explicit `l1 <= type(uint128).max` and `l2 <= type(uint128).max` checks before casting.
- Removed `console.log` and the test-only import from production code.
- Made `ROOT` and `MIMC_KEY` constants and `mimc` immutable.
- Added a constructor code-size check for the MiMC address.
- Simplified `concat` to `(uint256(a) << 128) | uint256(b)`.

#### `Homework.t.sol`

Fixes:

- Added regression tests for high-bit truncation rejection and wrong-root rejection.
- Replaced hard-coded bytecode length in the deploy helper with `mload(bytecode)`.
- Ran `forge fmt`.

## Remaining Operational Note

`week_2/IsMedianVerifier.sol` is generated from the previous `IsMedian.circom`. Because the circuit changed, that verifier should be considered stale. Before deploying or relying on it, regenerate the proving and verifying keys and replace the verifier from the fixed circuit.

I did not edit the generated verifier directly.

## Validation Performed

Circom compiler validation:

```sh
circom <each week_2-week_5 circuit> --r1cs --wasm --sym --inspect -o /tmp/rareskills-circom-audit/<circuit>
```

Result: all 15 Circom circuits compiled successfully with `Everything went okay`.

Circom witness validation:

- Positive and negative generated-witness checks were run for membership, sorting, median, division, square root, max, bitwise gates, bitwise addition, and all stack phases.
- Invalid cases included unsorted lists, wrong median `k`, wrong division remainder, zero denominator, wrong square root, non-bit bitwise inputs, invalid stack opcode, and stack underflow.

Solidity validation:

```sh
cd week_6
forge fmt --check
forge test
```

Result: `3 passed; 0 failed; 0 skipped`.

## Intentional Witness Hints Remaining

The remaining `<--` hints are deliberate and constrained:

- `Num2Bits` bit witnesses are constrained by booleanity and recomposition.
- `IsZero` inverse witness is constrained by the standard zero-check equations.
- `IntDivOut` quotient/remainder witnesses are constrained by denominator checks, `remainder < denominator`, and `LongMulAddEq`.
- `IntSqrtOut` output witness is constrained by `out^2 <= in < (out + 1)^2` and the overflow bound.
