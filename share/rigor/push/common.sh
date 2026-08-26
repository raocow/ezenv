# Shared config resolution for the rigor push scripts. Sourced, not run.
#
# Config lives in ~/.config/rigor/push.env. The standalone installer that
# predated this feature wrote ~/.config/phone-push.env, and its PHONE_PUSH_*
# names are still honored below, so an existing setup keeps working without a
# re-run — same courtesy the rest of rigor extends to its own legacy names.
# ~/.config/rigorish/push.env (the retracted rename) is also checked, in case
# it was ever set up under that name.

push_conf() {
  if [ -n "${RIGOR_PUSH_ENV:-}" ]; then printf '%s' "$RIGOR_PUSH_ENV"; return; fi
  if [ -r "$HOME/.config/rigor/push.env" ]; then
    printf '%s' "$HOME/.config/rigor/push.env"; return
  fi
  if [ -r "$HOME/.config/rigorish/push.env" ]; then
    printf '%s' "$HOME/.config/rigorish/push.env"; return
  fi
  printf '%s' "$HOME/.config/phone-push.env"
}

# Load config into the environment. Returns non-zero when there is no usable
# topic, which every caller treats as "not set up" rather than an error.
push_load() {
  local c; c="$(push_conf)"
  [ -r "$c" ] || return 1
  # shellcheck disable=SC1090
  . "$c" 2>/dev/null || return 1
  NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
  RIGOR_PUSH_DEVICE="${RIGOR_PUSH_DEVICE:-${PHONE_PUSH_DEVICE:-$(hostname -s 2>/dev/null || echo host)}}"
  RIGOR_PUSH_MIN_SECONDS="${RIGOR_PUSH_MIN_SECONDS:-${PHONE_PUSH_MIN_SECONDS:-60}}"
  [ -n "${NTFY_TOPIC:-}" ]
}

# Where the previous Codex notifier's argv is parked. Migrated from the
# standalone installer's location on first use.
push_codex_passthrough() {
  local new="$HOME/.config/rigor/codex-passthrough"
  local old="$HOME/.codex/notify-passthrough"
  if [ ! -f "$new" ] && [ -f "$old" ]; then
    mkdir -p "$(dirname "$new")" 2>/dev/null || true
    cp "$old" "$new" 2>/dev/null || true
  fi
  printf '%s' "$new"
}
