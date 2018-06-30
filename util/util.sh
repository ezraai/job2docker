#!/usr/bin/env bash

set -u

[ "${UTIL_FLAG:-0}" -gt 0 ] && return 0

export UTIL_FLAG=1



# read files or here documents into a variable
define(){ IFS=$'\n' read -r -d '' "${1}" || true; }


function warningLog() {
    [ -n "${WARNING_LOG:-}" ] && echo "WARNING: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}

function infoLog() {
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}

function infoVar() {
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${FUNCNAME[*]:1} : ${1}=${!1}" 1>&2
    return 0
}

function debugLog() {
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${*}" 1>&2
    return 0
}

function debugVar() {
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${1}=${!1}" 1>&2
    return 0
}

function debugStack() {
    if [ -n "${DEBUG_LOG:-}" ] ; then
        local args
        [ "${#}" -gt 0 ] && args=": ${*}"
        echo "DEBUG: ${FUNCNAME[*]:1}${args}" 1>&2
    fi
}


function errorMessage() { 
    echo "ERROR: $0: ${FUNCNAME[*]:1} : ${*}" 1>&2
}

function die() {
    echo "$0: ${FUNCNAME[*]:1} : ${*}" 1>&2
    exit 111
}

function try() {
    while [ -z "${1}" ]; do
        shift
    done
    [ "${#}" -lt 1 ] && die "empty try statement"

    ! "$@" && echo "$0: ${FUNCNAME[*]:1}: cannot execute: ${*}" 1>&2 && exit 111

    return 0
}


function assign() {
    local var="${1}"
    local value="${2}"
    required var value
    printf -v "${var}" '%s' "${value}"
}


function required() {
    local arg
    local error_message=""
    for arg in "${@}"; do
        if [ -z "${!1+x}" ]; then
            error_message="${error_message} ${arg} undefined"
        elif [ -z "${!arg}" ]; then
            error_message="${error_message} ${arg} empty"
        fi
    done
    [ -n "${error_message}" ] \
        && error_message="missing required arguments:${error_message}" \
        && echo "$0: ${FUNCNAME[*]:1}: ${error_message}" 1>&2 \
        && exit 111
    return 0
}


trap_add() {
    if [ "${1}" = "-h" -o "${1}" = "--help" -o "${#}" -lt 2 ] ; then
        cat <<-HELPDOC
	  DESCRIPTION

	  USAGE
	    trap_add <handler> <signal>

	    parameter: handler: a command or usually a function used as a signal handler
            parameter: signal: one or more trappable SIGNALS to which the handler will be attached
	HELPDOC
        return 2
    fi

    local trap_command="${1}"
    shift 1
    local trap_signal
    for trap_signal in "$@"; do
        debugVar trap_signal

        # Get the currently defined traps
        local existing_trap
        local current_trap
        current_trap=$(trap -p "${trap_signal}")
        debugLog "current trap: ${current_trap}"
        existing_trap=$( trap -p "${trap_signal}" | awk -F"'" '{ print $2 }' )
        debugVar existing_trap

        # Remove single apostrophe formatting wrapper
        existing_trap="${existing_trap#\'}"
        existing_trap="${existing_trap%\'}"
        debugVar existing_trap

        # Append new trap to old trap
        [ -n "${existing_trap}" ] && existing_trap="${existing_trap};"
        local new_trap="${existing_trap}${trap_command}"
        debugVar new_trap

        # Assign the composed trap
         trap "${new_trap}" "${trap_signal}"
    done
}

# set the trace attribute for the above function.  this is
# required to modify DEBUG or RETURN traps because functions don't
# inherit them unless the trace attribute is set
declare -f -t trap_add


export -f define
export -f debugLog
export -f debugVar
export -f infoLog
export -f infoVar
export -f debugStack
export -f die
export -f try
export -f assign
export -f trap_add

debugLog "sourced: util.sh"
