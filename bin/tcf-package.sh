#!/usr/bin/env bash

[ "${TCF_PACKAGE_FLAG:-0}" -gt 0 ] && return 0

export TCF_PACKAGE_FLAG=1

set -u

tcf_package_script_path=$(greadlink -e "${BASH_SOURCE[0]}")
tcf_package_script_dir="${tcf_package_script_path%/*}"

source "${tcf_package_script_dir}/tcf-env.sh"

source "${tcf_package_script_dir}/${UTIL_RELATIVE_PATH}util${RESOURCE_VERSION}.sh"
source "${tcf_package_script_dir}/${UTIL_RELATIVE_PATH}url-util${RESOURCE_VERSION}.sh"
source "${tcf_package_script_dir}/${UTIL_RELATIVE_PATH}file-util${RESOURCE_VERSION}.sh"
source "${tcf_package_script_dir}/${UTIL_RELATIVE_PATH}array-util${RESOURCE_VERSION}.sh"


function help() {
    help_flag=1
    local usage
    define usage <<EOF

Download all talend job zip files from url's listed in manifest file.
Merge all talend job zip files.
Rename property and jar files as necessary to minimize namespace collisions.
TBD: Create a list of all conflicting files.
Compress the merged files with tgz rather than zip.
Publish the new app tgz to target nexus.

usage:
    talend_packager [-m manifest_file] [-n nexus_host] [-g group_path] [-a app_name] [-v version] [-s source credential] [-t target credential] [-w working directory]

    -m manifest_file: env var TALEND_PACKAGER_JOB_MANIFEST : default "job_manifest.cfg"
    -n nexus_host: env var TALEND_PACKAGER_NEXUS_HOST : default "192.168.99.1"
    -g target group_path: env var TALEND_PACKAGER_GROUP_PATH : default "com/talend"
    -a target app_name: env var TALEND_PACKAGER_APP_NAME : default "myapp"
    -v target version: env var TALEND_PACKAGER_VERSION : default "0.1.0-SNAPSHOT"
    -s source nexus credential in userid:password format : env var TALEND_PACKAGER_NEXUS_SOURCE_USERID:TALEND_PACKAGER_NEXUS_SOURCE_PASSWORD : default "tadmin:tadmin"
    -t target nexus credential in userid:password format : env var TALEND_PACKAGER_NEXUS_TARGET_USERID:TALEND_PACKAGER_NEXUS_TARGET_PASSWORD : default "tadmin:tadmin"
    -w working directory : env var TALEND_PACKAGER_WORKING_DIR : defaults to creating a temp directory

EOF
    echo "${usage}"
}


function parse_args() {

    local OPTIND=1
    while getopts ":hm:n:g:a:v:s:t:w:" opt; do
        case "$opt" in
            h)
                help
                return 0
                ;;
            m)
                manifest_file="${OPTARG}"
                ;;
            n)
                nexus_host="${OPTARG}"
                ;;
            g)
                group_path="${OPTARG}"
                ;;
            a)
                app_name="${OPTARG}"
                ;;
            v)
                version="${OPTARG}"
                ;;
            s)
                source_credential="${OPTARG}"
                nexus_userid="${source_credential%:*}"
                nexus_password="${source_credential#*:}"
                ;;
            t)
                target_credential="${OPTARG}"
                nexus_target_userid="${target_credential%:*}"
                nexus_target_password="${target_credential#*:}"
                ;;
            w)
                working_dir="${OPTARG}"
                ;;
            ?)
                help >&2
                return 2
                ;;
        esac
    done
}


function multi_job() {
    local working_dir="${1:-${working_dir:-}}"
    local job_file_root="${2:-${job_file_root:-}}"
    local job_root="${3:-${job_root:-}}"

    debugLog "applying multi-job modifications"

    # rename jobInfo.properties
    mv "${working_dir}/${job_file_root}/jobInfo.properties" "${working_dir}/${job_file_root}/jobInfo_${job_root}.properties"
    # collisions are most likely with the routines.jar which has a common name but potentially different content
    mv "${working_dir}/${job_file_root}/lib/routines.jar" "${working_dir}/${job_file_root}/lib/routines_${job_root}.jar"
    # sed command to tweak shell script to use routines_${job_root}.jar
    sed -i "" "s/routines\.jar/routines_${job_root}\.jar/g" "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"
}


