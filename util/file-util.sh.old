#!/usr/bin/env bash

set -u

[ "${FILE_UTIL_FLAG:-0}" -gt 0 ] && return 0

export FILE_UTIL_FLAG=1

file_util_script_path=$(readlink -e "${BASH_SOURCE[0]}")
file_util_script_dir="${file_util_script_path%/*}"

file_util_util_path=$(readlink -e "${file_util_script_dir}/util.sh")
source "${file_util_util_path}"


create_temp_file() {
    [ "${#}" -lt 1 ] && echo "usage: create_temp_file <file_name_ref>" && return 1
    local -n temp_file="${1}"
    temp_file=$(mktemp)
    trap_add "rm -f ${temp_file}" EXIT
}


create_temp_dir() {
    [ "${#}" -lt 1 ] && echo "usage: create_temp_dir <dir_ref>" && return 1
    local -n temp_dir="${1}"
    temp_dir=$(mktemp -d)
    trap_add "rm -rf ${temp_dir}" EXIT
}


function file_exists() {

    local usage="usage: file_exists <filename>"
    [ "${#}" -lt 1 ] && echo -e "${usage}\n\nERROR: missing filename argument" 1>&2 && return 1
    local filename="${1}"
    trim filename
    [ -z "${filename}" ] && echo -e "${usage}\n\nERROR: empty or blank filename argument" 1>&2 && return 1

    [ ! -f "${filename}" ] && return 1

    return 0
}


function dir_exists() {

    local usage="usage: dir_exists <directory>"
    [ "${#}" -lt 1 ] && echo -e "${usage}\n\nERROR: missing directory argument" 1>&2 && return 1
    local dir="${1}"
    trim dir
    [ -z "${dir}" ] && echo -e "${usage}\n\nERROR: empty or blank directory argument" 1>&2 && return 1

    [ ! -d "${dir}" ] && return 1

    return 0
}


function create_user_directory() {

    if [ "${1}" = "-h" -o "${1}" = "--help" -o "$#" -lt 1 ] ; then
        cat <<-HELPDOC
	create_user_directory

	    DESCRIPTION
	        Create a user owned directory as sudo in some arbitrary location,
	        and change the owner and group of the leaf node directory and any
	        new intermediate directories created in the process.
	        existing directoryies are not modified.

	    CONSTRAINTS
	        Assumes access to sudo.

	    USAGE:
	        create_user_directory <fullDirPath> [ <owner> [ <group> [ <permission> ] ] ]

	        parameter: fullDirPath: required
	        parameter: owner: defaults to installUser config or current user if not defined
	        parameter: group: defaults to installGroup config or current group if not defined
                parameter: permission: permissions value defaults to 750

	HELPDOC
        return 1
    fi

    local fullDirPath="${1}"

    dir_exists "${fullDirPath}" && return 0

    [ -z "${fullDirPath}" ] && echo "ERROR: invalid file path: ${fullDirPath}" && return 1

    local parentDir
    parentDir=$(dirname "${fullDirPath}")

    # if dirname failed then exit
    [ "$?" -ne 0 ] && echo "ERROR: error parsing parent directory: ${fullDirPath}" && return 1

    local owner="${2:-${installUser:-$USER}}"
    trim owner
    [ -z "${owner}" ] && echo "ERROR: owner argument is empty or blank" && return 1
    ! user_exists "${owner}" && echo "ERROR: owner ${owner} does not exist" && return 1

    local group="${3:-${installUser:-$(id -gn)}}"
    trim group
    [ -z "${group}" ] && echo "ERROR: group argument is empty or blank" && return 1
    ! group_exists "${group}" && echo "ERROR: group ${group} does not exist" && return 1

    local permission="${4:-750}"
    trim permission
    [ -z "${permission}" ] && echo "ERROR: permission argument is empty or blank" && return 1

    # todo: use iteration rather than recursion
    [ ! -d "${parentDir}" ] && create_user_directory "${parentDir}" "${owner}" "${group}"
    sudo mkdir -p "${fullDirPath}"
    sudo chmod "${permission}" "${fullDirPath}"
    sudo chown "${owner}:${group}" "${fullDirPath}"

}



export -f create_temp_file
export -f create_temp_dir
export -f create_user_directory
