#!/usr/bin/env bash

debug=false
date_start=''
date_end=''
BASEURL="https://dumps.wikimedia.org/other/pagecounts-raw"

eval "$(docopts -V - -h - : "$@" <<EOF
Usage: download_sizes.sh [options] BASEURL

Arguments:
  BASEURL                     Base url from where to download the files.
                              [default: https://dumps.wikimedia.org/other/pagecounts-raw]

Options:
  -d, --debug                 Enable debug mode.
  --date-start YEAR_START     Starting year [default: 2007-12].
  --date-end YEAR_END         Starting year [default: 2016-12].
  -h, --help                  Show this help message and exits.
  --version                   Print version and copyright information.

----
download_sizes.sh 0.2.0
copyright (c) 2018 Cristian Consonni
MIT License
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
)"

# shellcheck disable=SC2128
SOURCED=false && [ "$0" = "$BASH_SOURCE" ] || SOURCED=true

if ! $SOURCED; then
  set -euo pipefail
  IFS=$'\n\t'
fi


if $debug; then
    function echodebug() {
        echo -n "[DEBUG] "
        echo "$@"
    }
    echodebug "debugging enabled."

    echodebug -e "date_start: \t $date_start"
    echodebug -e "date_end: \t $date_end"
fi

year_start="$(echo "$date_start" | cut -c 1-4)"
month_start="$(echo "$date_start" | cut -c 6-8)"
year_end="$(echo "$date_end" | cut -c 1-4)"
month_end="$(echo "$date_end" | cut -c 6-8)"

if $debug; then
    echodebug -e "BASEURL: \t $BASEURL"
    echodebug -e "year_start: \t $year_start"
    echodebug -e "month_start: \t $month_start"
    echodebug -e "year_end: \t $year_end"
    echodebug -e "month_end: \t $month_end"
fi

startdate=$(date -d "${year_start}-${month_start}-01" +%s)
enddate=$(date -d "${year_end}-${month_end}-01" +%s)

if [ "$startdate" -ge "$enddate" ]; then
    (>&2 echo "Error: end date must be greater than start date")
fi

function skip_years() {
    if [ "$1" -le "$year_start" ] && [ "$2" -lt "$month_start" ]; then return 0; fi
    if [ "$1" -ge "$year_end" ] && [ "$2" -gt "$month_end" ]; then return 0; fi

    return 1
}

year=''
month=''
url=''
for year in $(seq "$year_start" "$year_end"); do
    for month in {01..12}; do
        if skip_years "$year" "$month"; then continue; fi

        url="$BASEURL/${year}-${month}/"
        output="${year}-${month}.txt"
        tmp_output="${output}.tmp"

            echo "wget -O ${tmp_output} $url"
            wget -O "${tmp_output}" "$url"

         [ -f "${tmp_output}" ] && \
                xidel --extract "//tr//a" "${tmp_output}" | \
                grep -E '^part' > "${output}"

        rm "${tmp_output}"
    done
done
