#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats >/dev/null 2>&1; then
  echo "bats not found. Please install bats to run tests." >&2
  exit 1
fi

bats -r tests "$@"
