#!/usr/bin/env bash
#
# Audit VSCode profile state against the chezmoi source. Reports:
#   - Extension drift per profile (missing from machine, or extras not
#     in source's extension arrays).
#   - Settings drift per profile (unified diff of each profile's
#     settings.json against the tracked source's vscode/settings.json).
#
# Read-only. Reports differences; doesn't change anything.
#
# Usage:
#   audit-vscode.sh

set -eu
# Deliberately NOT pipefail: `diff` returns non-zero when files differ,
# which is the expected outcome here, not a failure.

# Color setup — enable only when stdout is a TTY and the terminal supports it
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_RED=$(tput setaf 1)
  C_GREEN=$(tput setaf 2)
  C_YELLOW=$(tput setaf 3)
  C_DIM=$(tput dim 2>/dev/null || echo "")
  C_BOLD=$(tput bold)
  C_RESET=$(tput sgr0)
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_DIM=""; C_BOLD=""; C_RESET=""
fi

SOURCE_DIR="$(chezmoi source-path 2>/dev/null || true)"
if [ -z "$SOURCE_DIR" ]; then
  echo "chezmoi source-path returned nothing — is chezmoi configured?" >&2
  exit 1
fi

SETUP_SCRIPT="$SOURCE_DIR/run_onchange_080-setup-vscode.sh.tmpl"
SOURCE_SETTINGS="$SOURCE_DIR/vscode/settings.json"

if [ ! -f "$SETUP_SCRIPT" ]; then
  echo "Setup script not found at: $SETUP_SCRIPT" >&2
  exit 1
fi

if [ ! -f "$SOURCE_SETTINGS" ]; then
  echo "Source settings.json not found at: $SOURCE_SETTINGS" >&2
  exit 1
fi

USER_DIR="$HOME/Library/Application Support/Code/User"
STORAGE="$USER_DIR/globalStorage/storage.json"

# Keys removed from both sides before the settings diff. These are keys we
# deliberately don't track (sync-vscode-settings.sh strips them from source
# too), so showing them as drift is just noise. Keep this list in sync with
# sync-vscode-settings.sh.
IGNORE_KEYS_JQ='
    del(.["mssql.connections"])
  | del(.["mssql.connectionGroups"])
'

# --- Helpers ----------------------------------------------------------------

# Extract a bash array literal from the setup script.
# Usage: extract_array default_extensions
# Prints one element per line, ignoring blank lines and #-comments.
extract_array() {
  local name="$1"
  awk -v name="$name" '
    $0 ~ ("^" name "=\\(") { in_arr=1; next }
    in_arr && /^\)/        { in_arr=0; next }
    in_arr {
      sub(/^[[:space:]]+/, "")
      sub(/[[:space:]]*#.*$/, "")
      if (length > 0) print
    }
  ' "$SETUP_SCRIPT"
}

# Resolve a profile's settings.json path. Default lives at the user dir;
# named profiles live under profiles/<hash>/.
profile_settings_path() {
  local name="$1"
  if [ "$name" = "Default" ]; then
    echo "$USER_DIR/settings.json"
    return 0
  fi
  [ -f "$STORAGE" ] || return 1
  local loc
  loc=$(jq -r --arg n "$name" \
        '.userDataProfiles[]? | select(.name == $n) | .location' \
        "$STORAGE" 2>/dev/null) || return 1
  [ -z "$loc" ] && return 1
  echo "$USER_DIR/profiles/$loc/settings.json"
}

