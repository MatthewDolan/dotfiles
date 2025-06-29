#!/usr/bin/env bats

repo_root="$(git rev-parse --show-toplevel)"

check_script() {
  local file="$1"
  local shebang
  shebang="$(head -n1 "${file}")"
  if [[ "${shebang}" == *zsh* ]] && command -v zsh >/dev/null 2>&1; then
    zsh -n "${file}"
  else
    bash -n "${file}"
  fi
  shellcheck -x -s bash --severity=style --enable=all "${file}"
}

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not found" >&2
  exit 1
fi

scripts=()
while IFS= read -r line; do
  scripts+=("${line}")
done < <(grep -rlE '^#!.*\b(bash|zsh)' "${repo_root}" | grep -v "^${repo_root}/bin/" || true)

bats_tests=()
while IFS= read -r line; do
  bats_tests+=("${line}")
done < <(find "${repo_root}/tests" -name '*.bats' -type f || true)

scripts+=("${bats_tests[@]}")

for script in "${scripts[@]}"; do
  bats_test_function --description "${script}" -- check_script "${script}"
done
