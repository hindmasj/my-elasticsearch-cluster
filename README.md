# My Elasticsearch Cluster
A docker based Elasticsearch cluster.

This project revives a previous private project that created a simple elasticsearch cluster.

## Guides

The original release of this project was based around the basic guide at [Install Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/8.5/docker.html) which builds a single node cluster plus Kibana but forces you to capture log messages to get the validation token that allows you to connect to the instances.

The instructions at [How to Run Elasticsearch 8 on Docker for Local Development](https://levelup.gitconnected.com/how-to-run-elasticsearch-8-on-docker-for-local-development-401fd3fff829) allow you to either run passwordless, or with a password specified in the docker command. But you still need to wait for master instance to fully running before you can capture validation tokens and the CA certificate for signing new nodes.

This release starts from the advice that is a little further down the page of the above, at [start a multi-node cluster with Docker Compose](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-compose-file). This guide also draws upon the files in [the Elasticsearch Github repo](https://github.com/elastic/elasticsearch/tree/8.11/docs/reference/setup/install/docker) which provide a starting point for the environment and compose file.

## Getting Started

The starting point is to download the files **".env"** and **"docker-compose.yml"** from the reference repo.

Edit the environment file to set the Elasticsearch password and the version of Elasticsearch to use. Then pull the images and spin up the cluster.

```
docker compose pull
docker compose up -d
```

This starts 3 master/data nodes and one kibana instance. A number of volumes are created for permanent storage of data and certificates. Each node runs as its own service **es0[1-3]**. There is a setup service that runs at the beginning but exits once the cluster setup is complete.

Access the [Kibana GUI](http://localhost:5601/app/home#/) through your browser and login with the elastic user/password.

## Accessing With Curl

Make a test connection to the cluster with curl. This accesses the default port at 9200 and makes use of the CA cert to validate the node it connects to. The default port is connected to the primary service of **"es01"**. The curl setup script retrieves the CA cert from the node and creates the simple **netrc** file to hold the credentials. Then run the basic curl command to check the connection. The run curl script allows you to run API commands easily, by specifying extra parameters. The first parameter must the URL of the API call.

```
bin/curl_setup.sh
bin/run_curl.sh
bin/run_curl.sh _cat/nodes
```

## Connecting The NiFi Cluster

The goal for this project to connect external applications, in particular the NiFi cluster project [my-nifi-cluster](https://github.com/hindmasj/my-nifi-cluster)

Run up the NiFi cluster and try a curl connection from inside one of the NiFi nodes.

```
docker compose -f ../my-nifi-cluster/docker-compose.yml up -d
docker compose -p my-nifi-cluster exec --index 1 nifi curl -k https://host.docker.internal:9200 -u elastic
```
Note the use of the hostname alias for the local machine.

So that proves how to connect the NiFi nodes to the elastic network.

### Extra Credit

For extra credit use the Netrc and CA files too.

Using the Netrc file. Note the location of NiFi's home directory. Had to build definition of **host.docker.internal** into the netrc file, which has been added to the curl setup script.

```
docker compose -p my-nifi-cluster cp netrc nifi:/home/nifi/.netrc
docker compose -p my-nifi-cluster exec nifi curl -n -k https://host.docker.internal:9200/_cat/nodes
```

That works. Using the CA file I had to add the name "host.docker.internal" as a subject alternative name to the certificate for es01. This was done by modifying the command for the setup service that defines the certificates.

```
docker compose -p my-nifi-cluster cp http_ca.crt nifi:/opt/nifi/nifi-current/es_ca.crt
docker compose -p my-nifi-cluster exec nifi curl -n --cacert es_ca.crt https://host.docker.internal:9200/_cat/nodes
```

### TODO

* Automate connection of all NiFI nodes.
* Create a trust store for the NiFI nodes.
* Create an API key for NiFi.
* Create some put and lookup services and flows.

