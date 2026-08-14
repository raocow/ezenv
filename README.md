# devrig

Opt-in shell environment helpers for a fresh Mac. Small zsh features you enable
à la carte — no dotfile spelunking, just `brew install` and one command per
feature you want.

Basically, I don't like typing `3` after `python` or `pip`, and I especially don't
like typing `source .venv/bin/activate`. Let's skip that step.

## Install

```bash
brew tap raocow/tap      # once
brew install devrig
```

Then enable the features you want (this writes a line to your `~/.zshrc` — an
extra step by design, since you may not want auto-venv in every repo):

```bash
devrig enable autovenv        # per-repo .venv auto-activation
devrig enable pyf             # bare python/pip -> python3/pip3
devrig enable                 # everything
exec zsh                     # apply to the current shell
```

`devrig status` shows what's enabled; `devrig disable <feature>` turns one off;
`devrig doctor` shows the resolved python/pip/venv. (`install`/`uninstall` still
work as aliases for `enable`/`disable`.)

<details>
<summary>Manual / advanced</summary>

`devrig enable` just appends a `source` line. To wire it up yourself instead:

```sh
eval "$(devrig init autovenv)"                      # in ~/.zshrc
source "$(brew --prefix)/share/devrig/devrig.zsh"    # or source directly (all features)
```
</details>

## Features

| Feature | What it does |
|---|---|
| `autovenv` | On every `cd`, activates the nearest `.venv` found walking up from the current dir, and deactivates on leaving. Opt-in by presence of a `.venv`, so it only fires in repos where you created one. The current directory wins: leaving every `.venv` scope deactivates whatever is active — including a venv auto-activated by your editor. **On `enable`, it offers to turn off VSCode/Cursor's own terminal venv auto-activation** (`python.terminal.activateEnvironment`, user-level) so autovenv is the sole manager and no venv leaks into dirs that have none; `disable` offers to undo it. Edits are backed up (`.devrig-bak`). |
| `pyf` | Symlinks `python`→`python3` and `pip`→`pip3` in a managed shim dir appended to `PATH`. Real interpreters and active virtualenvs always take precedence. (Formerly `py-fallback`, still accepted as an alias.) |
| `envup` | Adds an `envup` command that exports a `.env` into the current shell — `envup` loads `./.env`, `envup path/to/file` a specific one. Shorthand for `set -a; source <file>; set +a`. (A sourced function, not an `devrig` subcommand — a subprocess can't export back into your shell. Named `envup`, not `dotenv`, to avoid shadowing the python-dotenv CLI.) |

## Accounts moved to gitplus

Per-directory git/ssh/GitHub identities used to live here as `devrig account`.
They are now `git account`, part of [gitplus](https://github.com/raocow/gitplus).

They moved because every `git-*` command needs to resolve the bound account
before calling `gh`, which made this package a hard runtime dependency of the
git tooling and forced the two to be released together. The rest of devrig has
nothing to do with git, so only the git-shaped parts went — `ghswitch` with them.

**Nothing to redo.** `git account` reads the config this wrote, so existing
accounts and bindings keep working untouched.

## Sleep

```bash
devrig sleep off       # sudo pmset -a disablesleep 1 — keep the Mac awake
devrig sleep on        # sudo pmset -a disablesleep 0 — put it back
devrig sleep status    # what's it set to right now
```

A memorable name for a command that's easy to forget the flag/argument order
of. `off`/`on` needs `sudo` (same as the raw `pmset` call); `status` doesn't.

## Disable / uninstall

```bash
devrig disable autovenv    # turn off one feature
devrig disable all         # remove all devrig lines from ~/.zshrc
brew uninstall devrig
```

A feature (or `all`) is required — a bare `devrig disable` won't wipe everything
by accident. `devrig disable pyf` also removes its shim dir
(`~/.local/share/devrig/shims`, override with `DEVRIG_SHIM_DIR`), leaving nothing behind.

## License

MIT
