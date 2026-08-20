# rigorish

Opt-in shell environment helpers for a fresh Mac. Small zsh features you enable
à la carte — no dotfile spelunking, just `brew install` and one command per
feature you want.

Basically, I don't like typing `3` after `python` or `pip`, and I especially don't
like typing `source .venv/bin/activate`. Let's skip that step.

## Install

```bash
brew tap raocow/tap      # once
brew install rigorish
```

Then enable the features you want (this writes a line to your `~/.zshrc` — an
extra step by design, since you may not want auto-venv in every repo):

```bash
rigorish enable autovenv        # per-repo .venv auto-activation
rigorish enable pyf             # bare python/pip -> python3/pip3
rigorish enable                 # everything
exec zsh                     # apply to the current shell
```

`rigorish status` shows what's enabled; `rigorish disable <feature>` turns one off;
`rigorish doctor` shows the resolved python/pip/venv. (`install`/`uninstall` still
work as aliases for `enable`/`disable`.)

Two commands are not zsh features and touch nothing in your rc file:
`rigorish push` (agent notifications on your phone) and `rigorish sleep`.

<details>
<summary>Manual / advanced</summary>

`rigorish enable` just appends a `source` line. To wire it up yourself instead:

```sh
eval "$(rigorish init autovenv)"                      # in ~/.zshrc
source "$(brew --prefix)/share/rigorish/rigorish.zsh"    # or source directly (all features)
```
</details>

## Features

| Feature | What it does |
|---|---|
| `autovenv` | On every `cd`, activates the nearest `.venv` found walking up from the current dir, and deactivates on leaving. Opt-in by presence of a `.venv`, so it only fires in repos where you created one. The current directory wins: leaving every `.venv` scope deactivates whatever is active — including a venv auto-activated by your editor. **On `enable`, it offers to turn off VSCode/Cursor's own terminal venv auto-activation** (`python.terminal.activateEnvironment`, user-level) so autovenv is the sole manager and no venv leaks into dirs that have none; `disable` offers to undo it. Edits are backed up (`.rigorish-bak`). |
| `pyf` | Symlinks `python`→`python3` and `pip`→`pip3` in a managed shim dir appended to `PATH`. Real interpreters and active virtualenvs always take precedence. (Formerly `py-fallback`, still accepted as an alias.) |
| `envup` | Adds an `envup` command that exports a `.env` into the current shell — `envup` loads `./.env`, `envup path/to/file` a specific one. Shorthand for `set -a; source <file>; set +a`. (A sourced function, not a `rigorish` subcommand — a subprocess can't export back into your shell. Named `envup`, not `dotenv`, to avoid shadowing the python-dotenv CLI.) |

## Accounts moved to gitplus

Per-directory git/ssh/GitHub identities used to live here as `devrig account`.
They are now `git account`, part of [gitplus](https://github.com/raocow/gitplus).

They moved because every `git-*` command needs to resolve the bound account
before calling `gh`, which made this package a hard runtime dependency of the
git tooling and forced the two to be released together. The rest of rigorish has
nothing to do with git, so only the git-shaped parts went — `ghswitch` with them.

**Nothing to redo.** `git account` reads the config this wrote, so existing
accounts and bindings keep working untouched.

## Push

Notify your phone when a Claude Code or Codex turn ends, so you stop
babysitting a terminal that is going to take four minutes.

```bash
rigorish push setup             # wire this machine, print the topic to subscribe to
rigorish push test              # send one and confirm it arrived
rigorish push status            # what's wired, and where
rigorish push off               # unwire, restoring whatever was there before
```

Install the [ntfy](https://ntfy.sh) app on your phone and subscribe to the topic
`setup` prints. On your other machines, join the same topic so one subscription
covers all of them:

```bash
rigorish push setup --topic <the-topic> --device work-mini
```

Every notification is titled with the project and the machine
(`Claude Code — myrepo @ work-mini`), so several machines stay legible in one
feed. Claude Code notifies when a turn ends **and** whenever it is blocked
waiting on you; Codex notifies when a turn ends. Turns shorter than 60 seconds
stay quiet, on the theory that you had not walked away yet
(`RIGORISH_PUSH_MIN_SECONDS` in `~/.config/rigorish/push.env`).

**The topic name is the only thing protecting the feed on public ntfy.sh.** It
lives in `~/.config/rigorish/push.env`, mode 600, and `rigorish push status` masks
it unless you pass `--show`. Point `--server` at your own ntfy if you would
rather not use the public one.

`setup` edits Claude Code's `~/.claude/settings.json` and Codex's
`~/.codex/config.toml`, backing each up first (`.rigorish-bak`). Codex allows one
`notify` program, and on a Mac with the ChatGPT app installed its own desktop
notifier already holds that slot — so rigorish parks that command and replays it
before pushing, leaving desktop notifications working. `rigorish push off` hands
the slot back. Both are safe to re-run: they replace their own entries instead
of stacking new ones.

Needs `curl` and `perl` (both already on macOS). Deliberately not `jq`, so the
package stays dependency-free for everyone who does not use this feature.

## Sleep

```bash
rigorish sleep off       # sudo pmset -a disablesleep 1 — keep the Mac awake
rigorish sleep on        # sudo pmset -a disablesleep 0 — put it back
rigorish sleep status    # what's it set to right now
```

A memorable name for a command that's easy to forget the flag/argument order
of. `off`/`on` needs `sudo` (same as the raw `pmset` call); `status` doesn't.

## Disable / uninstall

```bash
rigorish disable autovenv    # turn off one feature
rigorish disable all         # remove all rigorish lines from ~/.zshrc
brew uninstall rigorish
```

A feature (or `all`) is required — a bare `rigorish disable` won't wipe everything
by accident. `rigorish disable pyf` also removes its shim dir
(`~/.local/share/rigorish/shims`, override with `RIGORISH_SHIM_DIR`), leaving nothing behind.

## License

MIT
