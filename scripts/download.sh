#!/usr/bin/env bash
#
# This scripts downloads the wikipedia dump files of a specific
# year and month.
# To use this script you must run in this order:
#   1) data/make_dirs.sh (to generate the output directories)
#   2) sizes/download_sizes.sh (to download the file names and sizes)
#
# Written by Cristan Consonni <cristian.consonni@unitn.it>
# Modified by Giovanni De Toni <giovanni.det@gmail.com>

continue=''
debug=false
quiet=false
kill=''
year=''
month=''

eval "$(docopts -V - -h - : "$@" <<EOF
Usage: download.sh [options] <year> <month>

      <year>               year to download (2007-2016)
      <month>              month to download (01-12)
      -c, --continue       Continue the previous download.
      -d, --debug          Enable debug mode (incompatible with --quiet).
      -k, --kill           Kill connection.
      -q, --quiet          Suppress output (incompatible with --debug).
      -h, --help           Show this help message and exits.
      --version            Print version and copyright information.
----
download.sh 0.2.0
copyright (c) 2018 Cristian Consonni
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

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pidfile="${workdir}/download.${year}-${month}.pid"

if $debug; then
    echo -e "year: \t\t $year"
    echo -e "month: \t\t $month"
 
    echo -e "continue: \t $continue"
    echo -e "debug: \t\t $debug"
    echo -e "kill: \t\t $kill"
fi


# --debug implies --verbose
if $debug; then quiet=false; fi

if $kill; then
    if [ -f "$pidfile" ]; then
        pkill --parent "$(cat "$pidfile")" --signal TERM
        rm -f "$pidfile"

        exit 0
    fi
else
  echo "$$" > "$pidfile"
fi

continue_opt=''
if $continue; then continue_opt='--continue'; fi

hour=$(date "+%H")
timeout_time=""
max_overall_download_limit=""

if [ "$hour" -gt "7" ] && [ "$hour" -lt "18" ] ; then
    timeout_time="8h"
    max_overall_download_limit="6MB"
else
    timeout_time="10h"
    max_overall_download_limit="50MB"
fi

if $debug; then set +x; fi

set +e
if $quiet; then
  stdbuf -o0 timeout -s TERM "$timeout_time" \
      aria2c \
          -j 12 \
          --max-overall-download-limit="$max_overall_download_limit" \
          --max-overall-upload-limit=50k \
          --file-allocation=none \
          -d "data/${year}-${month}/" \
          -i "downloadlists/${year}-${month}.txt" \
          $continue_opt \
            > "download.${year}${month}.txt"

else
  stdbuf -o0 timeout -s TERM "$timeout_time" \
      aria2c \
          -j 12 \
          --max-overall-download-limit="$max_overall_download_limit" \
          --max-overall-upload-limit=50k \
          --file-allocation=none \
          -d "data/${year}-${month}/" \
          -i "downloadlists/${year}-${month}.txt" \
          $continue_opt \
            | tee "download.${year}${month}.txt"
fi

exit 0
