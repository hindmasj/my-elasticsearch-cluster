# My Elasticsearch Cluster
A docker based Elasticsearch cluster.

This project revives a previous private project that created a simple elasticsearch cluster.

## Getting Started

Follow [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/8.5/docker.html). Pull the basic Elasticsearch image. Note that the "latest" tag is not supported so you need to pull a specific version. For the present, version "8.5.3" is the latest.

```
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.5.3
```

Spin up the basic development single-node instance in a dedicated network.

```
docker network create elastic
docker run --name es01 --net elastic -p 9200:9200 -it docker.elastic.co/elasticsearch/elasticsearch:8.5.3
```

Capture the security credentials.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Elasticsearch security features have been automatically configured!
✅ Authentication is enabled and cluster connections are encrypted.

ℹ️  Password for the elastic user (reset with `bin/elasticsearch-reset-password -u elastic`):
  foobar

...
```

Copy the private certificate from the instance to your local host.

```
docker cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt .
```

Run curl to connect to the instance. Use the captured password when prompted.

```
curl --cacert http_ca.crt -u elastic https://localhost:9200
```

Make this simpler by using a ".netrc" file. Use ``vi ~/.netrc``.

```
machine localhost
login elastic
password foobar
```

```
curl --cacert http_ca.crt -n https://localhost:9200/_cat/health
```
