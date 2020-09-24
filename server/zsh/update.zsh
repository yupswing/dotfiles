#! /usr/bin/env zsh

OUTPUT=~/.zshrc
BASEURL=https://raw.githubusercontent.com/yupswing/dotfiles/master/
DOTFILE=dotfiles/zsh/zshlib/modules/
SRVFILE=server/zsh/
FILES=(
  ${SRVFILE}base.zsh
  ${DOTFILE}00_options.zsh
  ${DOTFILE}10_environment.zsh
  ${DOTFILE}20_bindkeys.zsh
  ${DOTFILE}20_complete.zsh
  ${DOTFILE}60_aliases.zsh
  ${DOTFILE}60_git.zsh
  ${DOTFILE}60_less.zsh
  ${DOTFILE}60_node.zsh
  ${DOTFILE}60_python.zsh
  ${DOTFILE}60_ruby.zsh
  ${DOTFILE}90_functions.zsh
  ${DOTFILE}Linux/65_linux.zsh
)
echo "--- Update server .zshrc ---"
read -q "REPLY?Your ~/.zshrc will be rewritten. Continue? (yN)"

if [ $REPLY = "n" ]; then
  echo "Aborted."
  exit 0
fi

echo "Delete current $OUTPUT"
rm $OUTPUT

echo "Download and merge zshrc"
for FILE in "${FILES[@]}"; do
  echo " - $BASEURL$FILE > $OUTPUT"
  wget --no-cache $BASEURL$FILE -O - >>$OUTPUT 2>/dev/null
done

echo "Remember to source the new '.zshrc'"
echo "Goodbye"
