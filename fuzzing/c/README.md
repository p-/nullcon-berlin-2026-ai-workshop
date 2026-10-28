# Fuzzing C/C++ with libFuzzer

This example shows how a coverage-guided fuzzer finds a memory-safety bug in a few lines of C++.

## 1. Spot the bug

Open [`fuzz_me.cc`](fuzz_me.cc). `IsNullcon` checks whether its input starts with `Nullcon`. Can you find the bug before the fuzzer does?

`LLVMFuzzerTestOneInput` is the fuzz harness: libFuzzer calls it over and over with generated inputs.

## 2. Build the fuzzer

```bash
cd fuzzing/c
clang++ -g -fsanitize=address,fuzzer fuzz_me.cc -o fuzz_me
```

* `-fsanitize=fuzzer` links libFuzzer, which provides `main` and adds coverage instrumentation that guides input generation.
* `-fsanitize=address` enables AddressSanitizer, which turns silent out-of-bounds memory accesses into crashes.
* `-g` adds debug info, so the crash report shows file names and line numbers.

## 3. Run the fuzzer

```bash
./fuzz_me
```

libFuzzer starts from an empty corpus, mutates inputs, and keeps those that reach new code. It stops at the first crash, usually within a second, and saves the crashing input as `crash-<sha1>`.

## 4. Read the crash report

Look for:

* `ERROR: AddressSanitizer: heap-buffer-overflow`: the kind of bug.
* `READ of size 1`: the program read one byte outside the input buffer.
* `#0 ... in IsNullcon(...) .../fuzz_me.cc:12`: where it happened.
* The crashing input, printed as hex and as text just before `Test unit written to ./crash-<sha1>`.

## 5. Reproduce the crash

```bash
./fuzz_me crash-*
```

When given files, the fuzzer runs the harness once per file instead of fuzzing. Use this to debug a crash or to confirm a fix.

## 6. Solution

<details>
<summary>Show the bug and the fix</summary>

`Nullcon` is 7 bytes long, but `IsNullcon` only checks `size >= 6`. For the 6-byte input `Nullco`, the first six comparisons succeed and `data[6]` reads one byte past the end of the input.

Fix: change the check to `size >= 7`. Then rebuild and rerun step 5: the crash is gone. Running `./fuzz_me -max_total_time=10` fuzzes for 10 seconds without finding a crash.

</details>
