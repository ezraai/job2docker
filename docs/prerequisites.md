# Install Pre-Requisites

## Pre-Requisites

* [Docker](#install-docker)
* [Git](https://gist.github.com/derhuerst/1b15ff4652a867391f03#file-linux-md)
* [Oracle JRE](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Talend Studio](https://info.talend.com/request-talend-data-integration.html)


## Install Docker

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
