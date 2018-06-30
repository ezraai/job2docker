#!/usr/bin/env bash

set -u

[ "${PARSE_URL_FLAG:-0}" -gt 0 ] && return 0

export PARSE_URL_FLAG=1

function parse_url() {

    [ "${#}" -lt 2 ] && echo "usage: parse_url <target_url_array> <url>" && exit 1
    local -n parsed_url_ref="${1}"
    local url="${2}"

    local protocol="${url%%://*}"

    local host="${url#*://}"
    local port="${host#*:}"
    local path="${host#*/}"
    local file="${path##*/}"
    if [ "${port}" == "${host}" ]; then
        host="${host%%/*}"
        port="80"
    else
        host="${host%%:*}"
        port="${port%%/*}"
    fi

    parsed_url_ref[url]="${url}"
    parsed_url_ref[protocol]="${protocol}"
    parsed_url_ref[host]="${host}"
    parsed_url_ref[port]="${port}"
    parsed_url_ref[path]="${path}"
    parsed_url_ref[file]="${file}"
}


export -f parse_url
