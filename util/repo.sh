#!/usr/bin/env bash

set -u

[ "${REPO_FLAG:-0}" -gt 0 ] && return 0

export REPO_FLAG=1

repo_script_path=$(readlink -e "${BASH_SOURCE[0]}")
repo_script_dir="${repo_script_path%/*}"

repo_array_path=$(readlink -e "${repo_script_dir}/array-util.sh")
source "${repo_array_path}"


export DOWNLOAD_FILE_OPTIONS="-N"


# download
#
# download a file from external url to local file system using wget
#
function download_file() {
    [ $# -lt 4 ] &&  echo "ERROR: usage: download <sourceUrl> <targetDir> <userid> <password>" && return 1

    local _sourceUrl=${1}
    local _targetDir=${2}
    local _userid=${3}
    local _password=${4}

    local _userid_arg
    [ -n "${_userid}" ] && _userid_arg="--http-user=${_userid}"
    local _password_arg
    [ -n "${_password}" ] && _password_arg="--http-password=${_password}"

    wget "${DOWNLOAD_FILE_OPTIONS}" "${_userid_arg}" "${_password_arg}" -P "${_targetDir}" "${_sourceUrl}"
}

# download manifest files sequentially
#
#
function download_manifest() {

    [ $# -lt 4 ] &&  echo "ERROR: usage: download_manifest <manifest_file> <targetDir> <userid> <password>" && return 1

    local _manifestFile=${1}
    local _targetDir=${2}
    local _userid=${3}
    local _password=${4}

    forline "${_manifestFile}" download_file "${_targetDir}" "${_userid}" "${_password}"
}

# download manifest files in parallel
#
#
function download_parallel() {
    [ $# -lt 4 ] &&  echo "ERROR: usage: download_list <manifest_file> <targetDir> <userid> <password>" && return 1

    local _manifestFile=${1}
    local _targetDir=${2}
    local _userid=${3}
    local _password=${4}

    local _userid_arg
    [ -n "${_userid}" ] && _userid_arg="--http-user=${_userid}"
    local _password_arg
    [ -n "${_password}" ] && _password_arg="--http-password=${_password}"

#    wget "${DOWNLOAD_LIST_OPTIONS}" "${_userid_arg}" "${_password_arg}" -P "${_targetDir}" -i "${_manifestFile}"
    parallel --no-notice wget "${DOWNLOAD_LIST_OPTIONS}" "${_userid_arg}" "${_password_arg}" -P "${_targetDir}" {} < "${_manifestFile}"
}


function checksum() {
    [ $# -lt 1 ] &&  echo "ERROR: usage: checksum <targetDir>" && return 1

    local _targetDir=${1}

    (cd "${_targetDir}"; ls ./*.MD5 | xargs -r md5sum -c )
}

export -f download_file

export -f download_manifest

export -f download_parallel

export -f checksum

