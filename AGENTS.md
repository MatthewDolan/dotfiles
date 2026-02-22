# Instructions for Codex Agents

- Always run `./ci/test.sh` after making changes.
- Source the Hermit environment first:
  `. ./bin/activate-hermit`
- Ensure your working tree is clean before committing.
- Use `#!/bin/zsh` as the shebang for all shell scripts (not `#!/bin/bash`).

## Agent installation

- Agent configuration installation lives in `install-agents.sh` (extracted from `install.sh`).
- `install.sh` sources `install-agents.sh` at the end to keep bootstrap flow readable.
- `install-agents.sh` checks SSH access to `DOLAN_AGENTS_REPO_SSH` (default: `git@github.com:MatthewDolan/agents.git`) before cloning or running anything.

## Existing `~/.agents` validation

- If `~/.agents` already exists, `install-agents.sh` validates it is a git repo and that one of its remotes exactly matches `DOLAN_AGENTS_REPO_SSH`.
- If `~/.agents` exists but is not the expected repo, installation exits with an error and prints existing remotes for diagnostics.
