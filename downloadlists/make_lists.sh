#!/usr/bin/env bash

SIZEFILE=''
declare -a BASEURL
BASEURL=()

read -rd '' docstring <<EOF
Usage: make_lists.sh [options] SIZEFILE BASEURL...

Arguments:
  SIZEFILE                  Input file with the list of names.
  BASEURL                   Base url from where to download the files.

Options:
  -d, --debug               Enable debug mode.
  -h, --help                Show this help message and exits.
  --version                 Print version and copyright information.
----
make_lists.sh 0.2.0
copyright (c) 2018 Cristian Consonni
MIT License
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF

eval "$(echo "$docstring" | docopts -V - -h - : "$@" )"

# shellcheck disable=SC2128
SOURCED=false && [ "$0" = "$BASH_SOURCE" ] || SOURCED=true

if ! $SOURCED; then
  set -euo pipefail
  IFS=$'\n\t'
fi

name=$(basename "$SIZEFILE")
year=$(echo "$name" | tr -d  '.tx' | awk -F'-' '{print $1}')
month=$(echo "$name" | tr -d '.tx' | awk -F'-' '{print $2}')

echo "$year-$month"

for baseurl in "${BASEURL[@]}"; do
  awk -F',' '{print $1}' "$SIZEFILE" | while read -r filename; do
    url="${baseurl}/$year-$month/$filename"
    echo -e "$url"
  done
done > "$name"

exit 0
