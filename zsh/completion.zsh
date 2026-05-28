# Case-insensitive + substring matching for tab completion.
# Matchers tried in order:
#   m:{a-zA-Z-_}={A-Za-z_-}  case-insensitive
#   r:|=*                    match suffix anywhere on right
#   l:|=* r:|=*              substring (matches "work" inside "Phoenix.code-workspace")
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z-_}={A-Za-z_-}' \
  'r:|=*' \
  'l:|=* r:|=*'

# Group results by type and show section headings
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Cache completion data (speeds up large completions like kubectl)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh-completion"
