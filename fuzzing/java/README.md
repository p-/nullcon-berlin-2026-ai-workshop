# Fuzzing Java with Jazzer and Maven

This example shows how a coverage-guided fuzzer finds an input that has to pass several checks on transformed data.

[Jazzer](https://github.com/CodeIntelligenceTesting/jazzer) is a coverage-guided fuzzer for the JVM, built on libFuzzer. A fuzz test is a JUnit method annotated with `@FuzzTest`, and Jazzer generates its arguments.

## 1. Find the secret input

Open [`SecretCheck.java`](src/main/java/com/example/SecretCheck.java) and its fuzz test [`SecretCheckFuzzTest.java`](src/test/java/com/example/SecretCheckFuzzTest.java). Which values of `magic`, `block1` and `block2` reach `mustNeverBeCalled()`?

The annotations on `magic` tell Jazzer to generate a non-null array of exactly 6 bytes.

## 2. Run the fuzzer

```bash
cd fuzzing/java
JAZZER_FUZZ=1 mvn test -Dtest='SecretCheckFuzzTest#fuzz'
```

`JAZZER_FUZZ=1` runs the `@FuzzTest` method in fuzzing mode, and `-Dtest='SecretCheckFuzzTest#fuzz'` selects the fuzz test method to run by class and method name. Jazzer fuzzes only one `@FuzzTest` per run. The first run also downloads the dependencies.

Jazzer reaches `mustNeverBeCalled()` within seconds, and the build fails.

## 3. Read the report

The output is long. Look for:

* `FuzzTestFindingException: com.code_intelligence.jazzer.api.FuzzerSecurityIssueLow: mustNeverBeCalled has been called`: the finding.
* The stack trace below `Caused by:`, from `SecretCheck.mustNeverBeCalled` down to `SecretCheckFuzzTest.fuzz`: how the input got there.
* `Test unit written to .../src/test/resources/com/example/SecretCheckFuzzTestInputs/fuzz/crash-<sha1>`: where Jazzer saved the input.

## 4. Replay the finding as a regression test

```bash
mvn test
```

Without `JAZZER_FUZZ`, the `@FuzzTest` method runs like a unit test on every input saved in `src/test/resources/com/example/SecretCheckFuzzTestInputs/fuzz/`. The saved finding fails the build again, so a fixed bug can't come back unnoticed.

## 5. Solution

<details>
<summary>Show the input</summary>

The input that reaches `mustNeverBeCalled()` is:

* `magic`: the bytes of `Jazzer`, whose Base64 encoding is `SmF6emVy`.
* `block1`: `0x702065756c617620`, the bytes of ` value p` read as a little-endian `long`.
* `block2`: `0x676e696c69666f72`, the bytes of `rofiling` read as a little-endian `long`.

Together they spell `Jazzer value profiling`.

To start over, delete the saved inputs and the generated corpus, and rebuild. Otherwise Maven replays a stale copy from `target/`:

```bash
rm -rf src/test/resources/com .cifuzz-corpus
mvn clean
```

</details>
