local macos=${0:a:h}/macos
local linux=${0:a:h}/linux

osx() {
  # source all macos scripts
  for f ($macos/*.zsh) source $f
}

linux() {
  # source all macos scripts
  for f ($linux/*.zsh) source $f
}

if [[ `uname` == 'Linux' ]] then
  export LINUX=1
  linux
else
  export LINUX=
fi

if [[ `uname` == 'Darwin' ]] then
  export OSX=1
  osx
else
  export OSX=
fi
