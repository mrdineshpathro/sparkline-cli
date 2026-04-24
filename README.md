# sparkline-cli
### ▁▂▃▅▇ sparklines for your shell

See? Here's a graph of your productivity gains after using spark: ▁▂▃▅▇

![Version](https://img.shields.io/badge/version-2.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## table of contents

- [install](#install)
- [usage](#usage)
- [options](#options-v210)
- [real-world useful examples](#real-world-useful-examples)
  - [🔀 Git & code](#-git--code)
  - [🌐 Network & system](#-network--system)
  - [🌍 APIs & live data](#-apis--live-data)
  - [💻 Shell prompt integration](#-shell-prompt-integration)
  - [📁 Log file analysis](#-log-file-analysis)
  - [📦 DevOps & CI monitoring](#-devops--ci-monitoring)
  - [📊 Data & finance](#-data--finance)
  - [🎛️ Combining flags](#️-combining-flags)
- [tips & tricks](#tips--tricks)
- [font troubleshooting](#font-troubleshooting)
- [contributing](#contributing)
- [changelog](#changelog)

---

## install

spark is a single [shell script][bin] with zero dependencies — just drop it
somewhere on your `$PATH`.

**One-liner install:**
```sh
sudo sh -c "curl -fsSL https://raw.githubusercontent.com/mrdineshpathro/sparkline-cli/main/spark -o /usr/local/bin/spark && chmod +x /usr/local/bin/spark"
```

**Manual (clone and add to PATH):**
```sh
git clone https://github.com/mrdineshpathro/sparkline-cli.git ~/sparkline-cli
echo 'export PATH="$PATH:$HOME/sparkline-cli"' >> ~/.bashrc
source ~/.bashrc
```

**Homebrew (macOS/Linux):**
```sh
brew install spark
```

**Source into the current shell session (no install needed):**
```sh
source /path/to/sparkline-cli/spark
spark 1 5 22 13 53   # usable immediately as a shell function
```

---

## usage

Just run `spark` and pass it a list of numbers (comma-delimited, spaces,
or piped from stdin):

```sh
spark 0 30 55 80 33 150
▁▂▃▄▂█

spark 1,5,22,13,53
▁▁▃▂█

echo "9 13 5 17 1" | spark
▄▆▂█▁

spark -- -5 0 5        # negative numbers supported
▁▄█
```

Invoke help with `spark -h`.

---

## options (v2.1.0)

```
spark [options] VALUE[,VALUE...]
echo "VALUE,..." | spark [options]
```

| Flag | Short | Description |
|------|-------|-------------|
| `--help` | `-h` | Show help text |
| `--version` | `-V` | Print the version number |
| `--color` | `-c` | Blue → red heat-gradient coloring |
| `--min` | | Append minimum value to output |
| `--max` | | Append maximum value to output |
| `--no-newline` | `-n` | Suppress trailing newline |
| `--scale N` | `-s N` | Use N tick levels (2–8, default 8) |
| `--reverse` | `-r` | Invert tick mapping (high value = short bar) |
| `--ascii` | `-a` | Use ASCII chars instead of Unicode blocks |

---

## real-world useful examples

> **The core idea:** any command that outputs numbers can be piped into `spark` to instantly visualize the trend. If you can `grep`, `awk`, or `cut` numbers out of anything — server logs, CSVs, API responses, `ps`, `df`, `git log` — you can spark it.

### 🔀 Git & code

**Commits per author** (relative contribution at a glance):
```sh
git shortlog -s | cut -f1 | spark
# ▁▁▁▁▂▁▁▁▃▁▅▁▂▁▁▁
```

**Commits per day of the week** (Mon–Sun, see when your team is most active):
```sh
git log --format="%ad" --date=format:"%u" \
  | sort | uniq -c | awk '{print $1}' | spark
# ▆▅█▅▄▂▁  (Mon is tallest → most active)
```

**Commits per month this year:**
```sh
git log --after="$(date +%Y)-01-01" --format="%ad" --date=format:"%m" \
  | sort | uniq -c | awk '{print $1}' | spark
# ▃▄▆▅▇█▄▂▃▁▁▁
```

**Lines added per commit** (find commit spikes):
```sh
git log --shortstat | grep "insertions" \
  | awk '{print $4}' | spark
# ▁▁▂▁▁▃▁▁█▁▂▁▁▁▁
```

**Line length distribution of a source file** (spot long lines):
```sh
awk '{ print length($0) }' spark | grep -Ev '^0$' | spark
# ▁▁▁▁▅▁▇▁▁▅▁▂▂▅▂▃▂▃▃▁▆▃▃▃▁▇
```

**File sizes in a directory** (visually compare sizes):
```sh
ls -l *.sh | awk '{print $5}' | spark
# ▁▃█▂▁▅
```

**Number of files changed per commit** (last 30 commits):
```sh
git log --oneline -30 --shortstat \
  | grep "files changed" | awk '{print $1}' | spark
# ▁▂▁▁▃▅▁▂▁▁█▁▂▃▁▁▁▂▁▁▁▁▃▁▁▂▁▁▁▁
```

---

### 🌐 Network & system

**Ping latency over 20 samples** (spot jitter):
```sh
ping -c 20 google.com \
  | grep "time=" | sed 's/.*time=//;s/ ms//' | spark
# ▁▁▂▁▁▃▂▁█▁▁▁▂▁▁▁▂▁▁▁
```

**CPU usage every second for 15 seconds:**
```sh
for i in $(seq 1 15); do
  top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us,'
  sleep 1
done | spark
# ▂▁▁▁▃▁▂▁▁▁█▃▂▁▁
```

**Memory usage trend (RSS of a process):**
```sh
PID=1234
for i in $(seq 1 20); do
  ps -o rss= -p $PID 2>/dev/null || echo 0
  sleep 2
done | spark
# ▁▁▂▂▃▃▄▅▅▆▆▆▇▇▇▇██▇▇
```

**Disk usage of top-level folders:**
```sh
du -s */ 2>/dev/null | awk '{print $1}' | spark
# ▁▁▃▁█▂▁▁▄▁
```

**Network bytes received per second (Linux):**
```sh
IFACE=eth0
for i in $(seq 1 15); do
  grep "$IFACE" /proc/net/dev | awk '{print $2}'
  sleep 1
done | awk 'NR>1{print $1-prev} {prev=$1}' | spark
# ▁▁▂▁▅▁█▃▁▁▁▂▁▁▁
```

**Open file descriptors for a process over time:**
```sh
PID=1234
for i in $(seq 1 10); do
  ls /proc/$PID/fd 2>/dev/null | wc -l
  sleep 5
done | spark
# ▄▄▅▄▆▄▄▅▇█  (growing = possible fd leak)
```

---

### 🌍 APIs & live data

**Earthquake magnitudes (USGS live feed):**
```sh
curl -s "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.csv" \
  | sed '1d' | cut -d, -f5 | spark
# ▃█▅▅█▅▃▃▅█▃▃▁▅▅▃▃▅
```

**Weather temperature forecast (wttr.in):**
```sh
curl -s "wttr.in/?format=%t" | tr -d '+°C' | spark
```

**HackerNews top story scores:**
```sh
curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" \
  | tr ',' '\n' | head -20 | tr -d '[]' \
  | xargs -I{} curl -s "https://hacker-news.firebaseio.com/v0/item/{}.json" \
  | grep -o '"score":[0-9]*' | cut -d: -f2 | spark
# ▄▇▅▂▁▃█▄▅▁▂▃▄▂▁▂▁▅▃▂
```

**GitHub star history for a repo:**
```sh
curl -s "https://api.github.com/repos/holman/spark" \
  | grep -o '"stargazers_count":[0-9]*' | cut -d: -f2 | spark
```

**Bitcoin price (last 30 days via CoinGecko):**
```sh
curl -s "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30" \
  | grep -o '"prices":\[\[[^]]*' | tr ',' '\n' | grep -v prices \
  | awk -F']' '{print int($1)}' | spark
# ▃▄▅▆▅▄▃▅▆▇█▇▆▅▄▃▄▅▆▅▄▃▄▅▆▇
```

---

### 💻 Shell prompt integration

Put a sparkline of your 1/5/15-min load averages right in your prompt:

**Bash** (add to `~/.bashrc`):
```sh
_spark_load() {
  uptime | grep -oP '[\d.]+' | tail -3 | spark --no-newline
}
export PS1='[\u@\h load:$(_spark_load)] \w \$ '
# [user@host load:▂▃▄] ~/projects $
```

**Zsh** (add to `~/.zshrc`):
```sh
PROMPT='%F{cyan}$(uptime | grep -oP "[\d.]+" | tail -3 | spark --no-newline)%f %~ %# '
# ▂▃▄ ~/projects %
```

**Fish** (add to `~/.config/fish/config.fish`):
```sh
function fish_prompt
  set load (uptime | grep -oP '[\d.]+' | tail -3 | string join ' ')
  echo -n (spark $load)" "
  echo (prompt_pwd)" > "
end
```

**Git branch + recent commit activity in prompt:**
```sh
_spark_git() {
  git log --oneline -7 2>/dev/null \
    | awk '{print length($0)}' | spark --no-newline
}
export PS1='\w $(_spark_git) \$ '
# ~/myproject ▁▃▄▅▄▇█ $
```

---

### 📁 Log file analysis

**HTTP status code distribution (nginx/apache access log):**
```sh
awk '{print $9}' /var/log/nginx/access.log \
  | sort | uniq -c | sort -k2n | awk '{print $1}' | spark
# ▁▁▁▃█▁  (huge spike = one status dominates)
```

**Error count per hour (24-hour view):**
```sh
grep "ERROR" app.log \
  | awk '{print substr($2,1,2)}' \
  | sort | uniq -c | awk '{print $1}' | spark
# ▁▁▁▁▁▂▃▅█▆▄▃▂▂▁▁▁▁▁▁▁▁▁▁
```

**Response times from a log:**
```sh
grep "duration=" app.log \
  | sed 's/.*duration=\([0-9]*\).*/\1/' | spark
# ▁▂▁▁▃▁▁█▁▁▂▁▁▁▁▃▁
```

**Requests per minute (last hour):**
```sh
grep "$(date +'%d/%b/%Y')" /var/log/nginx/access.log \
  | awk '{print substr($4,14,2)}' \
  | sort | uniq -c | awk '{print $1}' | spark
# ▁▂▁▁▄▅█▇▅▃▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
```

**Top IPs by request count:**
```sh
awk '{print $1}' /var/log/nginx/access.log \
  | sort | uniq -c | sort -rn | head -10 | awk '{print $1}' | spark
# █▄▃▂▂▁▁▁▁▁
```

---

### 📦 DevOps & CI monitoring

**Docker container memory usage:**
```sh
docker stats --no-stream --format "{{.MemUsage}}" \
  | awk -F/ '{print $1}' | grep -o '[0-9.]*' | spark
# ▁▂▄▇█▃▁▂
```

**K8s pod restart counts:**
```sh
kubectl get pods --all-namespaces \
  | awk 'NR>1 {print $5}' | spark
# ▁▁▁▁▁▂▁▁█▁▁▁  (spike = crashlooping pod)
```

**CI build durations (seconds) from a log:**
```sh
grep "Build finished" ci.log | awk '{print $NF}' | tr -d 's' | spark
# ▂▂▃▂▅▄▇▄▃█▂▃▂▂▃
```

**Deployment frequency per day:**
```sh
grep "Deployed" deploy.log | awk '{print $1}' \
  | sort | uniq -c | awk '{print $1}' | spark
# ▁▃▁▅▁▁▂▁▁█▁▁▁▁▃
```

**Test suite duration trend (last 20 runs):**
```sh
grep "Finished in" test.log | tail -20 \
  | awk '{print $3}' | spark --color --min --max
# ▂▃▃▄▄▅▄▆▇█  (min=12.3s, max=45.1s)
```

---

### 📊 Data & finance

**CSV column sparkline** (e.g., column 3 of a data file):
```sh
awk -F, 'NR>1 {print $3}' data.csv | spark
```

**Stock price history (Yahoo Finance via curl):**
```sh
curl -s "https://query1.finance.yahoo.com/v8/finance/chart/AAPL?range=1mo&interval=1d" \
  | grep -o '"close":\[[^]]*' | tr ',' '\n' | grep -v close \
  | awk '{printf "%.0f\n", $1}' | spark
# ▅▆▄▅▆▇▇▆▅▄▃▄▅▆▇▇▆▅▄▅▆▇█
```

**Word frequency in a text file** (top 20 words):
```sh
tr -s ' ' '\n' < article.txt | sort | uniq -c \
  | sort -rn | head -20 | awk '{print $1}' | spark
# █▄▃▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁
```

**Lines of code per file in a project:**
```sh
wc -l src/*.py | sort -n | awk 'NR>1{print $1}' | spark
# ▁▁▂▁▃▄▅▃▇▅█▄
```

---

### 🎛️ Combining flags

```sh
# Colored + min/max — great dashboard one-liner
spark --color --min --max 12 45 33 78 55 91 20
# ▁▄▂▆▄▇▁  (min=12, max=91)

# "Lower is better" metrics — reversed so tall bar = bad
spark --reverse --color 5 2 8 1 15 3
# █▆▄▇▁▆  (tall = high error count = bad)

# ASCII output safe for log files / emails / CI output
spark --ascii 10 40 80 50 20
# _-#:.

# Coarse 4-level view for large value ranges
spark --scale 4 --min --max 1 100 500 250 750 1000
# ▁▁▃▂▄█  (min=1, max=1000)

# Embed in a string without a trailing newline
echo "Trend: $(spark --no-newline 1 5 22 13 53) ← last 5 deploys"
# Trend: ▁▁▃▂█ ← last 5 deploys

# Error rate dashboard (reversed + colored + minmax)
spark --reverse --color --min --max 0 2 5 1 8 0 3
# █▆▄▇▁█▅  (min=0, max=8) — tall = more errors
```

---

## tips & tricks

**Tip 1 — Use `--` to safely pass negative numbers:**
```sh
spark -- -10 -5 0 5 10
▁▂▄▆█
```

**Tip 2 — Works great in `watch` for live monitoring:**
```sh
watch -n1 'df -h / | awk "NR>1{print \$5}" | tr -d "%" | spark'
```

**Tip 3 — Chain with `tee` to log and visualize simultaneously:**
```sh
./benchmark.sh | tee results.txt | awk '{print $1}' | spark
```

**Tip 4 — Use `--ascii` when writing to log files** so sparklines are preserved in plaintext:
```sh
echo "Build times: $(spark --ascii 12 18 22 15 30)" >> build.log
# Build times: _.:-.#
```

**Tip 5 — `--scale 2` gives a simple pass/fail binary view:**
```sh
spark --scale 2 0 1 1 0 1 0 0 1
# ▁█████▁▁██  (▁=fail, █=pass)
```

**Tip 6 — Pipe from `seq` to preview tick distribution:**
```sh
seq 0 7 | spark               # even 8-step distribution
seq 0 100 | spark --scale 4   # 101 values at 4 levels
```

**Tip 7 — Use `--reverse` for "lower is better" datasets:**
```sh
# P95 response times — you want them LOW, so reversed bar = how good things are
spark --reverse --color --min --max 95 210 88 305 72 98
```

**Tip 8 — Source spark for use inside scripts without adding it to PATH:**
```sh
#!/usr/bin/env bash
source /path/to/spark/spark

results=(12 45 33 78 55 91)
echo "Results trend: $(spark "${results[@]}")"
```

---

## font troubleshooting

Spark uses Unicode block characters: `▁ ▂ ▃ ▄ ▅ ▆ ▇ █`

If you see irregular or misaligned blocks, your terminal font doesn't fully support these characters. Fixes:

| Terminal | Recommended Font |
|----------|-----------------|
| iTerm2 / macOS | Menlo, Monaco, or any Nerd Font |
| Windows Terminal | Cascadia Code, Consolas |
| GNOME Terminal | Ubuntu Mono, DejaVu Sans Mono |
| VS Code terminal | Any Nerd Font |

Install a good monospace font and set it as your terminal font. [Nerd Fonts](https://www.nerdfonts.com/) work great.

Use `--ascii` as a fallback if fonts are unavoidable:
```sh
spark --ascii 1 5 22 13 53
# __-.#
```

---

## contributing

Contributions welcome! Like seriously, I think contributions are real nifty.

Make your changes and be sure the tests all pass:

```sh
./spark-test.sh
```

That also means you should probably be adding your own tests as well as changing
the code. Wouldn't want to lose all your good work down the line, after all!

Once everything looks good, open a pull request.

---

## changelog

### v2.1.0
- `--scale N` / `-s` — choose 2–8 tick levels
- `--reverse` / `-r` — invert the bar mapping
- `--ascii` / `-a` — ASCII character fallback
- Input validation with graceful skip + stderr warning
- ShellCheck linting in CI
- Fixed wrong sparkline values in original test suite

### v2.0.0
- Negative number support
- Portable integer bounds (removed `0xffffffff`)
- `--version`, `--color`, `--min`, `--max`, `--no-newline` flags
- Replaced `roundup` with a self-contained Bash test suite
- GitHub Actions CI (replaces Travis CI)

### v1.0.0
- Hey! A 1.0! Starting to cut versions for the sake of things like Homebrew.
  [Read the origin story.](https://zachholman.com/posts/from-hack-to-popular-project/)

---

## ▇▁ ⟦⟧ ▇▁

Originally a [@holman][holman] joint. Upgraded & maintained by [@mrdineshpathro](https://github.com/mrdineshpathro).

[bin]:      https://github.com/mrdineshpathro/sparkline-cli/blob/main/spark
[brew]:     https://github.com/mxcl/homebrew
[wiki]:     https://github.com/holman/spark/wiki/Wicked-Cool-Usage
[holman]:   https://twitter.com/holman
