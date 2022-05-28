#!/bin/bash

tmpfile=$(mktemp)

curl -s https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh > "$tmpfile"

bash "$tmpfile"

rm "$tmpfile"