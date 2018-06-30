#!/usr/bin/env bash

set -u

[ "${ARRAY_UTIL_FLAG:-0}" -gt 0 ] && return 0

export ARRAY_UTIL_FLAG=1


#
# iterate through an associative array and apply a function to each element
# accepts variable arguments which are passed to the operator
#

function foreach() {

    [ "${#}" -lt 2 ] && echo "usage: foreach <array> <operation> <args...>" && exit 1

    local -n _arr="${1}"
    local _operation="${2}"
    shift 2

    for item in "${!_arr[@]}"; do
       "${_operation}" "${_arr[${item}]}" "${@}"
    done
}

#
# iterate through each line in a file and appy a function to each line
# accepts variable arguments which are passed to the operator
#

function forline() {

    [ "${#}" -lt 2 ] && echo "usage: forline <file> <operation> <args...>" && exit 1

    local _file="${1}"
    local _operation="${2}"
    shift 2
    local _line

    while IFS='' read -r _line || [[ -n "${_line}" ]]; do
        "${_operation}" "${_line}" "${@}"
    done < "${_file}"
}

#
# initialize an array ref to the variable arguments
#

function init_array() {
    local -n command="${1}"
    declare -i index=0

    shift 1
    for item in "${@}"; do
        command["${index}"]="${item}"
        ((index+=1))
    done
}

export -f foreach
export -f forline
