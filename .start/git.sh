# if ~/.initial_gitconfig exists, then copy it to ~/.gitconfig
if [ -f ~/.initial_gitconfig ]; then
  cp ~/.initial_gitconfig ~/.gitconfig
fi

# if githooks directory exists, then set it as the global hooks path
if [ -d ~/.githooks ]; then
  git config --global core.hooksPath ~/.githooks
fi