# My Elasticsearch Cluster
A docker based Elasticsearch cluster.

This project revives a previous private project that created a simple elasticsearch cluster.

## Manual Preparation

The first attempt at creating a basic does everything manually.

### Preparation

Pull the basic [Elasticsearch image](https://hub.docker.com/_/elasticsearch). Note that the "latest" tag is not supported so you need to pull a specific version. For the present, version "8.11.0" is the latest. The version is saved as an environment variable for simplicity.
Then create a dedicated network.


```
export ES_VERSION=8.11.0
docker pull docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
docker network create elastic
```

### Getting Started

A few options were looked at. The basic guide at [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/8.5/docker.html) forces you to capture some log messages
in order to connect to the instances. The instructions at
[How to Run Elasticsearch 8 on Docker for Local Development](https://levelup.gitconnected.com/how-to-run-elasticsearch-8-on-docker-for-local-development-401fd3fff829)
allow you to either run passwordless, or with a password specified in the docker command.

### Single Node Instance

Here we spin up the basic development single-node single instance with a dedicated password.

```
docker run --name es01 --net elastic -p 9200:9200 -it \
-e discovery.type=single-node \
-e ES_JAVA_OPTS="-Xms1g -Xmx1g" \
-e ELASTIC_PASSWORD=elastic \
docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
```

Copy the private certificate from the instance to your local host.

```
docker cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt .
```

Create a dedicated netrc file.

```
machine localhost
login elastic
password foobar
```

Run curl to connect to the instance.

```
curl --cacert http_ca.crt -n --netrc-file ./netrc https://localhost:9200
```
### Kibana

Pull the Kibana image.

```
docker pull docker.elastic.co/kibana/kibana:${ES_VERSION}
```

Start a Kibana instance.

```
docker run \
--name kibana \
--net elastic \
-p 5601:5601 \
docker.elastic.co/kibana/kibana:${ES_VERSION}
```

You need to create an enrollment token.

```
docker exec -i es01 bin/elasticsearch-create-enrollment-token --scope kibana
```

Then connect to the kibana instance at (http://localhost:5601/) and provide the enrollment token. When configuration is complete you can login with the credentials *elastic/elastic*.

## Scripted Start

This is ongoing, using scripts and Docker Compose to create a basic cluster.

Start by defining the [Elasticsearch image version](https://hub.docker.com/_/elasticsearch) you require as an environment variable and pull the images.

```
export ES_VERSION=8.11.0
docker compose pull
```

The compose file defines the default password as "elastic" which is dumb if you are operating in a piublic network, so you might want to parameterise it. Create a local netrc file to hold the login credentials.

```
machine localhost
login elastic
password elastic
```

### Start The Master

Start the master instance by itself.

```
docker compose up -d master
```
When ready make a test connection. As the backend is only connected to the "elastic" network you cannot connect to node directly. Instead run the curl command in the container.
```
docker compose cp netrc master:/usr/share/elasticsearch/.netrc
docker compose exec master curl --cacert config/certs/http_ca.crt -n https://localhost:9200
```

### Start Kibana

Start the Kibana instance, create an enrollment token for it and retrive the verification code.

```
docker compose up -d kibana
docker compose exec master bin/elasticsearch-create-enrollment-token --scope kibana
docker compose exec kibana bin/kibana-verification-code
```
Copy the resulting token and open the [Kibana GUI](http:/localhost:5601/). Copy the enrollment token into the first dialog and supply the verification key to the second. Finally login with the credential "elastic/elastic".

### TODO

* Automate the enrollment and verification of Kibana.
* Create a script to ease the running of curl commands.
* Add some test data.
* Add a client node to the cluster.
* Add some data nodes and create permanent volumes.
* Add some users.

## Connecting The NiFi Cluster

Try this, from the NiFI cluster home directory.

```
docker network connect my-elasticsearch-cluster_elastic my-nifi-cluster-nifi-1
docker compose exec --index 1 nifi curl -k https://master:9200 -u elastic
docker compose exec --index 1 nifi curl -k https://es01:9200 -u elastic
```

So that proves how to connect the NiFi nodes to the elastic network, and then use either the service or host names to identify the master Elasticsearch node.

### TODO

* Automate connection of all NiFI nodes.
* Obtain the host certificates for NiFi and create NiFi truststore.
* Create an API key for NiFi.
* Create some put and lookup services and flows.

