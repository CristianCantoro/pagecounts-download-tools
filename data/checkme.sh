#!/usr/bin/env bash

workdir=''
quiet=false

eval "$(docopts -V - -h - : "$@" <<EOF
Usage: checkme.sh [options] <workdir>

      <workdir>
      -q, --quiet       Suppress output.
      -h, --help        Show this help message and exits.
      --version         Print version and copyright information.
----
checkme.sh 0.1.0
copyright (c) 2016 Cristian Consonni
MIT License
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
)"

# bash strict mode
# See:
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echoq() { echo "$@"; }
progress_opt='--progress'

if $quiet; then
    echoq() { true; }
    progress_opt=''
fi

workdirname="$(echo "$workdir" | tr -d '/')"
checkdir="../checksums/check"

echoq "$workdirname";

mkdir -p "${checkdir}/${workdirname}/"

awk "{ printf \"%s ${workdirname}/%s\n\", \$1,\$2}" "${workdirname}/md5sums.txt" | \
    "$HOME/.linuxbrew/bin/parallel" \
        $progress_opt \
        --joblog "${checkdir}/${workdirname}/joblog" \
        --results "${checkdir}/${workdirname}/md5sums/" \
        "echo {} | md5sum -c"
