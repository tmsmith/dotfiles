#!/usr/bin/env bash
# Install .NET SDK channels via the bin/install-dotnet wrapper. Leave the
# versions array empty to install the latest. To add channels later, edit
# this list — `run_onchange_` will detect the content change.
set -euo pipefail

# Channels to install. Examples: 8.0, 9.0, LTS, STS. Empty = latest.
versions=()

echo ">>> Installing .NET"
# ${versions[@]+...} guards against the bash 3.2 + set -u quirk where an
# empty array reference is treated as unbound. Expands to nothing when the
# array is empty, to the elements when not.
"$HOME/bin/install-dotnet" ${versions[@]+"${versions[@]}"}
echo ".NET installed to \$HOME/.dotnet"