# Compare two sorted lists, print missing/extra.
# Args: <profile-name> <expected-newline-separated> <installed-newline-separated>
report_extension_diff() {
  local name="$1" expected="$2" installed="$3"

  local missing extra
  missing=$(comm -23 <(echo "$expected" | sort -u) <(echo "$installed" | sort -u))
  extra=$(comm -13 <(echo "$expected" | sort -u) <(echo "$installed" | sort -u))

  if [ -z "$missing" ] && [ -z "$extra" ]; then
    local count
    count=$(echo "$expected" | grep -c .)
    printf "  %s✓ extensions match source%s (%d expected)\n" "$C_GREEN" "$C_RESET" "$count"
    return
  fi

  if [ -n "$missing" ]; then
    printf "  %s✗ missing (in source, not installed):%s\n" "$C_RED" "$C_RESET"
    echo "$missing" | sed "s/^/      ${C_RED}- /;s/\$/${C_RESET}/"
  fi
  if [ -n "$extra" ]; then
    printf "  %s⚠ extra (installed, not in source):%s\n" "$C_YELLOW" "$C_RESET"
    echo "$extra" | sed "s/^/      ${C_YELLOW}+ /;s/\$/${C_RESET}/"
  fi
}

report_settings_diff() {
  local name="$1" settings_path="$2"

  if [ -z "$settings_path" ]; then
    echo "  (settings.json not found for profile)"
    return
  fi
  if [ ! -f "$settings_path" ]; then
    echo "  (no settings.json at $settings_path)"
    return
  fi

  # Normalize via jq (sort keys, canonical indentation) and strip the keys
  # we don't track on either side so indentation / key-order / known-extension-
  # writeback differences don't pollute the content diff.
  local norm_src norm_dst
  norm_src=$(jq -S "$IGNORE_KEYS_JQ" "$SOURCE_SETTINGS" 2>/dev/null) \
    || { echo "  (source settings.json is not valid JSON)"; return; }
  norm_dst=$(jq -S "$IGNORE_KEYS_JQ" "$settings_path" 2>/dev/null) \
    || { echo "  (profile settings.json is not valid JSON)"; return; }

  if [ "$norm_src" = "$norm_dst" ]; then
    printf "  %s✓ settings.json identical to source (content)%s\n" "$C_GREEN" "$C_RESET"
    return
  fi

  printf "  %s✗ settings.json drift%s (%s- source%s / %s+ profile%s):\n" \
    "$C_RED" "$C_RESET" "$C_RED" "$C_RESET" "$C_GREEN" "$C_RESET"
  # diff returns non-zero when files differ — capture output, don't propagate
  local diff_output
  diff_output=$(diff -u <(echo "$norm_src") <(echo "$norm_dst") || true)
  # Colorize diff: -lines red, +lines green, hunk headers dim
  echo "$diff_output" | tail -n +3 | awk -v R="$C_RED" -v G="$C_GREEN" -v D="$C_DIM" -v N="$C_RESET" '
    /^-/ { print "      " R $0 N; next }
    /^\+/ { print "      " G $0 N; next }
    /^@@/ { print "      " D $0 N; next }
    { print "      " $0 }
  '
}

audit_profile() {
  local name="$1"; shift
  local expected_extensions="$1"

  printf "%s=== %s ===%s\n" "$C_BOLD" "$name" "$C_RESET"

  local installed
  if ! installed=$(code --profile "$name" --list-extensions 2>/dev/null); then
    echo "  (could not list extensions — profile may not exist on this machine)"
    return
  fi

  report_extension_diff "$name" "$expected_extensions" "$installed"

  local settings_path
  settings_path=$(profile_settings_path "$name" 2>/dev/null || true)
  report_settings_diff "$name" "$settings_path"
  echo
}

# --- Main -------------------------------------------------------------------

default_extensions=$(extract_array default_extensions)
vue_net_mssql_extensions=$(extract_array vue_net_mssql_extensions)

# Vue/NET/MSSQL profile inherits Default (see setup-vscode.sh.tmpl) — so its
# expected set is the union of both arrays.
vue_combined=$(printf '%s\n%s\n' "$default_extensions" "$vue_net_mssql_extensions" \
               | grep -v '^$' | sort -u)

audit_profile "Default" "$default_extensions"
audit_profile "Vue/NET/MSSQL" "$vue_combined"
