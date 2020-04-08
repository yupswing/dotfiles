#!/bin/sh

DIR="$( cd "$( dirname "$0" )" && pwd )"

# screenshots
mkdir -p $HOME/Pictures/screenshots

# backgrounds
ln -sfn $DIR/data/backgrounds $HOME/Pictures/backgrounds
