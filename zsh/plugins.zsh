if [ "$(command -v zoxide)" ]; then
	eval "$(zoxide init zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

zle -N newtab
[ -f "$DF/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$DF/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$DF/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$DF/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"