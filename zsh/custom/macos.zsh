source $DF/zsh/lib/os.zsh
local macos=${0:a:h}/macos

osx() {
  # source all macos scripts
  for f ($macos/*.zsh) source $f
}

if [[ "$OSX" = "1" ]] then
  osx
fi
