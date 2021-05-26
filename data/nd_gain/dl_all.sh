#!/bin/bash
set -e

usage() {
    echo "YO"
}

log() {
    lcol='\033[1;33m' lcol2='\033[1;36m' lclr='\033[m'
    printf '%b%s %b%s%b %s\n' \
        "$lcol" "${3:-->}" "${lclr}${2:+$lcol2}" "$1" "$lclr" "$2" >&2
}

die() {
    printf 'error: %s.\n' "$1" >&2
    exit 1
}

dl_data() {
    log "Scraping download page"
    link=$(curl -s "https://gain.nd.edu/our-work/country-index/download-data/" \
            | grep "DOWNLOAD ND-GAIN DATA" \
            | tr ' ' '\n' \
            | tr '>' '\n' \
            | tr '=' '\n' \
        | grep zip | tr -d '"')
    [ ! -z "$link" ] && log "Download link found!" || die "Download link not found :("
    cd $DLDIR
    curl -s "https://gain.nd.edu$link" -O && log "Downloaded zipped file" || die "Download failed :( ; command attempted: curl -s "https://gain.nd.edu$link" -O"
}

unzip_data() {
    log "Unzipping data"
    unzip $DLDIR/$(basename $link) -d $DLDIR/$(date +'%Y-%m-%d')_ndgain > /dev/null
}


main() {
    DLDIR="."
    for i in "$@"; do
        case $i in
            -d|--dldir)
                DLDIR="$2"
                shift
                shift
                ;;
            -o|--overwrite)
                OVERWRITE=YES
                shift
                ;;
            -h|--help)
                usage
                exit
                ;;
            *)
                ;;
        esac
    done
    log  " " " " "Downloading Notre Dame's Global Adaptation Index"
    log "Download directory:" "$DLDIR"
    dl_data
    unzip_data
}

main "$@"
