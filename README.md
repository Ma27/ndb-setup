# `ndb-setup`

This repository provides a simple, [docker-compose](https://docs.docker.com/compose/)-based
setup to host a live-system of [aam-digital](https://www.aam-digital.com/).

## Prerequisites

* [docker-compose](https://docs.docker.com/compose/)
* [python3](https://www.python.org/)

## Setup

### Development

This repository contains a simple development environment that can be used to test the service
or to debug issues with live data.

That setup is fairly similar to the production environment, both share common configuration
under `env/common`, the `development` environment provides some sensitive defaults
for local configuration (like a port-forward of the http port to `localhost:8080`).

The service can be configured locally by running the following commands:

```
./startup.sh up -d
./scripts/initial-setup.sh
./scripts/add-user.py demo pass --host localhost:8080
```

### Production

The production environment uses similar configuration which lives under `env/prod`. In addition
to the default services `app` and `couchdb`, this environment provides another nginx instance
to retrieve [ACME certificates from let's encrypt](https://letsencrypt.org).

To deploy `ndbserver` to a production-environment, the following steps are needed:

* Adjust the domains in `env/prod` to the domains to use.
* Start the containers by running `ENV=prod ./startup.sh up -d`.

## Docker Images

By default, the latest docker image from Docker Hub named
[aamdigital/ndb-server](https://hub.docker.com/r/aamdigital/ndb-server) is used. A custom
image can be built by running `docker build docker/ -t ndb-tmp` in the
[ndb-core repository](https://github.com/aam-digital/ndb-core). After that the image
must be modified in `env/dev/docker-compose.yml` in the `app` service to `ndb-tmp`.

The image builds upon a simple nginx webserver
and modifies the configuration to include a reverse proxy for the `domain.com/db` URLs
to access the CouchDB database from the same domain, avoiding CORS issues.
