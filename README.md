# Dotfiles

These dotfiles include a Hermit environment used to manage tooling like ShellCheck.

## Testing

Activate the included [Hermit](https://github.com/cashapp/hermit) environment and run the tests with:

```bash
. ./bin/activate-hermit
./ci/test.sh
```

ShellCheck and Bats are installed via [MatthewDolan/hermit-packages](https://github.com/MatthewDolan/hermit-packages). Running the script invokes `bats` on the test suite under `tests/`.
