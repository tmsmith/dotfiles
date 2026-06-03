# .files

Personal macOS dotfiles managed by [chezmoi](https://chezmoi.io).

## Fresh-machine setup

On a new mac, one command:

```sh
curl -fsSL https://raw.githubusercontent.com/tmsmith/dotfiles/master/bootstrap.sh | sh
```

`bootstrap.sh` installs Xcode Command Line Tools (for git), chezmoi (standalone, into `~/bin`), then runs `chezmoi init --apply tmsmith/dotfiles`. Everything else — Homebrew install, brew bundle, .NET install, VSCode profile setup, macOS defaults — runs from chezmoi's `run_*` scripts inside the source tree.

The full apply takes ~25–35 minutes unattended after one sudo prompt at the start.

## Layout

```
.files/
├── bootstrap.sh                # fresh-machine entry point
├── .chezmoiroot                # tells chezmoi the source lives in chezmoi/
└── chezmoi/
    ├── .chezmoi.toml.tmpl      # prompts for name + email on init
    ├── .chezmoiexternal.toml   # zsh plugin externals (replaces submodules)
    ├── .chezmoiignore          # excludes Brewfile + vscode/ from auto-apply
    ├── Brewfile                # consumed by the brew-bundle run-script
    ├── dot_zshrc, dot_zshenv   # → ~/.zshrc, ~/.zshenv
    ├── dot_gitconfig.tmpl      # templated git identity
    ├── dot_curlrc, dot_gemrc, dot_irbrc, dot_starship, dot_wgetrc
    ├── dot_hammerspoon/        # → ~/.hammerspoon/
    ├── dot_claude/             # → ~/.claude/ (tracked subset only)
    ├── dot_iterm2/             # → ~/.iterm2/
    ├── dot_zsh/                # → ~/.zsh/ (sourced by zshrc)
    ├── dot_local/bin/          # → ~/.local/bin/ (install-dotnet, etc.)
    ├── vscode/                 # source for VSCode profile run-script
    │                           # (symlinked into ~/Library/Application Support/Code/User/)
    ├── run_once_before_020-set-default-shell.sh
    ├── run_once_before_030-install-brew.sh
    ├── run_onchange_before_040-brew-bundle.sh.tmpl
    ├── run_onchange_050-macos-defaults.sh
    ├── run_onchange_060-macos-dock.sh
    ├── run_onchange_070-install-dotnet.sh
    └── run_onchange_080-setup-vscode.sh.tmpl
```

## Day-to-day

| Goal | Command |
|---|---|
| Pull latest dotfiles and apply | `chezmoi update` |
| Edit a managed file in-place | `chezmoi edit ~/.zshrc` |
| See what would change | `chezmoi diff` |
| Apply changes you made in source | `chezmoi apply` |
| Add a new file to be managed | `chezmoi add ~/.somerc` |
| Find a managed file's source | `chezmoi source-path ~/.zshrc` |

## What gets installed

**CLI tools** (from `chezmoi/Brewfile`): ack, azcopy, azure-cli, curl, diff-so-fancy, findutils, fzf, gh, git, gnu-sed, gnu-tar, go, htop, jq, libssh2, make, mas, node, podman, podman-compose, sqlcmd, pipx, python@3.9, rsync, starship, tldr, watch, zoxide.

**Apps** (Homebrew casks): 1Password, Another Redis Desktop, Claude, cmux, Cyberduck, Discord, Google Chrome, Hammerspoon, iTerm2, Logi Options+, Microsoft Azure Storage Explorer, Microsoft Office, Microsoft Teams, Postman, Rectangle, Royal TSX, Spotify, Sublime Text, UTM, Visual Studio Code, Zoom.

**Mac App Store**: Tailscale.

**VSCode profiles** (set up by `run_onchange_080-setup-vscode.sh.tmpl`):
- **Default** (always-on) — Claude Code, Prettier, Rainbow CSV, Partial Diff, Mermaid Markdown, Drawio.
- **Vue/NET/MSSQL** stack — Default + .NET (C# Dev Kit, IntelliCode-ish), Frontend (ESLint, Vue/Volar), Data/SQL (4 MSSQL/sqlfluff extensions), Azure (Functions, Resource Groups).

**.NET SDK** via Microsoft's official `dotnet-install.sh` (installed to `~/.dotnet`).

**Zsh plugins** (cloned per machine via `chezmoi/.chezmoiexternal.toml`, no submodules): `zsh-syntax-highlighting`, `zsh-autosuggestions`.

**macOS defaults**: Finder shows hidden files / status bar / external drives; screenshots saved as PNG to `~/Desktop/Screenshots` with no shadow; Dock auto-hides with 42px icons, no animation delay, minimizes to app icon; password required immediately on sleep; hot corners (top-left → Mission Control, top-right → Screensaver, bottom-left → Desktop); desktop widgets disabled (Sonoma+).

## Adding things

| To add | Where |
|---|---|
| A new Homebrew formula or cask | `chezmoi/Brewfile` |
| A new VSCode extension to Default | `default_extensions` array in `chezmoi/run_onchange_080-setup-vscode.sh.tmpl` |
| A new VSCode extension to Vue/NET/MSSQL | `vue_net_mssql_extensions` array in same file |
| A new VSCode profile | New `vscode::setup_profile "Name" ext1 ext2 …` call in same file |
| A new .NET channel | `versions=()` array in `chezmoi/run_onchange_070-install-dotnet.sh` |
| A new zsh plugin | `chezmoi/.chezmoiexternal.toml` + source line in `chezmoi/dot_zsh/plugins.zsh` |
| A new dotfile | `chezmoi add <path>` (chezmoi copies it into the source dir with the right naming) |

The `run_onchange_*` scripts re-execute automatically when their content changes — adding to the Brewfile or extension arrays triggers a re-apply on next `chezmoi update`.

## Secrets

Identity (git name + email) is templated via `chezmoi/.chezmoi.toml.tmpl`, which prompts on `chezmoi init`. Values stored in `~/.config/chezmoi/chezmoi.toml` (per machine, not in this repo).

For future templated secrets (e.g. MSSQL connection profiles): plan is to use 1Password CLI via `{{ onepasswordRead "op://..." }}`. Add `brew install 1password-cli` + `op signin` to the bootstrap chain.