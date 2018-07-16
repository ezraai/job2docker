# Talend Docker Example

This repository includes sample bash scripts and utilities which allow you to deploy Talend jobs to Docker containers.

The `job2docker` approach converts a single Talend job zip file to a container.
The resulting Docker image will have a single entry point for the job.
It is intended for use by developers during their build / test / debug cycle and provides desktop parity.


* [Job2Docker Workflow](#job2docker-workflow)
* [Prerequisites](#prerequisites)
* [Setup](#setup)
* [Environment](#environment)
* [Directory Index](#directory-index)
* [Getting Started](#getting-started)


## Job2Docker Workflow

1.  A Talend job2docker_listener job is used to monitor a shared directory.
2.  The developer clicks Build in Talend Studio to create Talend job zip file in the shared directory.
3.  The Talend `job2docker_listener` triggers the `job2docker` script to convert the Talend zip file to a tgz ready for Docker.
4.  The Talend `job2docker_listener` triggers the `job2docker_build` script.
5.  The Talend `job2docker_listener` optionally publishes the resulting container to a Docker Registry.


Job2docker can be incorporated into a CI build environment, but it is out of scope for this cookbook.
When run as part of the CI build script, job2docker will presumably run on a CI server local to Nexus and the SCM.
Running job2docker in such a CI server will create a Docker image and supporting artifacts closer to the Docker registry so there will be less network overhead than transferring from a laptop.


## Prerequisites

* [Docker](docs/install-docker.md)
* [Git](https://gist.github.com/derhuerst/1b15ff4652a867391f03#file-linux-md)
* [Oracle JRE](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Talend Studio](https://info.talend.com/request-talend-data-integration.html)
* A [shared folder](docs/vm_shared_folder.md) accessible from both Studio and docker machines.


## Setup

A setup script is provided for linux.  
The script will clone the job2docker directory and working directories under a target directory which defaults to ${HOME}/talend.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup)
````

Jobs built by Studio are dropped into a shared directory that defaults to `${HOME}/shared_jobs`.  This can be overridden by passing a parameter.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup) ${HOME}/my_shared_jobs
````

The files can be installed under an alternate directory by passing a second parameter to the script.  Note that the shared job directory parameter must also be supplied as the first argument.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup) ${HOME}/shared_jobs ${HOME}/mytalend
````

Launch the job2docker_listener from the target directory.

````bash
    ${HOME}/talend/job2docker_listener
````

[Manual install instructions](docs/manual_install.md) are available if you prefer.


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

* job2docker/job2docker-setup - install script
* job2docker/bin - scripts for creating docker images, creating containers, and deploying images to the cloud
* job2docker/docs - additional readme files
* job2docker/job2docker_build - sample Dockerfile used to create Docker image containing the Talend job
* job2docker/util - utility bash scripts
* job2docker/jobs - sample jobs
* j2d - created during setup, working directory for running the agent that monitors the build directory for Talend zip files


## Getting Started

* [Job2Docker HelloWorld](docs/job2docker-hello-world.md)
* [Job2Docker HelloWorld Config Files](docs/job2docker-hello-world-config-files.md)

