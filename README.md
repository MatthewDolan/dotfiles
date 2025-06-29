# Dotfiles

These dotfiles include a Hermit environment used to manage tooling like ShellCheck.

## Testing

First ensure you have [Hermit](https://github.com/cashapp/hermit) installed and initialise the environment:

```bash
./bin/hermit init
hermit install shellcheck
```

Install [Bats](https://bats-core.readthedocs.io) (e.g. `apt-get install bats` or `brew install bats-core`).

Run the tests with:

```bash
./ci/test.sh
```

This invokes `bats` on the test suite under `tests/`.
