# Week 2 Homework

## 1. IsSorted

Used `IsEqual` template instead of a constraint comparing with a constant to avoid under-constraint problem.

## 2. HasAtLeastOne

Idea is check if `(in[0] - k) * (in[0] - k) * (in[0] - k) * (in[0] - k) === 0` but turned that into R1CS.

## 3. IsMedian

zardkat has some JS bugs in a few modules under prettier/ directory. The circuit compiles and is verified in zkREPL: https://zkrepl.dev/?gist=fe7c15c2b8c09906eb1ddc61fc8446d4
