# Manual Install

* [Download Scripts](#download-scripts)
* [Create a Shared Directory](#create-a-shared-directory)
* [Job2Docker Listener](#job2docker-listener)

## Download Scripts

Use git clone to download this repository.

````bash
git clone https://github.com/Talend/job2docker.git
````

## Create a Shared Directory

If you are running Studio on Linux then just create a directory that will be used as the target for Studio builds.

If you are running Studio on Windows, then either use either a network share common to both Linux and Windows machines
or [create a Shared folder](vm_shared_folder.md).
You will build your jobs from Studio to this directory and it will be monitored by the job2docker utililty.

## Job2Docker Listener

The job2docker_listener is just a Talend job that listens on a directory and kicks off the bash scripts found in this git repo.
The `job2docker_listener_0.1.zip` file is in the jobs directory.  It contains the already built job.
Unzip this to a folder and then modify the context variables as shown in the steps below.
Create a parent directory for this job since Talend zip files are not grouped under a parent directory by default.
The multiple redundant names can be a bit confusing, so use an abbreviated name for the top level.

````bash
mkdir -p ${HOME}/j2d
cd ${HOME}/j2d
unzip ${HOME}/job2docker/jobs/job2docker_listener_0.1.zip
````

Edit the `Default.properties` file to point to your own directory paths.

````bash
nano -w ${HOME}/j2d/job2docker_listener/se_demo/job2docker_listener_0_1/contexts/Default.properties
````

````
#this is context properties
#Wed Jun 20 04:00:15 EDT 2018
job_publish_directory=${HOME}/shared/published_jobs
job_zip_target_dir=${HOME}/j2d/containerized
working_dir=
package_command=${HOME}/job2docker/bin/job2docker
build_command=${HOME}/job2docker/job2docker_build/build
deploy_command=${HOME}/job2docker/bin/deploy-aws
job_owner=eost
````

In the example above the `job_publish_directory` is the shared directory being monitored by the job2docker_listener job.

The `working_dir` can be left blank.  The scripts will use a temporary directory.

Change the package, build, and deploy paths to point to where you cloned this repo.

You need to create the `job_zip_target_dir`.  It is a working directory that will hold the modified job tgz file.

````bash
mkdir -p ${HOME}/j2d/containerized
````

You will also need to set the execute permission on the shell script to start the job.

````bash
cd ${HOME}/j2d/job2docker_listener
chmod +x job2docker_listener_run.sh
````

Start the job2docker_listener process

````
${HOME}/j2d/job2docker_listener_run.sh
````

You should see output similar to the below

````
log4j:ERROR Could not connect to remote log4j server at [localhost]. We will try again later.
Listening on /home/eost/shared/published_jobs
````
