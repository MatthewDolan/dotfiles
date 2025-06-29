#!/usr/bin/env bats

setup() {
  repo_root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "bash scripts pass shellcheck" {
  if ! command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck not found" >&2
    return 1
  fi

  mapfile -t scripts < <(grep -rlE '^#!.*\bbash' "$repo_root" | grep -v "^$repo_root/bin/")
  all_pass=true
  for f in "${scripts[@]}"; do
    if bash -n "$f" && shellcheck -x -s bash --severity=style --enable=all "$f"; then
      echo "✅ $f"
    else
      echo "❌ $f"
      all_pass=false
    fi
  done
  [ "$all_pass" = true ]
}
