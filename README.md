# My Elasticsearch Cluster
A docker based Elasticsearch cluster.

This project revives a previous private project that created a simple elasticsearch cluster.

## Preparation

Pull the basic [Elasticsearch image](https://hub.docker.com/_/elasticsearch). Note that the "latest" tag is not supported so you need to pull a specific version. For the present, version "8.11.0" is the latest.
Then create a dedicated network.


```
export ES_VERSION=8.11.0
docker pull docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
docker network create elastic
```

## Getting Started

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
