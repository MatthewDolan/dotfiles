#!/usr/bin/env bats

repo_root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

check_script() {
  local file="$1"
  bash -n "$file"
  shellcheck -x -s bash --severity=style --enable=all "$file"
}

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found" >&2
  exit 1
fi

mapfile -t scripts < <(grep -rlE '^#!.*\bbash' "$repo_root" | grep -v "^$repo_root/bin/")
for script in "${scripts[@]}"; do
  bats_test_function --description "$script" -- check_script "$script"
done
