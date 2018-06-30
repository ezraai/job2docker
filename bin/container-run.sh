#!/usr/bin/env bash

set -e
set -u

container_run_script_path=$(readlink -e "${BASH_SOURCE[0]}") 
container_run_script_dir="${container_run_script_path%/*}"

source "${container_run_script_dir}/../util/util.sh"


function container_run() {

    local job_id="${1:-}"
    local job_name="${2:-t0_docker_create_customer}"
    local project_name="${3:-SE_DEMO}"
    local app_name="${4:-${APP_NAME:-${app_name:-talend_sample_container_app}}}"
    local job_version="${5:-0.1.0-SNAPSHOT}"
    local image="${6:-${USER}/${app_name}}"
    local image_version="${7-0.1.0}"


    local usage="./d03-run <job_id> [ <project_name [ <image> [ <image_version> [ <app_name> [ <job_name> [ <job_version> ] ] ] ] ] ]"
    if [ -z "${job_id}" ]; then
        echo "WARNING: missing job_id: ${usage}"  1>&2
        job_id=$(uuidgen -t)
        echo "WARNING: using job_id=${job_id}" 1>&2
    fi

    # container has knowledge of app name
    local volume_root="/home/eost/talend_distro/sample_job/volumes"
    local project_root="talend/${project_name}"
    local app_root="${project_root}/${app_name}"
    local job_root="${app_root}/${job_name}"
    local job_instance_root="${job_root}/${job_id}"
    # talend/SE_DEMO/talend_sample_container_app/t0_docker_create_customer/xxxx

    # jobs do not have knowledge of app name
    # these paths are relative to the job in the container
    local project_target="talend/${project_name}"
    local job_target="${project_target}/${job_name}"
    local job_instance_target="${job_target}/${job_id}"
    # talend/SE_DEMO/t0_docker_create_customer/xxx

    echo "TALEND_${project_name^^}_${job_name^^}_JOB_ID=${job_id}"

    # we use re-use ${volume_root}/${job_root}/in for common input for states file
    # it is mapped to in_dir context variable by the job level configuration file
    #     ${volume_root}/${job_root}/job.cfg
    # note that the paths within job.cfg must be relative to the container, not the host OS

    # set JOB_ID environment variable to allow introspection of container

    docker run \
      --env "TALEND_${project_name^^}_${job_name^^}_JOB_ID=${job_id}" \
      -v "${volume_root}/${job_root}/config:/${job_target}/config:ro" \
      -v "${volume_root}/${job_root}/amc:/${job_target}/amc" \
      -v "${volume_root}/${job_root}/in:/${job_target}/in:ro" \
      -v "${volume_root}/${job_instance_root}/config:/${job_instance_target}/config:ro" \
      -v "${volume_root}/${job_instance_root}/in:/${job_instance_target}/in:ro" \
      -v "${volume_root}/${job_instance_root}/out:/${job_instance_target}/out" \
      -v "${volume_root}/${job_instance_root}/data:/${job_instance_target}/data" \
      -v "${volume_root}/${job_instance_root}/temp:/${job_instance_target}/temp" \
      -v "${volume_root}/${job_instance_root}/log:/${job_instance_target}/log" \
      --rm \
      "${image}:${image_version}" \
      "/talend/${app_name}/${job_name}/${job_name}_run.sh" "--context_param" "job_id=${job_id}"

#      /talend/${app_name}/${job_name}-${job_version}/${job_name}/${job_name}_run.sh

    # set JOB_ID environment variable to allow introspection of container
    : <<EOF
    docker run \
      --env "TALEND_JOB_ID=${job_id}" \
      -v ${volume_root}/${job_root}/config:/${job_target}/config:ro \
      -v ${volume_root}/${job_root}/amc:/${job_target}/amc \
      -v ${volume_root}/${job_root}/in:/${job_target}/in \
      -v ${volume_root}/${job_instance_root}/config:/${job_instance_target}/config:ro \
      -v ${volume_root}/${job_instance_root}/in:/${job_instance_target}/in:ro \
      -v ${volume_root}/${job_instance_root}/out:/${job_instance_target}/out \
      -v ${volume_root}/${job_instance_root}/data:/${job_instance_target}/data \
      -v ${volume_root}/${job_instance_root}/temp:/${job_instance_target}/temp \
      -v ${volume_root}/${job_instance_root}/log:/${job_instance_target}/log \
      --rm -it \
      "${image}:${image_version}"
EOF


}
