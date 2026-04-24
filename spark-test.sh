#!/usr/bin/env bash
#
# spark-test.sh — Self-contained test suite for spark.
# No external dependencies. Run directly: ./spark-test.sh
# Exit code: 0 = all pass, 1 = one or more failures.

SPARK="./spark"
PASS=0
FAIL=0
_BOLD="\033[1m"
_GREEN="\033[32m"
_RED="\033[31m"
_DIM="\033[2m"
_RESET="\033[0m"

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    printf "  ${_GREEN}✓${_RESET} %s\n" "$desc"
    (( PASS++ ))
  else
    printf "  ${_RED}✗${_RESET} %s\n" "$desc"
    printf "      ${_DIM}expected:${_RESET} %s\n" "$expected"
    printf "      ${_DIM}actual:  ${_RESET} %s\n" "$actual"
    (( FAIL++ ))
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    printf "  ${_GREEN}✓${_RESET} %s\n" "$desc"
    (( PASS++ ))
  else
    printf "  ${_RED}✗${_RESET} %s\n" "$desc"
    printf "      ${_DIM}expected to contain:${_RESET} %s\n" "$needle"
    printf "      ${_DIM}actual:             ${_RESET} %s\n" "$haystack"
    (( FAIL++ ))
  fi
}

assert_exit_nonzero() {
  local desc="$1"; shift
  if ! "$@" >/dev/null 2>&1; then
    printf "  ${_GREEN}✓${_RESET} %s\n" "$desc"
    (( PASS++ ))
  else
    printf "  ${_RED}✗${_RESET} %s (expected non-zero exit)\n" "$desc"
    (( FAIL++ ))
  fi
}

assert_stderr_contains() {
  local desc="$1" needle="$2"; shift 2
  local actual; actual=$("$@" 2>&1 >/dev/null)
  if [[ "$actual" == *"$needle"* ]]; then
    printf "  ${_GREEN}✓${_RESET} %s\n" "$desc"
    (( PASS++ ))
  else
    printf "  ${_RED}✗${_RESET} %s\n" "$desc"
    printf "      ${_DIM}expected stderr:${_RESET} %s\n" "$needle"
    printf "      ${_DIM}actual stderr:  ${_RESET} %s\n" "$actual"
    (( FAIL++ ))
  fi
}

# ── Help & version ────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Help & version${_RESET}\n"

assert_contains "--help shows USAGE"   "USAGE" "$($SPARK --help)"
assert_contains "-h shows USAGE"       "USAGE" "$($SPARK -h)"
assert_contains "--version has 'spark'" "spark" "$($SPARK --version)"
assert_contains "-V has 'spark'"        "spark" "$($SPARK -V)"

# ── Basic graphing ────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Basic graphing (comma-separated)${_RESET}\n"

assert_eq "simple comma data"   "▁▂█▅▂"      "$($SPARK 1,5,22,13,5)"
assert_eq "0-30-55-80-33-150"   "▁▂▃▄▂█"     "$($SPARK 0,30,55,80,33,150)"
assert_eq "100 < 300"           "▁▁▁▁▃▁▁▁▂█" "$($SPARK 1,2,3,4,100,5,10,20,50,300)"
assert_eq "50 < 100"            "▁▄█"         "$($SPARK 1,50,100)"
assert_eq "4 < 8"               "▁▃█"         "$($SPARK 2,4,8)"
assert_eq "no tier 0 (1..5)"   "▁▂▄▆█"       "$($SPARK 1,2,3,4,5)"

# ── Space-separated argv ──────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Space-separated argv${_RESET}\n"

assert_eq "space-separated"    "▁▂▃▄▂█" "$($SPARK 0 30 55 80 33 150)"
assert_eq "extra whitespace"   "▁▂▃▄▂█" "$($SPARK 0 30               55 80 33     150)"

# ── Piped input ───────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Piped input${_RESET}\n"

assert_eq "pipe comma-separated" "▁▂▃▄▂█" "$(echo '0,30,55,80,33,150' | $SPARK)"
assert_eq "pipe space-separated" "▄▆▂█▁"  "$(echo '9 13 5 17 1' | $SPARK)"

# ── Decimals ──────────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Decimal handling${_RESET}\n"

assert_eq "decimals truncated"  "▁█"     "$($SPARK 5.5,20)"
assert_eq "all same decimals"   "▅▅▅▅"   "$($SPARK 2.9,2.1,2.5,2.3)"

# ── Constant / equal data ─────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Constant / equal data${_RESET}\n"