function process_zip() {

    local working_dir="${1:-${working_dir:-}}"
    local job_file_name="${2:-${job_file_name:-}}"
    local job_file_root="${3:-${job_file_root:-}}"
    local job_root="${4:-${job_root:-}}"
    local is_multi_job="${5:-${is_multi_job:-true}}"

    debugVar working_dir
    debugVar job_file_name
    debugVar job_file_root
    debugVar job_root
    debugVar is_multi_job

    mkdir -p "${working_dir}/${job_file_root}"

    infoLog "Unzipping '${working_dir}/${job_file_name}' to '${working_dir}/${job_file_root}'"
    unzip -qq -o -d "${working_dir}/${job_file_root}" "${working_dir}/${job_file_name}"

    debugLog "rename 'jobInfo.properties' to 'jobInfo_${job_root}.properties'"
    mv "${working_dir}/${job_file_root}/jobInfo.properties" "${working_dir}/${job_file_root}/jobInfo_${job_root}.properties"
    debugLog "rename 'routines.jar' to 'routines_${job_root}.jar'"
    mv "${working_dir}/${job_file_root}/lib/routines.jar" "${working_dir}/${job_file_root}/lib/routines_${job_root}.jar"
    debugLog "tweak shell script to use 'routines_${job_root}.jar'"
    sed -i "" "s/routines\.jar/routines_${job_root}\.jar/g" "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"

#    [ "${is_multi_job}" == "true" ] && multi_job "${working_dir}" "${job_file_root}" "${job_root}"

    debugLog "insert exec at beginning of java invocation"
    sed -i "" "s/^java /exec java /g" "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"
    debugLog "set exec permission since it is not set and is not maintianed by zip format"
    chmod +x "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"
}


