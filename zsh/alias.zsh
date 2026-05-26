#alias
alias cls='clear'
alias x='exit'
alias k='kubectl'
alias uuidgenl='uuidgen | tr "[:upper:]" "[:lower:]"'

# Get week number
alias week='date +%V'

# URL-encode strings
alias encodeurl='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
alias eurl=encodeurl

alias decodeurl='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1]);"'
alias durl=decodeurl

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

# List directory contents
alias ll='ls -laFsh'

alias mktmp='cd $(mktemp -d)'