assert_eq "all same integers"   "▅▅▅▅"   "$($SPARK 1,1,1,1)"
assert_eq "single value"        "▅"       "$($SPARK 42)"

# ── Negative numbers ──────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Negative numbers${_RESET}\n"

assert_eq "negative range -5 0 5"     "▁▄█" "$($SPARK -- -5,0,5)"
assert_eq "all negatives -3 -2 -1"    "▁▄█" "$($SPARK -- -3,-2,-1)"
assert_eq "negative and positive mix" "▁▄█" "$($SPARK -- -10,0,10)"

# ── --min / --max annotation ──────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --min / --max annotation${_RESET}\n"

assert_contains "--min shows min value"   "(min=0"         "$($SPARK --min --max 0,30,55,80,33,150)"
assert_contains "--max shows max value"   "max=150)"       "$($SPARK --max 0,30,55,80,33,150)"
assert_contains "--min --max shows both"  "(min=0, max=150)" "$($SPARK --min --max 0,30,55,80,33,150)"

# ── --no-newline / -n ─────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --no-newline / -n flag${_RESET}\n"

result=$($SPARK --no-newline 1,2,3; echo "X")
assert_eq "--no-newline suppresses newline" "▁▄█X" "$result"

result=$($SPARK -n 1,2,3; echo "X")
assert_eq "-n shorthand suppresses newline" "▁▄█X" "$result"

# ── --color / -c ──────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --color / -c flag${_RESET}\n"

assert_contains "--color produces block chars" "▁" "$($SPARK --color 1,50,100 | cat)"
assert_contains "-c shorthand produces output"  "▁" "$($SPARK -c 1,50,100 | cat)"

# ── --scale / -s ──────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --scale / -s flag${_RESET}\n"

assert_eq "--scale 2 uses 2 levels"    "▁█"     "$($SPARK --scale 2 1,100)"
assert_eq "--scale 4 on even spread"   "▁▁▃▇"   "$($SPARK --scale 4 0,33,66,100)"
assert_eq "--scale 8 equals default"   "▁▂█▅▂"  "$($SPARK --scale 8 1,5,22,13,5)"
assert_eq "-s shorthand works"         "▁█"     "$($SPARK -s 2 1,100)"

assert_exit_nonzero "--scale 0 rejected" $SPARK --scale 0 1,2,3
assert_exit_nonzero "--scale 9 rejected" $SPARK --scale 9 1,2,3

# ── --reverse / -r ────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --reverse / -r flag${_RESET}\n"

assert_eq "--reverse inverts mapping" "█▅▁" "$($SPARK --reverse -- 1,50,100)"
assert_eq "-r shorthand inverts"      "█▅▁" "$($SPARK -r -- 1,50,100)"

# ── --ascii / -a ──────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ --ascii / -a flag${_RESET}\n"

result=$($SPARK --ascii 1,100)
assert_eq "--ascii min and max ticks" "_#" "$result"

result=$($SPARK -a 1,100)
assert_eq "-a shorthand works" "_#" "$result"

result=$($SPARK --ascii 1,50,100)
if [[ "$result" != *"▁"* && "$result" != *"█"* ]]; then
  printf "  ${_GREEN}✓${_RESET} --ascii produces no Unicode block chars\n"; (( PASS++ ))
else
  printf "  ${_RED}✗${_RESET} --ascii unexpectedly contains Unicode blocks: %s\n" "$result"; (( FAIL++ ))
fi

# ── Input validation ──────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Input validation${_RESET}\n"

assert_exit_nonzero "pure non-numeric exits non-zero" $SPARK abc
assert_stderr_contains "non-numeric warns on stderr" "warning" $SPARK 1 abc 3

result=$($SPARK 1 abc 3 2>/dev/null)
assert_eq "non-numeric skipped, valid values graphed" "▁█" "$result"

# ── Large dataset ─────────────────────────────────────────────────────────────
echo ""; printf "${_BOLD}▶ Large dataset${_RESET}\n"

large=$(seq 1 500 | tr '\n' ' ')
result=$($SPARK $large)
len=${#result}
if (( len == 500 )); then
  printf "  ${_GREEN}✓${_RESET} 500-value dataset → 500-char output\n"; (( PASS++ ))
else
  printf "  ${_RED}✗${_RESET} 500-value dataset: expected 500 chars, got %d\n" "$len"; (( FAIL++ ))
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
printf "${_BOLD}Results: ${_GREEN}${PASS} passed${_RESET}"
(( FAIL > 0 )) && printf ", ${_RED}${FAIL} failed${_RESET}"
printf "\n\n"

(( FAIL == 0 ))
