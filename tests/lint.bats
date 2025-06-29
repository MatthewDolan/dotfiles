#!/usr/bin/env bats

repo_root="$(git rev-parse --show-toplevel)"

check_script() {
  local file="$1"
  bash -n "${file}"
  shellcheck -x -s bash --severity=style --enable=all "${file}"
}

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found" >&2
  exit 1
fi

scripts=()
while IFS= read -r line; do
  scripts+=("${line}")
done < <(grep -rlE '^#!.*\bbash' "${repo_root}" | grep -v "^${repo_root}/bin/" || true)

bats_tests=()
while IFS= read -r line; do
  bats_tests+=("${line}")
done < <(find "${repo_root}/tests" -name '*.bats' -type f || true)

scripts+=("${bats_tests[@]}")

for script in "${scripts[@]}"; do
  bats_test_function --description "${script}" -- check_script "${script}"
done
