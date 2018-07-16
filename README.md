# Talend Docker Example

This repository includes sample bash scripts which allow you to deploy Talend jobs to Docker containers.

The `job2docker` approach converts a single Talend job zip file to a container.
The resulting Docker image will have a single entry point for the job.
It is intended for use by developers during their build / test / debug cycle and provides desktop parity.

* [Prerequisites](docs/prerequisites.md)
* [Setup](#setup)
* [Environment](#environment)
* [Directory Index](#directory-index)
* [Getting Started](#getting-started)


## Setup

A setup script is provided for linux.  
The script will clone the job2docker directory and working directories under a target directory which defaults to ${HOME}/talend.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup)
````

The files can be installed under an alternate directory by passing a parameter to the script.

````bash
    bash <(curl https://raw.githubusercontent.com/Talend/job2docker/master/job2docker-setup) ${HOME}/mytalend
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

* [Job2Docker Design Overview](docs/job2docker-design-overview.md)
* [Job2Docker HelloWorld](docs/job2docker-hello-world.md)
* [Job2Docker HelloWorld Config Files](docs/job2docker-hello-world-config-files.md)