function lambda_process_zip() {

    local working_dir="${1:-${working_dir:-}}"
    local job_file_name="${2:-${job_file_name:-}}"
    local job_file_root="${3:-${job_file_root:-}}"
    local job_root="${4:-${job_root:-}}"
    local is_multi_job="${5:-${is_multi_job:-true}}"

    debugVar working_dir
    debugVar job_file_name
    debugVar job_file_root
    debugVar job_root
    debugVar is_multi_job

    mkdir -p "${working_dir}/${job_file_root}"

    infoLog "Unzipping '${working_dir}/${job_file_name}' to '${working_dir}/${job_file_root}'"
    unzip -qq -o -d "${working_dir}/${job_file_root}" "${working_dir}/${job_file_name}"

    debugLog "Creating ${working_dir}/${job_file_root}/java"
    mkdir -p "${working_dir}/${job_file_root}/java"

    debugLog "moving libs '${working_dir}/${job_file_root}/lib' to '${working_dir}/${job_file_root}/java'"
    echo "mv ${working_dir}/${job_file_root}/lib ${working_dir}/${job_file_root}/java"
    mv "${working_dir}/${job_file_root}/lib" "${working_dir}/${job_file_root}/java"

    debugLog "moving jar files from '${working_dir}/${job_file_root}/${job_root}' to '${working_dir}/${job_file_root}/java/lib'"
    mv ${working_dir}/${job_file_root}/${job_root}/*.jar "${working_dir}/${job_file_root}/java/lib"

#
# delete src and items and then copy everything else
#
    debugLog "removing src directory '${working_dir}/${job_file_root}/${job_root}/src'"
    rm -rf "${working_dir}/${job_file_root}/${job_root}/src"
    debugLog "removing items directory '${working_dir}/${job_file_root}/${job_root}/items'"
    rm -rf "${working_dir}/${job_file_root}/${job_root}/items"
    debugLog "moving all directories and files from '${working_dir}/${job_file_root}/${job_root}' to '${working_dir}/${job_file_root}/java/lib'"
    mv ${working_dir}/${job_file_root}/${job_root}/* "${working_dir}/${job_file_root}/java/lib"
    
    debugLog "setting execute permission for shell scripts in '${working_dir}/${job_file_root}/java/lib'"
    find "${working_dir}/${job_file_root}/java/lib" -type f -iname "*.sh" -exec chmod +x {} \;

# temp disabled
#    debugLog "removing target directory '${working_dir}/${job_file_root}/META-INF'"
#    rm -rf "${working_dir}/${job_file_root}/META-INF"

# temp disabled
#    debugLog "removing target directory '${working_dir}/${job_file_root}/${job_root}'"
#    rm -rf "${working_dir}/${job_file_root}/${job_root}"

#    debugLog "rename 'jobInfo.properties' to 'jobInfo_${job_root}.properties'"
#    mv "${working_dir}/${job_file_root}/jobInfo.properties" "${working_dir}/${job_file_root}/jobInfo_${job_root}.properties"

#    debugLog "rename 'routines.jar' to 'routines_${job_root}.jar'"
#    mv "${working_dir}/${job_file_root}/lib/routines.jar" "${working_dir}/${job_file_root}/lib/routines_${job_root}.jar"

#    debugLog "tweak shell script to use 'routines_${job_root}.jar'"
#    sed -i "s/routines\.jar/routines_${job_root}\.jar/g" "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"

# multi-job is addressed above, this is legacy code
#    [ "${is_multi_job}" == "true" ] && multi_job "${working_dir}" "${job_file_root}" "${job_root}"

#    debugLog "insert exec at beginning of java invocation"
#    sed -i "s/^java /exec java /g" "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"

#    debugLog "set exec permission since it is not set and is not maintianed by zip format"
#    chmod +x "${working_dir}/${job_file_root}/${job_root}/${job_root}_run.sh"
}


function process_job_entry() {
    debugLog "BEGIN"

    local current_url="${1}"
    local job_file_name
    local job_file_root
    local job_root
    local job_root_pattern="-+([0-9])\.+([0-9])\.+([0-9])*"


    debugVar "current_url"

    if [ "${current_url:0:1}" == "#" ]; then
        return 0
    else
        infoLog "processing manifest entry: ${current_url}"
    fi

    local -A parsed_source_url
    parse_url parsed_source_url "${current_url}"

    local job_zip_path="${parsed_source_url[file]}"
    parse_job_zip_path "${job_zip_path}" "${job_root_pattern}" job_file_name job_file_root job_root

    debugLog "attempting to retrieve ${current_url} to ${working_dir}"
    wget -q --http-user="${nexus_userid}" --http-password="${nexus_password}" --directory-prefix="${working_dir}" "${current_url}" && true
    if [ ! $? == 0 ]; then
        errorMessage "error retrieving ${current_url}"
        return 1
    fi

    process_zip "${working_dir}" "${job_zip_path}" "${job_file_root}" "${job_root}"

    # merge zip file contents
    rsync -aibh --stats "${working_dir}/${job_file_root}/" "${working_dir}/target/" > /dev/null

    debugLog "END"
}


function parse_job_zip_path() {

    local job_zip_path="${1}"
    local job_root_pattern="${2}"
    local _job_file_name="${3}"
    local _job_file_root="${4}"
    local _job_root="${5}"

    required job_zip_path job_root_pattern _job_file_name _job_file_root _job_root

    local job_file_name_out="${job_zip_path##*/}"
    local job_file_root_out="${job_file_name_out%.*}"

    local extglob_save
    extglob_save=$(shopt -p extglob || true )

    shopt -s extglob

    local job_root_out="${job_file_root_out/%${job_root_pattern}}"

    eval "${extglob_save}"

    assign "${_job_file_name}" "${job_file_name_out}"
    assign "${_job_file_root}" "${job_file_root_out}"
    assign "${_job_root}" "${job_root_out}"
}


function job_to_docker() {
    local job_zip_path="${1:-${job_zip_path:-}}"
    local job_zip_target_dir="${2:-${job_zip_target_dir:-${PWD}}}"
    local working_dir="${3:-${working_dir:-}}"

    debugVar job_zip_path
    debugVar job_zip_target_dir
    debugVar working_dir

    local job_file_name
    local job_file_root
    local job_root
    local job_root_pattern="_+([0-9])\.+([0-9])*"
    local tmp_working_dir

    required job_zip_path

    default_working_dir="${working_dir:-${TMPDIR:-${HOME}/tmp/job2docker}}"
    mkdir -p "${default_working_dir}"
    [ ! -w "${default_working_dir}" ] && errorMessage "Working directory '${default_working_dir}' is not writeable" && return 1
    tmp_working_dir=$(mktemp -d "${default_working_dir}XXXXXX")
    debugVar tmp_working_dir

    parse_job_zip_path "${job_zip_path}" "${job_root_pattern}" job_file_name job_file_root job_root

    infoLog "Copying '${job_zip_path}' to working directory '${tmp_working_dir}'"
    cp "${job_zip_path}" "${tmp_working_dir}"

    process_zip "${tmp_working_dir}" "${job_file_name}" "${job_file_root}" "${job_root}" "false"

    # delete local zip file copy when finished
    # this needs to occur after zip command since zip does not like the additional file desriptor
    local working_zip_path_fd
    exec ${working_zip_path_fd}>"${tmp_working_dir}/${job_file_name}"
    rm "${tmp_working_dir}/${job_file_name}"

    tar -C "${tmp_working_dir}" -zcpf "${tmp_working_dir}/${job_root}.tgz" "${job_file_root}"
    mv "${tmp_working_dir}/${job_root}.tgz" "${job_zip_target_dir}"
    infoLog "Dockerized zip file ready in '${job_zip_target_dir}/${job_root}.tgz'"

    # clean up working directory
    rm -rf "${tmp_working_dir:?}/${job_file_root}"
}


