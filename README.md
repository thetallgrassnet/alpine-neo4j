# What is Neo4j?

Based on the [official Neo4j Docker image](https://github.com/neo4j/docker-neo4j), built on [Alpine](https://www.alpinelinux.org/) to minimize image size.

**Note: this image is a _work in progress_ beta, and is not suited for production use**

Neo4j is a highly scalable, robust, native graph database. It is used in mission-critical apps by thousands of leading startups, enterprises, and governments around the world. You can learn more [here](http://neo4j.com/developer).

# How to use this image

The image exposes two ports (`7474` and `7473`) for HTTP and HTTPS access to the Neo4j API and a volume (`/data`) to allow the database to be persisted outside its container.

	docker run \
	    --detach \
	    --publish=7474:7474 \
	    --volume=$HOME/neo4j-data:/data \
	    thetallgrassnet/alpine-neo4j

Point your browser at `http://localhost:7474`.

Please note that by default Neo4j requires authentication. You have to login with `neo4j/neo4j` at the first connection and set a new password.

## Neo4j editions

The Neo4j comes in two editions: Community and Enterprise.

Neo4j Enterprise Edition is designed for commercial deployments where scale and availability are important. Use of Neo4j Enterprise Edition requires a commercial license agreement with Neo Technology. Please see [Neo4j licensing](http://neo4j.com/licensing/) for details.

Tags are available for both editions. Enterprise tags have an `_enterprise` suffix, Community tags have no suffix.

## Docker configuration

### File descriptor limit

Neo4j may use a large number of file descriptors if many indexes are in use or there is a large number of simultaneous database connections.

Docker controls the number of open file descriptors in a container; the limit depends on the configuration of your system. We recommend a limit of at least 40000 for running Neo4j.

To check the limit on your system, run this command:

	docker run thetallgrassnet/alpine-neo4j \
	    bash -c 'echo Soft limit: $(ulimit -Sn); echo Hard limit: $(ulimit -Hn)'

To override the default configuration for a single container, use the `--ulimit` option like this:

	docker run \
	    --detach \
	    --publish=7474:7474 \
	    --volume=$HOME/neo4j-data:/data \
	    --ulimit=nofile=40000:40000
	    thetallgrassnet/alpine-neo4j

## Neo4j configuration

The image provides a usable default configuration for learning about Neo4j, but it is not suitable for production use. You can read more about configuring Neo4j in the [manual](http://neo4j.com/docs/stable/configuration.html).

There are three ways to modify the configuration depending on how much you need to customize the image.

### Environment variables

Pass environment variables to the container when you run it.

	docker run \
	    --detach \
	    --publish=7474:7474 \
	    --volume=$HOME/neo4j-data:/data \
	    --env=NEO4J_CACHE_MEMORY=4G \
	    thetallgrassnet/alpine-neo4j

The following environment variables are available:

-	`NEO4J_CACHE_MEMORY`: the size of Neo4j's native-memory cache, defaults to 512M
-	`NEO4J_HEAP_MEMORY`: the size of Neo4j's heap in MB, defaults to the JVM default for your system
-	`NEO4J_KEEP_LOGICAL_LOGS`: the retention policy for logical logs, defaults to `100M size`
-	`NEO4J_AUTH`: controls authentication, set to `none` to disable authentication or `neo4j/<password>` to override the default password (see documentation [here](http://neo4j.com/docs/stable/rest-api-security.html))

#### Enterprise Edition

The following settings control features that are only available in the Enterprise Edition of Neo4j.

-	`NEO4J_DATABASE_MODE`: the database mode, defaults to `SINGLE`, set to `HA` to create a cluster
-	`NEO4J_SERVER_ID`: the id of the server, must be unique within a cluster
-	`NEO4J_HA_ADDRESS`: the address which a server advertises to other members of a cluster in HA mode, this must be resolvable by all cluster members
-	`NEO4J_INITIAL_HOSTS`: comma-separated list of other members of the cluster

### `/conf` volume

To make arbitrary modifications to the Neo4j configuration, provide the container with a `/conf` volume.

	docker run \
	    --detach \
	    --publish=7474:7474 \
	    --volume=$HOME/neo4j-data:/data \
	    --volume=$HOME/neo4j-conf:/conf \
	    thetallgrassnet/alpine-neo4j

The `/conf` volume will override all configuration provided by the image and must therefore contain a complete, valid set of Neo4j configuration files.

### Build a new image

For more complex customization of the image you can create a new image based on this one.

	FROM thetallgrassnet/alpine-neo4j

## Neo4j HA

In order to run Neo4j in HA mode under Docker you need to wire up the containers in the cluster so that they can talk to each other. Each container must have a network route to each of the others and the `NEO4J_HA_ADDRESS` and `NEO4J_INITIAL_HOSTS` environment variables must be set according (see above).

Within a single Docker host, this can be achieved using container names and links as follows.

	docker run --name=instance1 --detach --publish 7474:7474 \
	    --env=NEO4J_DATABASE_MODE=HA --env=NEO4J_HA_ADDRESS=instance1 --env=NEO4J_SERVER_ID=1 \
	    --env=NEO4J_INITIAL_HOSTS=instance1:5001,instance2:5001,instance3:5001 \
	    thetallgrassnet/alpine-neo4j

	docker run --name=instance2 --detach --publish 7475:7474 \
	    --link instance1:instance1 \
	    --env=NEO4J_DATABASE_MODE=HA --env=NEO4J_HA_ADDRESS=instance2 --env=NEO4J_SERVER_ID=2f \
	    --env=NEO4J_INITIAL_HOSTS=instance1:5001,instance2:5001,instance3:5001 \
	    thetallgrassnet/alpine-neo4j

	docker run --name=instance3 --detach --publish 7476:7474 \
	    --link instance1:instance1 --link instance2:instance2 \
	    --env=NEO4J_DATABASE_MODE=HA --env=NEO4J_HA_ADDRESS=instance3 --env=NEO4J_SERVER_ID=3 \
	    --env=NEO4J_INITIAL_HOSTS=instance1:5001,instance2:5001,instance3:5001 \
	    thetallgrassnet/alpine-neo4j

## Neo4j shell

The Neo4j shell can be run locally within a container using a command like this:

	docker exec --interactive <container> bin/neo4j-shell
