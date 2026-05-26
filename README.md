# .files

Personal macOS dotfiles. Symlinks config files into `$HOME`, sets up zsh, and installs apps via Homebrew.

## Setup

On a fresh Mac, git is not yet available. Use `curl` (pre-installed on macOS) to bootstrap — the installer will handle Xcode and everything else.

### 1. Download and install

```sh
curl -fsSL https://github.com/tmsmith/dotfiles/archive/refs/heads/master.tar.gz | tar -xz
mv dotfiles-master ~/.files
cd ~/.files
zsh .setup/installMac
```

This will install Xcode Command Line Tools (including git), Homebrew, and all packages before symlinking your dotfiles.

### 2. Initialize git and pull submodules

Once the installer finishes, git is available via Homebrew. Convert the directory into a proper repo and pull in the zsh plugin submodules:

```sh
cd ~/.files
git init
git remote add origin https://github.com/tmsmith/dotfiles.git
git fetch
git checkout master
git submodule update --init
```

### 3. Set your git identity

Git identity lives in `private/gitconfig.local`, which is not committed. Create it, then re-run the linker to symlink it (and anything else in `private/`):

```sh
cat > ~/.files/private/gitconfig.local << 'EOF'
[user]
  name = Your Name
  email = you@example.com
EOF

cd ~/.files/.setup && source core.zsh && DF=~/.files df::install
```

### 4. Reload your shell

```sh
exec zsh
```

---

### Already have git? (re-install / update)

```sh
git clone --recurse-submodules https://github.com/tmsmith/dotfiles ~/.files
cd ~/.files
zsh .setup/installMac
```

---

## What the installer does

1. **Xcode CLI tools** — installs if not already present
2. **Shell** — ensures zsh is the default shell
3. **macOS defaults** — applies system preferences (Dock, Finder, screenshots, etc.)
4. **Homebrew** — installs Homebrew, then runs `brew bundle` from the Brewfile
5. **Dotfiles** — symlinks everything in `home/` and `private/` into `$HOME`
6. **Fonts** — rsyncs `home/fonts/` into `~/Library/Fonts/`

> The installer keeps `sudo` alive for the duration so you won't be re-prompted.

---

## What gets installed

### CLI tools (Homebrew)

| Package | Purpose |
|---|---|
| `ack` | Code search |
| `awscli` | AWS CLI |
| `curl` | HTTP client |
| `findutils` | GNU find/xargs |
| `fzf` | Fuzzy finder |
| `gh` | GitHub CLI |
| `git` | Version control |
| `gnu-sed` / `gnu-tar` | GNU coreutils |
| `go` | Go language |
| `jq` | JSON processor |
| `make` | Build tool |
| `mas` | Mac App Store CLI |
| `node` | Node.js |
| `python@3.9` | Python |
| `rsync` | File sync |
| `starship` | Shell prompt |
| `tldr` | Simplified man pages |
| `watch` | Run commands repeatedly |
| `zoxide` | Smarter `cd` |

### Apps (Homebrew Cask)

| App | Purpose |
|---|---|
| 1Password | Password manager |
| Discord | Chat |
| Docker | Containers |
| .NET SDK | .NET development |
| Hammerspoon | macOS automation |
| Insomnia | REST/API client |
| iTerm2 | Terminal |
| Royal TSX | Remote connections |
| Spotify | Music |
| Sublime Text | Text editor |
| Visual Studio Code | Code editor |

### Zsh plugins (submodules)

| Plugin | Purpose |
|---|---|
| `zsh-syntax-highlighting` | Shell syntax highlighting |
| `zsh-autosuggestions` | Fish-style command suggestions |

---

## What gets symlinked

Everything in `home/` is symlinked to `~/.{filename}`:

| File | Destination |
|---|---|
| `home/zshrc` | `~/.zshrc` |
| `home/zshenv` | `~/.zshenv` |
| `home/gitconfig` | `~/.gitconfig` |
| `home/curlrc` | `~/.curlrc` |
| `home/wgetrc` | `~/.wgetrc` |
| `home/starship` | `~/.starship` |
| `home/hammerspoon/` | `~/.hammerspoon/` |
| `home/iterm2/` | `~/.iterm2/` |
| `home/fonts/` | synced to `~/Library/Fonts/` |

Private files (not committed) go in `private/` and are symlinked the same way.

---

## macOS defaults applied

- Finder shows hidden files, status bar, external drives
- Screenshots saved to `~/Desktop/Screenshots` as PNG (no shadow)
- Dock auto-hides, no animation delay, icons at 42px, minimizes to app icon
- Save/print panels expanded by default
- Saves go to disk, not iCloud
- Bluetooth audio quality increased
- Password required immediately on sleep/screensaver
- Hot corners: top-left → Mission Control, top-right → Screensaver, bottom-left → Desktop

---

## Structure

```
.files/
├── .setup/
│   ├── installMac          # Main entry point
│   ├── _install            # Core install logic (linking, fonts)
│   ├── core.zsh            # Utilities (logging, df::link)
│   └── macos/
│       ├── 00-xcode.zsh    # Xcode CLI tools
│       ├── 01-shell.zsh    # Shell setup
│       ├── 02-settings.zsh # macOS defaults
│       ├── 03-homebrew.zsh # Homebrew + Brewfile
│       └── Brewfile        # Package list
├── home/                   # Config files → symlinked to ~/
├── private/                # Private configs → symlinked to ~/ (not committed)
└── zsh/                    # Zsh plugin scripts and submodules
```
