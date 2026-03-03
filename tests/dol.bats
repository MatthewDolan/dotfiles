#!/usr/bin/env bats
# shellcheck disable=SC2154

repo_root="$(git rev-parse --show-toplevel)"

run_dol() {
  if command -v zsh >/dev/null 2>&1; then
    run zsh "${repo_root}/home/bin/dol" "$@"
    return
  fi

  run bash "${repo_root}/home/bin/dol" "$@"
}

dol_help_prints_usage() {
  run_dol help
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"dol install [--yes]"* ]]
  [[ "${output}" == *"dol agents check [--yes]"* ]]
}

dol_update_fails_on_dirty_working_tree() {
  local dirty_file="${repo_root}/.dol-test-dirty.$$"

  touch "${dirty_file}"
  run_dol update
  rm -f "${dirty_file}"

  [[ "${status}" -eq 1 ]]
  [[ "${output}" == *"working tree has local changes"* ]]
}

bats_test_function --description "dol help prints usage" -- dol_help_prints_usage
bats_test_function --description "dol update fails on dirty working tree" -- dol_update_fails_on_dirty_working_tree
