PRIVATE_FOLDER=$(dirname $0)/../private
if [[ -a $PRIVATE_FOLDER ]]; then
  for f in $PRIVATE_FOLDER/*.zsh; do
    source $f;
  done
fi
