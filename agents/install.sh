#!/bin/zsh
set -euo pipefail

install_agents_configuration() {
  # Keep variables local so this helper can be safely sourced by install.sh.
  local agents_repo
  local agents_target
  local current_sha
  local matching_remote
  local remote_name
  local remote_url
  local current_remotes

  # Allow overriding the default agents repository for forks/tests.
  agents_repo="${DOLAN_AGENTS_REPO_SSH:-git@github.com:MatthewDolan/agents.git}"
  agents_target="${HOME}/.agents"

  # Reuse existing checkout when present, but only after validating identity.
  if [[ -e "${agents_target}" ]]; then
    if [[ ! -d "${agents_target}" ]]; then
      echo "Cannot install agent configuration: ${agents_target} exists and is not a directory."
      return 1
    fi

    if ! git -C "${agents_target}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "Cannot install agent configuration: ${agents_target} exists but is not a git repository."
      return 1
    fi

    # Verify at least one configured remote points at the expected repo.
    matching_remote=""
    for remote_name in $(git -C "${agents_target}" remote); do
      remote_url="$(git -C "${agents_target}" remote get-url "${remote_name}" 2>/dev/null || true)"
      if [[ -z "${remote_url}" ]]; then
        continue
      fi

      if [[ "${remote_url}" == "${agents_repo}" ]]; then
        matching_remote="${remote_name}"
        break
      fi
    done

    # Refuse to run unknown repo code if ~/.agents points somewhere else.
    if [[ -z "${matching_remote}" ]]; then
      echo "Cannot install agent configuration: ${agents_target} is a git repository, but it does not match ${agents_repo}."
      current_remotes="$(git -C "${agents_target}" remote -v || true)"
      if [[ -n "${current_remotes}" ]]; then
        echo "Current remotes for ${agents_target}:"
        echo "${current_remotes}"
      else
        echo "Current remotes for ${agents_target}: none configured."
      fi
      return 1
    fi

    current_sha="$(git -C "${agents_target}" rev-parse --short HEAD 2>/dev/null || echo "unknown")"
    echo "Using existing agents repository at ${agents_target} (matched remote: ${matching_remote}, sha: ${current_sha}; no fetch/pull)..."
  else
    # No existing checkout. Confirm SSH access before cloning.
    echo "Checking SSH access to ${agents_repo}..."
    if ! git ls-remote --exit-code "${agents_repo}" >/dev/null 2>&1; then
      echo "No SSH access to ${agents_repo}; cannot install agent configuration."
      return 0
    fi

    # Clone after access has been confirmed.
    echo "Cloning agents repository to ${agents_target}..."
    git clone "${agents_repo}" "${agents_target}"
  fi

  # Source the script (instead of spawning) so any exported environment
  # changes from the agents install remain in the current shell context.
  if [[ -f "${agents_target}/install.sh" ]]; then
    echo "Running agent configuration install script..."
    . "${agents_target}/install.sh"
  else
    echo "Cannot install agent configuration: ${agents_target}/install.sh not found."
  fi
}

install_agents_configuration
