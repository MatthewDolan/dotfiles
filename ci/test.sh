#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

# Find all files that use bash in the shebang
# shellcheck disable=SC2312
mapfile -t files < <(grep -rlE '^#!.*\bbash' "${repo_root}" | grep -v "^${repo_root}/bin/")

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found. Please install shellcheck to lint scripts." >&2
  exit 1
fi

echo "Running bash syntax checks and shellcheck..." >&2
all_pass=true
for file in "${files[@]}"; do
  if bash -n "${file}" && shellcheck -x -s bash --severity=style --enable=all "${file}"; then
    printf "✅ %s\n" "${file}" >&2
  else
    printf "❌ %s\n" "${file}" >&2
    all_pass=false
  fi
done

if ${all_pass}; then
  echo "All bash checks passed." >&2
else
  echo "Some bash checks failed." >&2
  exit 1
fi
