setopt extended_glob
autoload -U colors && colors

source $root/zsh/oh-my-zsh/lib/spectrum.zsh

# banner
banner::print() {
  printf '%s\n' '    __ _ _           '
  printf '%s\n' '   / _(_) |          '
  printf '%s\n' '  | |_ _| | ___  ___ '
  printf '%s\n' '  |  _| | |/ _ \/ __|'
  printf '%s\n' ' _| | | | |  __/\__ \'
  printf '%s\n' '(_)_| |_|_|\___||___/'
  printf '\n'
}

# logging
log::r() { print -P -- "%{$BG[001]%}%{$FG[000]%}$1%{$reset_color%}" }
log::g() { print -P -- "%{$BG[002]%}%{$FG[000]%}$1%{$reset_color%}" }
log::y() { print -P -- "%{$BG[003]%}%{$FG[000]%}$1%{$reset_color%}" }
log::b() { print -P -- "%{$BG[004]%}%{$FG[000]%}$1%{$reset_color%}" }
log::n() { print -P -- "%{$BG[000]%}%{$FG[007]%}$1%{$reset_color%}" }

log::step() { log::n "\n>>>>> $*" }
log::panic() { log::r $1; exit 1 }

# link a file to the home dir.
#
# if $dst exists and is a regular file, skip.
# if $dst is a link, but doens't link to $src, remove it.
df::link() {
  local src=$1
  local dst=${2:-~/.${src:t}}

  print -n "Checking $dst ... "

  # if src is a directory, check if dst is a directory
  if [[ -d $src && (-d $dst && ! -L $dst) ]]; then
    log::r "Skipping regular directory"
    return
  fi

  # if the dst is a regular file, skip it.
  if [[ -f $dst && ! -L $dst ]]; then
    log::r "Skipping regular file"
    return
  fi

  # if the dst is a symlink, check if it links to the correct file.
  if [ -L $dst ]; then
    local tgt=$(readlink $dst)
    if [[ "$tgt" != "$src" ]]; then
      log::y "Overriding link to $src. (was $tgt)"
      ln -fs $src $dst
    else
      log::g "Already linked"
    fi
    return
  fi

  # dst doens't exist. Create new link.
  log::b "Linking to $src"
  ln -s $src $dst
}

df::install() {
  # link all files to home directory
  print -l "\n>>>>>> Linking files <<<<<<\n"
  for file ($DF/home/*(.)) df::link $file

  # link all directories to the home directory
  print -l "\n>>>>>> Linking directories <<<<<<\n"
  for dir ($DF/home/*(/)) df::link $dir

  # link all files to private directory
  print -l "\n>>>>>> Linking private files <<<<<<\n"
  for file ($DF/private/*(.N)) df::link $file

  # link all directories to private directory
    print -l "\n>>>>>> Linking private directories <<<<<<\n"
  for dir ($DF/private/*(/N)) df::link $dir

  # sync fonts to ~/Library/Fonts
  print -l "\n>>>>>> Syncing Fonts <<<<<<\n"
  rsync --exclude ".DS_Store" --exclude ".git" --exclude "README.md" -av --no-perms $DF/home/fonts/ ~/Library/Fonts/

  # all done
  print -l "\n>>>>>> Done <<<<<<\n"
}
