#!/usr/bin/env bash
set -u

failures=0

fail() {
  printf 'FAIL: %s\n' "$1"
  failures=$((failures + 1))
}

expect_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "expected file $path"
}

expect_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "expected directory $path"
}

expect_absent() {
  local path="$1"
  [[ ! -e "$path" ]] || fail "expected no root-level $path"
}

expect_contains() {
  local path="$1"
  local pattern="$2"

  if [[ ! -f "$path" ]]; then
    fail "cannot inspect missing file $path"
    return
  fi

  grep -Fq "$pattern" "$path" || fail "expected $path to contain: $pattern"
}

expect_file ".claude-plugin/marketplace.json"
expect_contains ".claude-plugin/marketplace.json" '"name": "material-3-skill"'
expect_contains ".claude-plugin/marketplace.json" '"path": "skills/material-3"'
expect_absent ".claude-plugin/plugin.json"

expect_file "skills/material-3/.claude-plugin/plugin.json"
expect_contains "skills/material-3/.claude-plugin/plugin.json" '"name": "material-3"'
expect_contains "skills/material-3/.claude-plugin/plugin.json" '"repository": "https://github.com/hamen/material-3-skill"'

expect_file "skills/material-3/SKILL.md"
expect_dir "skills/material-3/references"
expect_file "skills/material-3/references/color-system.md"
expect_absent "SKILL.md"
expect_absent "references"

expect_contains "README.md" "/plugin marketplace add hamen/material-3-skill"
expect_contains "README.md" "/plugin install material-3@material-3-skill"
expect_contains "README.md" "skills/material-3/SKILL.md"

if [[ "$failures" -gt 0 ]]; then
  printf '\n%d plugin layout check(s) failed.\n' "$failures"
  exit 1
fi

printf 'Plugin layout checks passed.\n'
