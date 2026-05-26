# install Homebrew
log::step "Installing Homebrew"

export NONINTERACTIVE=1

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ln -sf $brew_repo/bin/brew /usr/local/bin/brew

export PATH=/opt/homebrew/bin:$PATH

brew update --force

# install and upgrade from Brewfile
if [ -f "${0:a:h}/Brewfile" ]; then
  log::step "Installing from Brewfile"
  brew bundle check --file="${0:a:h}/Brewfile" || brew bundle --file="${0:a:h}/Brewfile"
  log::g "Brews installed/updated"
fi
