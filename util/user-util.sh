#!/usr/bin/env bash

set -u

[ "${USER_UTIL_FLAG:-0}" -gt 0 ] && return 0

export USER_UTIL_FLAG=1

user_util_script_path=$(readlink -e "${BASH_SOURCE[0]}")
user_util_script_dir="${user_util_script_path%/*}"

user_util_string_path=$(readlink -e "${user_util_script_dir}/string-util.sh")
source "${user_util_string_path}"


function user_exists() {
    local usage="user_exists <user>"
    [ "${#}" -lt 1 ] && echo "ERROR: usage: ${usage}" >&2 && return 1
    local user="${1}"
    [ -z "${user}" ] && echo -e "ERROR: usage: ${usage}\nempty user ument" >&2 && return 1

    id -u "${user}" > /dev/null 2>&1

    return "${?}"
}



function group_exists() {
    local usage="group_exists <group_name>"
    [ "${#}" -lt 1 ] && echo "ERROR: usage: ${usage}" >&2 && return 1
    local group_name="${1}"
    [ -z "${group_name}" ] && echo -e "ERROR: usage: ${usage}\nempty group_name argument" >&2 && return 1

    getent group | cut -d: -f1 | grep "^${group_name}$" > /dev/null 2>&1

    return "${?}"
}

function group_members() {
    local usage="usage: group_members <group_name> <member_list_ref>"
    [ "${#}" -lt 2 ] && echo -e "${usage}\nERROR: too few arguments" >&2 && return 1
    local group_name="${1}"
    [ -z "${group_name}" ] && echo -e "${usage}\nERROR: empty group_name argument" >&2 && return 1

    local member_list_ref="${2}"
    [ -z "${member_list_ref}" ] && echo -e "${usage}\nERROR: empty member_list_ref argument" >&2 && return 1
    local -n member_list="${member_list_ref}"

    local members
    members=$(getent group | grep "^${group_name}:" | cut -d: -f4)
    IFS=', ' read -r -a member_list <<< "${members}"
}
