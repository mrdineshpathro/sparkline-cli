# changes

## 2.1.0

New flags for greater control over output:

- **`--scale N` / `-s N`** — choose 2–8 tick levels instead of always using 8.
  Useful when you want coarser or finer granularity. Example: `spark --scale 4 1 5 22 13 53`
- **`--reverse` / `-r`** — invert the tick mapping so high values produce short bars.
  Handy for "fewest errors = tallest bar" datasets.
- **`--ascii` / `-a`** — fall back to ASCII characters (`_.-:=|I#`) for terminals
  without Unicode support.
- **Input validation** — non-numeric tokens now emit a warning on stderr and are
  skipped gracefully; a fully non-numeric invocation exits non-zero.

Infrastructure:

- ShellCheck linting added to CI as a required first job.
- CI now prints the Bash version on each runner for easier debugging.
- Added `.shellcheckrc` to pin lint rules.
- Fixed wrong sparkline examples in help text comments (`▅` → `▄` for the
  `0,30,55,80,33,150` dataset — the old value was a math error in the original
  1.x test suite that was never caught because roundup tests weren't running).

## 2.0.0

Major modernisation of the entire codebase:

- **Negative number support** — values below zero are now scaled correctly.
- **Portable integer bounds** — replaced the hard-coded `0xffffffff` min
  initialiser (which broke on 64-bit Bash / ARM) with `2147483647`.
- **`--version` / `-V`** — print the version number.
- **`--color` / `-c`** — ANSI blue→red gradient coloring of the sparkline.
- **`--min` / `--max`** — append `(min=X, max=Y)` annotation to output.
- **`--no-newline` / `-n`** — suppress the trailing newline.
- **Modern Bash guards** — all comparisons moved to `[[ ]]`; all variables
  fully `local`-scoped.
- **Replaced roundup** — the unmaintained `roundup` test framework (last commit
  2013) was removed. `spark-test.sh` is now a self-contained Bash runner with
  zero external dependencies.
- **GitHub Actions CI** — replaces the deprecated Travis CI configuration.
  Tests run on `ubuntu-latest` and `macos-latest`.



## 1.0.0

Hey! A 1.0! Now's a decent time as any. Starting to cut versions just for the
sake of things like Homebrew. So, might as well start with 1.0.

1.0 encompasses things that happened during
[the first week](https://zachholman.com/posts/from-hack-to-popular-project/)
of development.