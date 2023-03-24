# Drycc Object Storage based on MinIO&reg;

## What is Drycc Object Storage based on MinIO&reg;?

> MinIO&reg; is an object storage server, compatible with Amazon S3 cloud storage service, mainly used for storing unstructured data (such as photos, videos, log files, etc.).

[Overview of Drycc Object Storage based on MinIO&reg;](https://min.io/)

This project has been forked from [bitnami-docker-minio](https://github.com/bitnami/bitnami-docker-minio),  We mainly modified the dockerfile in order to build the images of amd64 and arm64 architectures. 

Disclaimer: All software products, projects and company names are trademark(TM) or registered(R) trademarks of their respective holders, and use of them does not imply any affiliation or endorsement. This software is licensed to you subject to one or more open source licenses and VMware provides the software on an AS-IS basis. MinIO(R) is a registered trademark of the MinIO Inc. in the US and other countries. Bitnami is not affiliated, associated, authorized, endorsed by, or in any way officially connected with MinIO Inc. MinIO(R) is licensed under GNU AGPL v3.0.

## TL;DR

```console
$ docker run --name minio quay.io/drycc-addons/minio:latest
```

### Docker Compose

```console
$ curl -sSL https://raw.githubusercontent.com/drycc-addons/drycc-docker-minio/main/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

## Get this image

The recommended way to get the Drycc MinIO(R) Docker Image is to pull the prebuilt image from the [Container Image Registry](https://quay.io/repository/drycc-addons/minio).

```console
$ docker pull quay.io/drycc-addons/minio:[TAG]
```

If you wish, you can also build the image yourself.

```console
$ docker build -t quay.io/drycc-addons/minio:latest 'https://github.com/drycc-addons/drycc-docker-minio.git#main:2022/debian'
```

## Persisting your database

If you remove the container all your data will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

For persistence you should mount a directory at the `/data` path.

```console
$ docker run --name minio \
    --publish 9000:9000 \
    --publish 9001:9001 \
    --volume /path/to/minio-persistence:/data \
    quay.io/drycc-addons/minio:latest
```

or by modifying the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-minio/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  minio:
  ...
    volumes:
      - /path/to/minio-persistence:/data
  ...
```

> NOTE: As this is a non-root container, the mounted files and directories must have the proper permissions for the UID `1001`.

## Connecting to other containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), a MinIO(R) server running inside a container can easily be accessed by your application containers.

Containers attached to the same network can communicate with each other using the container name as the hostname.

### Using the Command Line

In this example, we will create a [MinIO(R) client](https://github.com/drycc-addons/drycc-docker-minio-client) container that will connect to the server container that is running on the same docker network as the client.

#### Step 1: Create a network

```console
$ docker network create app-tier --driver bridge
```

#### Step 2: Launch the MinIO(R) server container

Use the `--network app-tier` argument to the `docker run` command to attach the MinIO(R) container to the `app-tier` network.

```console
$ docker run -d --name minio-server \
    --env MINIO_ROOT_USER="minio-root-user" \
    --env MINIO_ROOT_PASSWORD="minio-root-password" \
    --network app-tier \
    quay.io/drycc-addons/minio:latest
```

#### Step 3: Launch your MinIO(R) Client container

Finally we create a new container instance to launch the MinIO(R) client and connect to the server created in the previous step. In this example, we create a new bucket in the MinIO(R) storage server:

```console
$ docker run -it --rm --name minio-client \
    --env MINIO_SERVER_HOST="minio-server" \
    --env MINIO_SERVER_ACCESS_KEY="minio-access-key" \
    --env MINIO_SERVER_SECRET_KEY="minio-secret-key" \
    --network app-tier \
    quay.io/drycc-addons/minio-client \
    mb minio/my-bucket
```

### Using Docker Compose

When not specified, Docker Compose automatically sets up a new network and attaches all deployed services to that network. However, we will explicitly define a new `bridge` network named `app-tier`. In this example we assume that you want to connect to the MinIO(R) server from your own custom application image which is identified in the following snippet by the service name `myapp`.

```yaml
version: '2'

networks:
  app-tier:
    driver: bridge

services:
  minio:
    image: 'quay.io/drycc-addons/minio:latest'
    ports:
      - '9000:9000'
      - '9001:9001'
    environment:
      - MINIO_ROOT_USER=minio-root-user
      - MINIO_ROOT_PASSWORD=minio-root-password
    networks:
      - app-tier
  myapp:
    image: 'YOUR_APPLICATION_IMAGE'
    networks:
      - app-tier
    environment:
      - MINIO_SERVER_ACCESS_KEY=minio-access-key
      - MINIO_SERVER_SECRET_KEY=minio-secret-key
```

> **IMPORTANT**:
>
> 1. Please update the **YOUR_APPLICATION_IMAGE_** placeholder in the above snippet with your application image
> 2. In your application container, use the hostname `minio` to connect to the MinIO(R) server. Use the environment variables `MINIO_SERVER_ACCESS_KEY` and `MINIO_SERVER_SECRET_KEY` to configure the credentials to access the MinIO(R) server.

Launch the containers using:

```console
$ docker-compose up -d
```

## Configuration

MiNIO can be configured via environment variables as detailed at [MinIO(R) documentation](https://docs.min.io/docs/minio-server-configuration-guide.html).

A MinIO(R) Client  (`mc`) is also shipped on this image that can be used to perform administrative tasks as described at the [MinIO(R) Client documentation](https://docs.min.io/docs/minio-admin-complete-guide.html). In the example below, the client is used to obtain the server info:

```console
$ docker run --name minio -d quay.io/drycc-addons/minio:latest
$ docker exec minio mc admin info local
```

or using Docker Compose:

```console
$ curl -sSL https://raw.githubusercontent.com/drycc-addons/drycc-docker-minio/main/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
$ docker-compose exec minio mc admin info local
```

### Creating default buckets

You can create a series of buckets in the MinIO(R) server during the initialization of the container by setting the environment variable `MINIO_DEFAULT_BUCKETS` as shown below (policy is optional):

```console
$ docker run --name minio \
    --publish 9000:9000 \
    --publish 9001:9001 \
    --env MINIO_DEFAULT_BUCKETS='my-first-bucket:policy,my-second-bucket' \
    quay.io/drycc-addons/minio:latest
```

or by modifying the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-minio/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  minio:
  ...
    environment:
      - MINIO_DEFAULT_BUCKETS=my-first-bucket:policy,my-second-bucket
  ...
```

### Securing access to MinIO(R) server with TLS

You can secure the access to MinIO(R) server with TLS as detailed at [MinIO(R) documentation](https://docs.min.io/docs/how-to-secure-access-to-minio-server-with-tls.html).

This image expects the variable `MINIO_SCHEME` set to `https` and certificates to be mounted at the `/certs` directory. You can put your key and certificate files on a local directory and mount it in the container as shown below:

```console
$ docker run --name minio \
    --publish 9000:9000 \
    --publish 9001:9001 \
    --volume /path/to/certs:/certs \
    --env MINIO_SCHEME=https
    quay.io/drycc-addons/minio:latest
```

or by modifying the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-minio/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  minio:
  ...
    environment:
    ...
      - MINIO_SCHEME=https
    ...
    volumes:
      - /path/to/certs:/certs
  ...
```

### Setting up MinIO(R) in Distributed Mode

You can configure MinIO(R) in Distributed Mode to setup a highly-available storage system. To do so, the environment variables below **must** be set on each node:

* `MINIO_DISTRIBUTED_MODE_ENABLED`: Set it to 'yes' to enable Distributed Mode.
* `MINIO_DISTRIBUTED_NODES`: List of MinIO(R) nodes hosts. Available separators are ' ', ',' and ';'.
* `MINIO_ROOT_USER`: MinIO(R) server root user. Must be common on every node.
* `MINIO_ROOT_PASSWORD`: MinIO(R) server root password. Must be common on every node.

You can use the Docker Compose below to create an 4-node distributed MinIO(R) setup:

```yaml
version: '2'

services:
  minio1:
    image: 'quay.io/drycc-addons/minio:latest'
    environment:
      - MINIO_ROOT_USER=minio-root-user
      - MINIO_ROOT_PASSWORD=minio-root-password
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio1,minio2,minio3,minio4
      - MINIO_SKIP_CLIENT=yes
  minio2:
    image: 'quay.io/drycc-addons/minio:latest'
    environment:
      - MINIO_ROOT_USER=minio-root-user
      - MINIO_ROOT_PASSWORD=minio-root-password
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio1,minio2,minio3,minio4
      - MINIO_SKIP_CLIENT=yes
  minio3:
    image: 'quay.io/drycc-addons/minio:latest'
    environment:
      - MINIO_ROOT_USER=minio-root-user
      - MINIO_ROOT_PASSWORD=minio-root-password
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio1,minio2,minio3,minio4
      - MINIO_SKIP_CLIENT=yes
  minio4:
    image: 'quay.io/drycc-addons/minio:latest'
    environment:
      - MINIO_ROOT_USER=minio-root-user
      - MINIO_ROOT_PASSWORD=minio-root-password
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio1,minio2,minio3,minio4
      - MINIO_SKIP_CLIENT=yes
```

MinIO(R) also supports ellipsis syntax (`{1..n}`) to list the MinIO(R) node hosts, where `n` is the number of nodes. This syntax is also valid to use multiple drives (`{1..m}`) on each MinIO(R) node, where `n` is the number of drives per node. You can use the Docker Compose below to create an 2-node distributed MinIO(R) setup with 2 drives per node:

```yaml
version: '2'
services:
  minio-0:
    image: 'quay.io/drycc-addons/minio:latest'
    volumes:
      - 'minio_0_data_0:/data-0'
      - 'minio_0_data_1:/data-1'
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=miniosecret
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio-{0...1}/data-{0...1}
  minio-1:
    image: 'quay.io/drycc-addons/minio:latest'
    volumes:
      - 'minio_1_data_0:/data-0'
      - 'minio_1_data_1:/data-1'
    environment:
      - MINIO_ROOT_USER=minio
      - MINIO_ROOT_PASSWORD=miniosecret
      - MINIO_DISTRIBUTED_MODE_ENABLED=yes
      - MINIO_DISTRIBUTED_NODES=minio-{0...1}/data-{0...1}
volumes:
  minio_0_data_0:
    driver: local
  minio_0_data_1:
    driver: local
  minio_1_data_0:
    driver: local
  minio_1_data_1:
    driver: local
```

Find more information about the Distributed Mode in the [MinIO(R) documentation](https://docs.min.io/docs/distributed-minio-quickstart-guide.html).

### Reconfiguring Keys on container restarts

MinIO(R) configures the access & secret key during the 1st initialization based on the `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` environment variables, respetively.

When using persistence, MinIO(R) will reuse the data configured during the 1st initialization by default, ignoring whatever values are set on these environment variables. You can force MinIO(R) to reconfigure the keys based on the environment variables by setting the `MINIO_FORCE_NEW_KEYS` environment variable to `yes`:

```console
$ docker run --name minio \
    --publish 9000:9000 \
    --publish 9001:9001 \
    --env MINIO_FORCE_NEW_KEYS="yes" \
    --env MINIO_ROOT_USER="new-minio-root-user" \
    --env MINIO_ROOT_PASSWORD="new-minio-root-password" \
    --volume /path/to/minio-persistence:/data \
    quay.io/drycc-addons/minio:latest
```

## Logging

The Drycc MinIO(R) Docker image sends the container logs to the `stdout`. To view the logs:

```console
$ docker logs minio
```

or using Docker Compose:

```console
$ docker-compose logs minio
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration docker uses the `json-file` driver.

### HTTP log trace

To enable HTTP log trace, you can set the environment variable `MINIO_HTTP_TRACE` to redirect the logs to a specific file as detailed at [MinIO(R) documentation](https://docs.min.io/docs/minio-server-configuration-guide.html).

When setting this environment variable to `/opt/quay.io/drycc-addons/minio/log/minio.log`, the logs will be sent to the `stdout`.

```console
$ docker run --name minio \
    --publish 9000:9000 \
    --publish 9001:9001 \
    --env MINIO_HTTP_TRACE=/opt/quay.io/drycc-addons/minio/log/minio.log \
    quay.io/drycc-addons/minio:latest
```

or by modifying the [`docker-compose.yml`](https://github.com/drycc-addons/drycc-docker-minio/blob/main/docker-compose.yml) file present in this repository:

```yaml
services:
  minio:
  ...
    environment:
      - MINIO_HTTP_TRACE=/opt/drycc/minio/log/minio.log
  ...
```

## Maintenance

### Upgrade this image

Bitnami provides up-to-date versions of MinIO(R), including security patches, soon after they are made upstream. We recommend that you follow these steps to upgrade your container.

#### Step 1: Get the updated image

```console
$ docker pull quay.io/drycc-addons/minio:latest
```

or if you're using Docker Compose, update the value of the image property to
`quay.io/drycc-addons/minio:latest`.

#### Step 2: Stop and backup the currently running container

Stop the currently running container using the command

```console
$ docker stop minio
```

or using Docker Compose:

```console
$ docker-compose stop minio
```

Next, take a snapshot of the persistent volume `/path/to/minio-persistence` using:

```console
$ rsync -a /path/to/minio-persistence /path/to/minio-persistence.bkp.$(date +%Y%m%d-%H.%M.%S)
```

#### Step 3: Remove the currently running container

```console
$ docker rm -v minio
```

or using Docker Compose:

```console
$ docker-compose rm -v minio
```

#### Step 4: Run the new image

Re-create your container from the new image.

```console
$ docker run --name minio quay.io/drycc-addons/minio:latest
```

or using Docker Compose:

```console
$ docker-compose up minio
```

## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/drycc-addons/drycc-docker-minio/issues), or submit a [pull request](https://github.com/drycc-addons/drycc-docker-minio/pulls) with your contribution.
