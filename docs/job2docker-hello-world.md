# HelloWorld with Job2Docker

* [Build helloworld job to shared directory](#build-docker-job)
* [Run helloworld job container](#run-job-in-container)
* [Passing Parameters via Docker Commandline](#passing-parameters-via-docker-commandline)

## Build Docker Job

The jobs directory includes a simple HelloWorld job.
Both the exported job and the built job are included for reference.
Use the `Import Items` capability to load `docker_hello_world.zip` into Studio.

![import job](pictures/import_items.jpg)

Use `Build Job` to generate the zip file in the shared directory previously created.

![build job](pictures/build_job.jpg)

Confirm that the docker image has been built

````
sudo docker images

REPOSITORY                                          TAG                 IMAGE ID            CREATED              SIZE
eost/docker_hello_world                             0.1                 ce044e5cbcb7        About a minute ago   176MB
````

You should see output similar to the [job2docker_listener console](job2docker_listener_console_sample.md)

## Run Job in Container

You can run the HelloWorld job from the container using the Docker run command.

````
docker run ${USER}/docker_hello_world:0.1
log4j:ERROR Could not connect to remote log4j server at [localhost]. We will try again later.
hello world
````


## Passing Parameters via Docker Commandline

The docker image has a single entry point using the exec shell style.

    ENTRYPOINT [ "/bin/ash", "/talend/docker_hello_world_0.1/docker_hello_world/docker_hello_world_run.sh" ]

So any command line arguments to the docker run command will be appended to the `hello_world_run.sh` invocation within the container.

Therefore, you can set context variables from the Docker run command using standard Talend syntax.
The HelloWorld job takes a single context variable parameter named `message`.

````
docker run ${USER}/docker_hello_world:0.1 --context_param message="Greetings earthling"
log4j:ERROR Could not connect to remote log4j server at [localhost]. We will try again later.
Greetings earthling
````

