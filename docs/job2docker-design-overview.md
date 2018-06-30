# Job2Docker Design Overview

Job2docker provides a simple mechanism for developers to automate builds of containers from their Studio.
It is intended to run locally for a single developer.
Job2docker can be incorporated into a CI build environment.
When run as part of the CI build script, job2docker will presumably run on a CI server local to Nexus and the SCM.
It will create a Docker image and supporting artifacts closer to the Docker registry so there will be less network overhead than transferring from a laptop.

## Job2Docker Design

1.  A Talend job2docker_listener job is used to monitor a shared directory.
2.  The developer clicks Build in Talend Studio to create Talend job zip file in the shared directory.
3.  The Talend `job2docker_listener` triggers the `job2docker` script to convert the Talend zip file to a tgz ready for Docker.
4.  The Talend `job2docker_listener` triggers the `job2docker_build` script.
5.  The Talend `job2docker_listener` optionally publishes the resulting container to a Docker Registry.
