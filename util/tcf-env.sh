#!/usr/bin/env bash

set -u

[ "${PARSE_TCF_ENV_FLAG:-0}" -gt 0 ] && return 0

export PARSE_TCF_ENV_FLAG=1

# set TALEND_STUDIO_RESOURCES to 'true' to control include path and file name suffix

if [ "${TALEND_STUDIO_RESOURCES:-}" == "true" ]; then
    # studio resource configuration puts everything in the same directory
    # and appends a version to the file name
    export RESOURCE_VERSION="_0.1"
    export UTIL_RELATIVE_PATH=""
else
    # bash configuration is the default and uses separate util directory and has no version suffix
    export RESOURCE_VERSION=""
    export UTIL_RELATIVE_PATH="../util/"
fi

