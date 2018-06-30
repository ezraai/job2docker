````
Script started on Sat 30 Jun 2018 12:12:06 PM EDT
eost@localhost:~/j2d/job2docker_listener
[eost@localhost job2docker_listener]
$ ./job2docker_listener_run.sh 
log4j:ERROR Could not connect to remote log4j server at [localhost]. We will try again later.
Listening on /home/eost/shared/published_jobs
.---------------------------------------------------------------------------------.
|                            #1. tLogRow_6--tLogRow_6                             |
+-------------------+-------------------------------------------------------------+
| key               | value                                                       |
+-------------------+-------------------------------------------------------------+
| current_iteration | 3                                                           |
| fileName          | docker_hello_world_0.1.zip                                  |
| presentFile       | null                                                        |
| createdFile       | null                                                        |
| updatedFile       | /home/eost/shared/published_jobs/docker_hello_world_0.1.zip |
| deletedFile       | null                                                        |
+-------------------+-------------------------------------------------------------+

.----------------------------------------------------------------------------.
|                     #1. tLogRow_1--job2docker_listener                     |
+--------------+-------------------------------------------------------------+
| key          | value                                                       |
+--------------+-------------------------------------------------------------+
| job_zip_path | /home/eost/shared/published_jobs/docker_hello_world_0.1.zip |
+--------------+-------------------------------------------------------------+

.------------------+-----------------------------------------------------------.
|                               job2docker_start                               |
|=-----------------+----------------------------------------------------------=|
|key               |value                                                      |
|=-----------------+----------------------------------------------------------=|
|job_zip_path      |/home/eost/shared/published_jobs/docker_hello_world_0.1.zip|
|job_zip_target_dir|/home/eost/containerized                                   |
|package_command   |/home/eost/talend_distro/bin/job2docker                    |
|shell_log_file    |/home/eost/talend_distro/job2docker.log                    |
|working_dir       |                                                           |
|job_owner         |eost                                                       |
|deploy_command    |/home/eost/talend_distro/bin/deploy-aws                    |
|build_command     |/home/eost/talend_distro/job2docker_build/build            |
'------------------+-----------------------------------------------------------'

job_filename=docker_hello_world_0.1.zip
job_name=docker_hello_world
job_version=0.1
DEBUG: job_to_docker main : job_zip_path=/home/eost/shared/published_jobs/docker_hello_world_0.1.zip
DEBUG: job_to_docker main : job_zip_target_dir=/home/eost/containerized
DEBUG: job_to_docker main : working_dir=
DEBUG: job_to_docker main : tmp_working_dir=/home/eost/tmp/job2docker/0oXWVb
INFO: Copying '/home/eost/shared/published_jobs/docker_hello_world_0.1.zip' to working directory '/home/eost/tmp/job2docker/0oXWVb' : job_to_docker main
DEBUG: process_zip job_to_docker main : working_dir=/home/eost/tmp/job2docker/0oXWVb
DEBUG: process_zip job_to_docker main : job_file_name=docker_hello_world_0.1.zip
DEBUG: process_zip job_to_docker main : job_file_root=docker_hello_world_0.1
DEBUG: process_zip job_to_docker main : job_root=docker_hello_world
DEBUG: process_zip job_to_docker main : is_multi_job=false
INFO: Unzipping '/home/eost/tmp/job2docker/0oXWVb/docker_hello_world_0.1.zip' to '/home/eost/tmp/job2docker/0oXWVb/docker_hello_world_0.1' : process_zip job_to_docker main
DEBUG: process_zip job_to_docker main : rename 'jobInfo.properties' to 'jobInfo_docker_hello_world.properties'
DEBUG: process_zip job_to_docker main : rename 'routines.jar' to 'routines_docker_hello_world.jar'
DEBUG: process_zip job_to_docker main : tweak shell script to use 'routines_docker_hello_world.jar'
DEBUG: process_zip job_to_docker main : insert exec at beginning of java invocation
DEBUG: process_zip job_to_docker main : set exec permission since it is not set and is not maintianed by zip format
INFO: Dockerized zip file ready in '/home/eost/containerized/docker_hello_world.tgz' : job_to_docker main
INFO: Finished : main
[tLogRow_2] ~/talend_distro/job2docker_build ~/j2d/job2docker_listener
[tLogRow_2] INFO: main : job_owner=eost
[tLogRow_2] INFO: main : job_name=docker_hello_world
[tLogRow_2] INFO: main : job_version=0.1
[tLogRow_2] INFO: main : job_tgz_file=/home/eost/containerized/docker_hello_world.tgz
[tLogRow_2] INFO: main : job_parent_dir=/talend
[tLogRow_2] INFO: main : image_tag=eost/docker_hello_world:0.1
[tLogRow_2] Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
[tLogRow_3] package||||1
.----------------------.
|#1. tLogRow_2--job2docker_output|
+--------------+-------+
| key          | value |
+--------------+-------+
| step         | null  |
| errorMessage | null  |
| stdOut       | null  |
| errorOut     | null  |
| exitValue    | null  |
+--------------+-------+

eost@localhost:~/j2d/job2docker_listener
[eost@localhost job2docker_listener]$ exit
exit

Script done on Sat 30 Jun 2018 12:12:50 PM EDT
````
