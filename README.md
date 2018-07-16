# Talend Docker Example

This repository includes sample bash scripts which allow you to deploy Talend jobs to Docker containers.

The `job2docker` approach converts a single Talend job zip file to a container.
The resulting Docker image will have a single entry point for the job.
It is intended for use by developers during their build / test / debug cycle and provides desktop parity.

* [Pre-requisites](#pre-requisites)
* [Environment](#environment)
* [Directory Index](#directory-index)
* [Setup](#setup)
* [Getting Started](#getting-started)


## Pre-Requisites

* [Docker](https://docs.docker.com/install/linux/docker-ce/centos/)
* [Git](https://gist.github.com/derhuerst/1b15ff4652a867391f03#file-linux-md)
* [Oracle JRE](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Talend Studio](https://info.talend.com/request-talend-data-integration.html)


## Environment

* All containerization work is done on Linux with Docker installed.
* Talend Studio steps can run on a separate machine if desired, it could be a Windows machine.
* A common drop point (shared directory, shared network drive, shared folder) for Jobs built from Studio to be processed by job2docker.

* The environment used to test these scripts was a Windows laptop running Talend Studio.
* The docker scripts were run on an Ubuntu 16.04.2 LTS VM running kernel 4.4.0-97-generic.
* It was also tested with a Centos 7 VM running kernel 3.10.0-862.6.3.el7.x86_64.
* VirtualBox was used for the VM hosting.
* A shared folder was created using VirtualBox so that Studio builds would be visible to the Linux VM.


## Directory Index

* bin - scripts for creating docker images, creating containers, and deploying images to the cloud
* docs - additional readme files
* job2docker - working directory for running the agent that monitors the build directory for Talend zip files
* job2docker_build - sample Dockerfile used to create Docker image containing the Talend job
* util - utility bash scripts


## Setup

### Scripted Setup

A setup script is provided for linux.  
The script will clone the job2docker directory and create j2d and containerized working directories under a directory which defaults to the user's home directory.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup)
````

The files can be installed under an alternate directory by passing a parameter to the script.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup) ${HOME}/talend
````

### Manual Setup

#### Install Docker

Install Docker for your host OS

* [Install Docker on Centos](https://docs.docker.com/install/linux/docker-ce/centos/)
* [Install Docker on Debian](https://docs.docker.com/install/linux/docker-ce/debian/)
* [Install Docker on Fedora](https://docs.docker.com/install/linux/docker-ce/fedora/)
* [Install Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

For AWS Linux

````
sudo yum update -y
sudo yum install -y docker
sudo service docker start
````

Optional - Follow the [Linux post-installation steps](https://docs.docker.com/install/linux/linux-postinstall/) for Docker to create a Docker user group.  This is required for the job2docker process to be able to invoke Docker without sudo.
Note that this grants root equivalent privileges to the account so it must be used with care.


````bash
sudo groupadd docker
sudo usermod -aG docker $USER
# logout and log back in so the settings take effect
````

Test that docker is running
````bash
docker run hello-world
````

#### Download Scripts

Use git clone to download this repository.

````bash
git clone https://github.com/Talend/job2docker.git
````

#### Create a Shared Directory

This step is only required for job2docker mode.

If you are running Studio on Linux then just create a directory that will be used as the target for Studio builds.

If you are running Studio on Windows, then either use either a network share common to both Linux and Windows machines or [create a Shared folder](https://www.techrepublic.com/article/how-to-share-folders-between-guest-and-host-in-virtualbox/).  You will build your jobs from Studio to this directory and it will be monitored by the job2docker utililty.

#### Job2Docker Listener

The job2docker_listener is just a Talend job that listens on a directory and kicks off the bash scripts found in this git repo.
The `job2docker_listener_0.1.zip` file is in the jobs directory.  It contains the already built job.
Unzip this to a folder and then modify the context variables as shown in the steps below.
Create a parent directory for this job since Talend zip files are not grouped under a parent directory by default.
The multiple redundant names can be a bit confusing, so use an abbreviated name for the top level.

````bash
cd $HOME
mkdir j2d
cd j2d
unzip ${HOME}/job2docker/jobs/job2docker_listener_0.1.zip
````

Edit the `Default.properties` file to point to your own directory paths.

````bash
cd job2docker_listener/se_demo/job2docker_listener_0_1/contexts
nano -w Default.properties
````

````
#this is context properties
#Wed Jun 20 04:00:15 EDT 2018
job_publish_directory=${HOME}/shared/published_jobs
job_zip_target_dir=${HOME}/containerized
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
mkdir -p ${HOME}/containerized
````

You will also need to set the execute permission on the shell script to start the job.

````bash
cd ${HOME}/j2d/job2docker_listener
chmod +x job2docker_listener_run.sh
````

Start the job2docker_listener process

````
./job2docker_listener_run.sh
````

You should see output similar to the below

````
log4j:ERROR Could not connect to remote log4j server at [localhost]. We will try again later.
Listening on /home/eost/shared/published_jobs
````


## Getting Started

* [Job2Docker Design Overview](docs/job2docker-design-overview.md)
* [Job2Docker HelloWorld](docs/job2docker-hello-world.md)
* [Job2Docker HelloWorld Config Files](docs/job2docker-hello-world-config-files.md)

