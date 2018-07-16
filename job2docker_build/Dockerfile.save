# JDK Data Container
FROM anapsix/alpine-java:8u121b13_jdk

MAINTAINER Ed Ost eost@talend.com

ARG job_name
ARG job_version
ARG job_tgz_file
ARG job_parent_dir=/talend

ENV JOB_NAME=${job_name} \
    JOB_VERSION=${job_version} \
    JOB_PARENT_DIR=${job_parent_dir}

ADD "${job_tgz_file}" "${job_parent_dir}/"
RUN mkdir -p /talend/config

# entrypoint added by build script
#
# ENTRYPOINT [ "/bin/ash" ]
# CMD [ "${JOB_PARENT_DIR}/${JOB_NAME}_${JOB_VERSION}/${JOB_NAME}/${JOB_NAME}_run.sh" ]
#
ENTRYPOINT [ "/bin/ash", "/talend/docker_hello_world_0.1/docker_hello_world/docker_hello_world_run.sh" ]
