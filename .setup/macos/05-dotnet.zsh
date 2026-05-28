#!/usr/bin/env zsh

# .NET SDK channels to install on first setup (e.g. 8.0, 9.0, LTS, STS).
# Leave empty to install the latest.
# To add versions later, run: install-dotnet <channel> [<channel> ...]
local versions=()

log::step "Installing .NET"
"$DF/bin/install-dotnet" $versions
log::g ".NET installed to \$HOME/.dotnet"