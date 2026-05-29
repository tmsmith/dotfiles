#!/usr/bin/env zsh

# VSCode on macOS keeps each profile's config under
# ~/Library/Application Support/Code/User/profiles/<hash>/ (Default lives
# directly in .../Code/User/). This script:
#   1. Installs each profile's extensions (auto-creating the profile)
#   2. Symlinks the tracked user config (settings.json, keybindings.json,
#      snippets/) into every profile dir so edits to the dotfile source
#      propagate everywhere.

log::step "Configuring VSCode"

local user_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$user_dir"

# --- Helpers ---------------------------------------------------------------

# Resolve a profile's on-disk data dir by its display name.
# Default lives in $user_dir directly; named profiles live under profiles/<hash>.
vscode::profile_dir() {
  local profile=$1

  if [ "$profile" = "Default" ]; then
    echo "$user_dir"
    return
  fi

  local storage="$user_dir/globalStorage/storage.json"
  [ -f "$storage" ] || return

  local loc=$(jq -r --arg n "$profile" \
    '.userDataProfiles[]? | select(.name == $n) | .location' \
    "$storage" 2>/dev/null)
  [ -n "$loc" ] || return

  echo "$user_dir/profiles/$loc"
}

# Symlink tracked user config into a profile dir.
# If VSCode has auto-created an empty placeholder (just "{}" or empty),
# remove it first so df::link can create the symlink.
vscode::link_config() {
  local prof_dir=$1
  [ -d "$prof_dir" ] || return

  local f
  for f in settings.json keybindings.json; do
    local src="$DF/home/vscode/$f"
    local dst="$prof_dir/$f"
    [ -f "$src" ] || continue

    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
      local content=$(tr -d '[:space:]' < "$dst")
      if [[ "$content" == "{}" || "$content" == "[]" || -z "$content" ]]; then
        rm "$dst"
      fi
    fi
    df::link "$src" "$dst"
  done

  if [ -d "$DF/home/vscode/snippets" ]; then
    if [ -d "$prof_dir/snippets" ] && [ ! -L "$prof_dir/snippets" ]; then
      [ -z "$(ls -A "$prof_dir/snippets" 2>/dev/null)" ] && rmdir "$prof_dir/snippets"
    fi
    df::link "$DF/home/vscode/snippets" "$prof_dir/snippets"
  fi
}

# Install a list of extensions into a profile, then link user config into it.
# Auto-creates the profile on VSCode 1.86+ if it doesn't exist.
vscode::setup_profile() {
  local profile=$1; shift

  log::b "Profile: $profile"
  for ext in "$@"; do
    code --profile "$profile" --install-extension "$ext" >/dev/null
  done

  local prof_dir=$(vscode::profile_dir "$profile")
  [ -n "$prof_dir" ] && vscode::link_config "$prof_dir"
}

# --- Profiles --------------------------------------------------------------
#
# Profiles are named after the *tech stack* (so multiple projects can share
# one), not the project. Associate a profile with a project via VSCode:
# Cog → Profiles → assign to current folder.

# Default — always-on across every workspace.
# Named profiles inherit this list as a base (union below).
default_extensions=(
  anthropic.claude-code
  esbenp.prettier-vscode
  mechatroner.rainbow-csv
  ryu1kn.partial-diff
  bpruitt-goddard.mermaid-markdown-syntax-highlighting
  hediet.vscode-drawio
)

# Vue/NET/MSSQL stack (used by Phoenix CRM, etc.) — stack-specific only;
# default extensions get unioned in when the profile is set up below.
vue_net_mssql_extensions=(
  ms-dotnettools.csdevkit
  ms-dotnettools.csharp
  ms-dotnettools.vscode-dotnet-runtime
  dbaeumer.vscode-eslint
  vue.volar
  ms-mssql.data-workspace-vscode
  ms-mssql.mssql
  ms-mssql.sql-bindings-vscode
  sqlfluff.vscode-sqlfluff
  ms-azuretools.vscode-azurefunctions
  ms-azuretools.vscode-azureresourcegroups
)

vscode::setup_profile "Default" "${default_extensions[@]}"
vscode::setup_profile "Vue/NET/MSSQL" \
  "${default_extensions[@]}" \
  "${vue_net_mssql_extensions[@]}"

# Vue/NET/MSSQL — optional extras from the Windows install, not installed by
# default. Uncomment and re-run if you find you need them on a given machine:
#   ms-mssql.sql-database-projects-vscode    SQL Database Projects (mssql companion)
#   ms-dotnettools.vscodeintellicode-csharp  IntelliCode AI assistance for C#
#   cweijan.vscode-database-client2          DB client UI
#   cweijan.dbclient-jdbc                    JDBC backend for vscode-database-client2
#   dineug.vuerd-vscode                      ER diagram authoring
#   kaishuu0123.vscode-erd-preview           ER diagram preview
#   azurite.azurite                          Local Azure Storage emulator

log::g "VSCode configured"
