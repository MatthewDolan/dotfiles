#!/usr/bin/env bats

repo_root="$(git rev-parse --show-toplevel)"

check_script() {
  local file="$1"
  local shebang

  if [[ "${file}" == *.bats ]]; then
    bats --count "${file}" >/dev/null
    return 0
  fi

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

# De-duplicate script paths in case a Bats test contains heredocs with shebangs.
unique_scripts=()
while IFS= read -r line; do
  unique_scripts+=("${line}")
done < <(printf '%s\n' "${scripts[@]}" | awk 'NF && !seen[$0]++')
scripts=("${unique_scripts[@]}")

for script in "${scripts[@]}"; do
  bats_test_function --description "${script}" -- check_script "${script}"
done
