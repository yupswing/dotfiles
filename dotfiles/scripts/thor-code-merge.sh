#!/usr/bin/env bash

# per qualche ragione non funziona passando direttamente
# THOR_MERGE='code --wait --diff "$1" "$2"' bin/rails app:update
# funziona invece chiamando
# THOR_MERGE=/home/simo/.scripts/thor-code-merge.sh bin/rails app:update
code --wait -d "$1" "$2"
