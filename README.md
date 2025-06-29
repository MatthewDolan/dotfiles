# Dotfiles

These dotfiles include a Hermit environment used to manage tooling like ShellCheck.

## Installation

Run the installer from a local checkout:

```bash
./install.sh
```

Alternatively, run it directly with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/MatthewDolan/dotfiles/main/install.sh | bash
```

You can also fetch the installer from GitHub Pages:

```bash
curl -fsSL https://matthewdolan.github.io/dotfiles/install.sh | bash
```

When executed via `curl` or from outside the repository, the installer clones this repository to `~/.dotfiles` before continuing.

## Testing

Activate the included [Hermit](https://github.com/cashapp/hermit) environment and run the tests with:

```bash
. ./bin/activate-hermit
./ci/test.sh
```

ShellCheck and Bats are installed via [MatthewDolan/hermit-packages](https://github.com/MatthewDolan/hermit-packages). Running the script invokes `bats` on the test suite under `tests/`.
