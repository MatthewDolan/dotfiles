#!/usr/bin/env bats

repo_root="$(git rev-parse --show-toplevel)"

setup() {
  tmp_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install-test.XXXXXX")"
  fake_bin="${tmp_home}/fake-bin"
  mkdir -p "${fake_bin}" "${tmp_home}/.oh-my-zsh"

  cat > "${fake_bin}/uname" <<'EOF'
#!/bin/sh
echo "Linux"
EOF
  chmod +x "${fake_bin}/uname"

  real_git="$(command -v git)"
  cat > "${fake_bin}/git" <<EOF
#!/bin/sh
if [ "\$1" = "ls-remote" ]; then
  exit 1
fi
exec "${real_git}" "\$@"
EOF
  chmod +x "${fake_bin}/git"

  install_env=(
    "HOME=${tmp_home}"
    "PATH=${fake_bin}:${PATH}"
    "DOLAN_USE_HERMIT=false"
  )

  if command -v zsh >/dev/null 2>&1; then
    install_command=(
      "$(command -v zsh)"
      "${repo_root}/install.sh"
    )
  else
    install_command=(
      "$(command -v bash)"
      "${repo_root}/home/bin/dol"
      install
    )
  fi
}

teardown() {
  rm -rf "${tmp_home}"
}

@test "fresh install prepends managed include blocks" {
  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  [ -L "${tmp_home}/.zshrc.dolan" ]
  [ -L "${tmp_home}/.zshenv.dolan" ]
  [ -L "${tmp_home}/.gitconfig.dolan" ]

  [ -f "${tmp_home}/.zshrc" ]
  [ ! -L "${tmp_home}/.zshrc" ]
  [ -f "${tmp_home}/.zshenv" ]
  [ ! -L "${tmp_home}/.zshenv" ]
  [ -f "${tmp_home}/.gitconfig" ]
  [ ! -L "${tmp_home}/.gitconfig" ]

  run sed -n '1,3p' "${tmp_home}/.zshrc"
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "# >>> ~/.dotfiles/install.sh >>>" ]
  [ "${lines[1]}" = "[ -f \"\$HOME/.zshrc.dolan\" ] && . \"\$HOME/.zshrc.dolan\"" ]
  [ "${lines[2]}" = "# <<< ~/.dotfiles/install.sh <<<" ]

  run sed -n '1,3p' "${tmp_home}/.zshenv"
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "# >>> ~/.dotfiles/install.sh >>>" ]
  [ "${lines[1]}" = "[ -f \"\$HOME/.zshenv.dolan\" ] && . \"\$HOME/.zshenv.dolan\"" ]
  [ "${lines[2]}" = "# <<< ~/.dotfiles/install.sh <<<" ]

  run sed -n '1,4p' "${tmp_home}/.gitconfig"
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "# >>> ~/.dotfiles/install.sh >>>" ]
  [ "${lines[1]}" = "[include]" ]
  [ "${lines[2]}" = "  path = ~/.gitconfig.dolan" ]
  [ "${lines[3]}" = "# <<< ~/.dotfiles/install.sh <<<" ]
}

@test "existing file contents are preserved under prepended block" {
  cat > "${tmp_home}/.zshrc" <<'EOF'
export KEEP_THIS_LINE=1
EOF

  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  run tail -n 1 "${tmp_home}/.zshrc"
  [ "${status}" -eq 0 ]
  [ "${output}" = "export KEEP_THIS_LINE=1" ]
}

@test "stale managed blocks are replaced with current include content" {
  cat > "${tmp_home}/.zshrc" <<'EOF'
# >>> ~/.dotfiles/install.sh >>>
[ -f "$HOME/.old-zshrc" ] && . "$HOME/.old-zshrc"
# <<< ~/.dotfiles/install.sh <<<

export STILL_HERE=1
EOF

  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  run grep -c '^# >>> ~/.dotfiles/install.sh >>>$' "${tmp_home}/.zshrc"
  [ "${status}" -eq 0 ]
  [ "${output}" -eq 1 ]

  run grep -c 'old-zshrc' "${tmp_home}/.zshrc"
  [ "${status}" -eq 1 ]

  run sed -n '1,3p' "${tmp_home}/.zshrc"
  [ "${status}" -eq 0 ]
  [ "${lines[1]}" = "[ -f \"\$HOME/.zshrc.dolan\" ] && . \"\$HOME/.zshrc.dolan\"" ]
}

@test "existing symlinked dotfiles are unlinked and replaced with local files" {
  ln -s "${repo_root}/home/.zshrc.dolan" "${tmp_home}/.zshrc"
  ln -s "${repo_root}/home/.zshenv.dolan" "${tmp_home}/.zshenv"
  ln -s "${repo_root}/home/.gitconfig.dolan" "${tmp_home}/.gitconfig"

  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  [ -f "${tmp_home}/.zshrc" ]
  [ ! -L "${tmp_home}/.zshrc" ]
  [ -f "${tmp_home}/.zshenv" ]
  [ ! -L "${tmp_home}/.zshenv" ]
  [ -f "${tmp_home}/.gitconfig" ]
  [ ! -L "${tmp_home}/.gitconfig" ]
}

@test "re-running install does not duplicate managed blocks" {
  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  run env "${install_env[@]}" "${install_command[@]}"
  [ "${status}" -eq 0 ]

  run grep -c '^# >>> ~/.dotfiles/install.sh >>>$' "${tmp_home}/.zshrc"
  [ "${status}" -eq 0 ]
  [ "${output}" -eq 1 ]

  run grep -c '^# >>> ~/.dotfiles/install.sh >>>$' "${tmp_home}/.zshenv"
  [ "${status}" -eq 0 ]
  [ "${output}" -eq 1 ]

  run grep -c '^# >>> ~/.dotfiles/install.sh >>>$' "${tmp_home}/.gitconfig"
  [ "${status}" -eq 0 ]
  [ "${output}" -eq 1 ]
}
