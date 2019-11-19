alias ll="ls -laFsh"

alias c='clear'
alias cls='clear'
alias x='exit'

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# URL-encode strings
alias encodeurl='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
alias eurl=encodeurl

alias decodeurl='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1]);"'
alias durl=decodeurl

# show all dns resolvers
alias showdns='scutil --dns'

# XML-encode strings
alias encodexml='python -c "import sys; from xml.sax.saxutils import escape; print escape(sys.argv[1]);"'
alias exml=encodexml

alias decodexml='python -c "import sys; from xml.sax.saxutils import unescape; print unescape(sys.argv[1]);"'
alias dxml=decodexml

alias pwg=password_gen