function job_to_lambda() {
    local job_zip_path="${1:-${job_zip_path:-}}"
    local job_zip_target_dir="${2:-${job_zip_target_dir:-${PWD}}}"
    local working_dir="${3:-${working_dir:-}}"
    local job_file_name="${4:-${job_file_name:-}}"
    local job_file_root="${5:-${job_file_root:-}}"
    local job_root="${6:-${job_root:-}}"

    debugVar job_zip_path
    debugVar job_zip_target_dir
    debugVar working_dir
    debugVar job_file_name
    debugVar job_file_root
    debugVar job_root

    local job_root_pattern="-+([0-9])\.+([0-9])\.+([0-9])*"
    local tmp_working_dir

    required job_zip_path

    default_working_dir="${working_dir:-${TMPDIR:-${HOME}/tmp/job2lambda}}"
    mkdir -p "${default_working_dir}"
    [ ! -w "${default_working_dir}" ] && errorMessage "Working directory '${default_working_dir}' is not writeable" && return 1
    tmp_working_dir=$(mktemp -d "${default_working_dir}XXXXXX")
    debugVar tmp_working_dir

    infoLog "Copying '${job_zip_path}' to working directory '${tmp_working_dir}'"
    cp "${job_zip_path}" "${tmp_working_dir}"

    lambda_process_zip "${tmp_working_dir}" "${job_file_name}" "${job_file_root}" "${job_root}" "false"

    # delete local zip file copy when finished
    # this needs to occur after zip command since zip does not like the additional file desriptor
    local working_zip_path_fd
    exec {working_zip_path_fd}>"${tmp_working_dir}/${job_file_name}"
    rm "${tmp_working_dir}/${job_file_name}"

# use tar for docker processing
#    tar -C "${tmp_working_dir}" -zcpf "${tmp_working_dir}/${job_root}.tgz" "${job_file_root}"
#    mv "${tmp_working_dir}/${job_root}.tgz" "${job_zip_target_dir}"
#    infoLog "Dockerized zip file ready in '${job_zip_target_dir}/${job_root}.tgz'"


declare zip_command
which zip
if [ $? -ne 0 ]; then
   zip_command="/opt/usr/bin/zip"
   ls -al /opt/usr/bin/zip
   chmod +x /opt/usr/bin/zip
else
   zip_command="zip"
fi
debugLog "zip_command=${zip_command}"

# use zip for lambda layers
    debugLog "zipping content of directory '${tmp_working_dir}/${job_file_root}' to '${job_zip_target_dir}/${job_file_root}.zip'"
    current_dir="${PWD}"
    cd "${tmp_working_dir}/${job_file_root}"
    debugLog "current directory: ${PWD}"
    debugLog "directory content: $(ls)"
#    debugLog "target zip directory: $(ls ${job_zip_target_dir}/${job_file_root}.zip)"
    debugLog "executing: ${zip_command} -r \"${job_zip_target_dir}/${job_file_root}.zip\" ./* > /dev/null"
    "${zip_command}" -r "${job_zip_target_dir}/${job_file_root}.zip" ./* 1>&2
    if [ -f "${job_zip_target_dir}/${job_file_root}.zip" ]; then
        debugLog "'${job_zip_target_dir}/${job_file_root}.zip' EXISTS"
    else
        debugLog "'${job_zip_target_dir}/${job_file_root}.zip' DOES NOT EXIST"
    fi
    cd "${current_dir}"
    infoLog "Lambda layer zip file ready in '${job_zip_target_dir}/${job_file_root}.zip'"

    # clean up working directory
    rm -rf "${tmp_working_dir:?}/${job_file_root}"
}


function process_manifest() {
    debugLog "BEGIN"

    local manifest_file="${1}"
    local app_name="${2}"

    forline "${manifest_file}" process_job_entry

    debugLog "**** moving '${working_dir}/target' to '${working_dir}/${app_name}' ****"
    mv "${working_dir}/target" "${working_dir}/${app_name}"

    # keep permissions using tgz format
    debugLog "process_manifest: PWD=${PWD}"
    debugLog "zipping from directory '${working_dir}/${app_name}' into '${app_name}.tgz'"
    tar -C "${working_dir}" -zcpf "${app_name}.tgz" "${app_name}"
    debugLog "tar zip result = ${?}"

    debugLog "deleting working directory '${working_dir}/${app_name}'"
    rm -rf "${working_dir:?}/${app_name}"


    debugLog "END"
}


function publish_app() {
    debugLog "BEGIN"

    local nexus_target_url="${nexus_target_repo}/${group_path}/${version}/${app_name}-${version}.tgz"

    infoLog "publishing talend app to ${nexus_target_url}"
    curl -u "${nexus_target_userid}:${nexus_target_password}" \
        -w "\n\nhttp-result=%{http_code}\n" --upload-file "${app_name}.tgz" \
        "${nexus_target_url}"

    # shellcheck disable=2154
    infoLog "Published manifest ${manifest} as ${group_path}:${app_name}:${version} to Nexus ${nexus_host}"

    exit 0

    debugLog "END"
}


function talend_packager() {
    debugLog "BEGIN"

    # TODO: allow this to be loaded from a file specified as an option

    # default top level parameters
    local manifest_file="${manifest_file:-${TALEND_PACKAGER_JOB_MANIFEST:-manifest.cfg}}"
    local working_dir="${working_dir:-${TALEND_PACKAGER_WORKING_DIR:-}}"

    [ -z "${working_dir}" ] && create_temp_dir working_dir

    # default nexus source configuration
    local nexus_userid="${TALEND_PACKAGER_NEXUS_USERID:-tadmin}"
    local nexus_password="${TALEND_PACKAGER_NEXUS_PASSWORD:-tadmin}"

    # default nexus target configuration
    local nexus_source_userid="${TALEND_PACKAGER_NEXUS_SOURCE_USERID:-admin}"
    local nexus_source_password="${TALEND_PACKAGER_NEXUS_SOURCE_PASSWORD:-Talend123}"
    local source_credential="${nexus_source_userid}:${nexus_source_password}"
    local nexus_host="${TALEND_PACKAGER_NEXUS_HOST:-192.168.99.1}"
# nexus 2 path
#    local nexus_target_repo="${TALEND_PACKAGER_NEXUS_TARGET_REPO:-http://${nexus_host}:8081/nexus/service/local/repositories/snapshots/content}"
# nexus 3 path
    local nexus_target_repo="${TALEND_PACKAGER_NEXUS_TARGET_REPO:-http://${nexus_host}:8081/repository/snapshots}"
    local nexus_target_userid="${TALEND_PACKAGER_NEXUS_TARGET_USERID:-admin}"
    local nexus_target_password="${TALEND_PACKAGER_NEXUS_TARGET_PASSWORD:-Talend123}"
    local target_credential="${nexus_target_userid}:${nexus_target_password}"
    local group_path="${TALEND_PACKAGER_GROUP_PATH:-com/talend}"
    local app_name="${TALEND_PACKAGER_APP_NAME:-myapp}"
    local version="${TALEND_PACKAGER_VERSION:-0.1.0-SNAPSHOT}"

    # help flag
    local help_flag=0

    parse_args "$@"
    # exit with success value if help was requested
    if [ "${help_flag}" -eq 1 ] ; then
        return 0
    fi

    debugVar manifest_file
    debugVar group_path
    debugVar app_name
    debugVar version
    debugVar source_credential
    debugVar target_credential
    debugVar working_dir

    infoLog "executing: talend_packager -m \"${manifest_file}\" -g \"${group_path}\" -a \"${app_name}\" -v \"${version}\" -s \"${source_credential}\" -t \"${target_credential}\" -w \"${working_dir}\""

    debugLog "adding trap: rm -f \"${app_name}.tgz\""
    trap_add "rm -f ${app_name}.tgz" EXIT
    process_manifest "${manifest_file}" "${app_name}"

    debugVar working_dir
    publish_app

    debugLog "END"
}
