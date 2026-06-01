if [ "$(command -v zoxide)" ]; then
	eval "$(zoxide init zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

zle -N newtab
[ -f "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$HOME/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"