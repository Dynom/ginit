[![Circle CI](https://circleci.com/gh/Dynom/ginit/tree/master.svg?style=shield)](https://circleci.com/gh/Dynom/ginit) [![Go Report Card](https://goreportcard.com/badge/github.com/Dynom/ginit)](https://goreportcard.com/report/github.com/Dynom/ginit)

# Introduction

ginit is a small signal proxy program that solves the "Docker pid 1" problem. It's written in Go and it's being used at https://pimmr.com/ and in a Docker container near you.

# Usage

Make sure that ginit is available on your image and change your CMD command to have ginit as it's first argument.

```dockerfile
ADD ginit /ginit
CMD ["/ginit", "/bin/sleep", "3600"]
```

## Creating a Docker image with ginit

A minimalistisc Dockerfile, including download verification, could be:

```dockerfile
FROM alpine:latest

MAINTAINER mark@dynom.nl

ENV GITHUB_DL_URL https://github.com/Dynom/ginit/releases/download/
ENV GINIT_VERSION v0.1.0
ENV BINARY_NAME ginit-${GINIT_VERSION}-linux-386.tar.gz
ENV BINARY_URL ${GITHUB_DL_URL}/${GINIT_VERSION}/${BINARY_NAME}
RUN apk update && apk upgrade && \
    apk add --no-cache openssl && \
    wget -q ${BINARY_URL} ${BINARY_URL}.sha512 && \
    sha512sum -sc ${BINARY_NAME}.sha512 && \
    tar zxf ${BINARY_NAME} -C / && \
    apk del openssl && \
    rm -rf /tmp/* /var/cache/apk/*

ENTRYPOINT ["/ginit"]
```
building it:
```sh
$ docker build -t dynom/ginit:test .
```

And proving that it works:
```sh
$ docker run dynom/ginit:test ps aux
PID   USER     TIME   COMMAND
    1 root       0:00 /ginit ps aux
   10 root       0:00 ps aux
```

# Obtaining ginit
## Releases
You can download pre-build binaries on the release page: [Releases](https://github.com/Dynom/ginit/releases)
## From source

To produce a linux binary; Clone/download the repository and build it like so:

```sh
GOOS=linux go build
```

It should work fine on most linux distributions, but it's thoroughly tested and compatible with https://www.alpinelinux.org/.

# More information

## Dependencies
None really.

## When should I use it?
Whenever you run a single application (not deamon) within a Docker container, which is typically so when you follow the [12 factor application design approach](http://12factor.net/). Applications that spawn daemons, like Postgresql for example, have mechanisms to handle the child-process reaping problems themselves.

So when you need to wait a long (>=5 seconds) time before your container process stops (using Docker compose or systemd style unit scripts), it can be due to the fact that your program doesn't correctly receive the SIGTERM/SIGINT signal. Ginit solves that for you.

## Limitations
It's designed to support only one program (child) to launch. To call ginit a real init replacement system is therefor stretching it's  definition.

## The Docker pid 1 problem?
A thorough write-up can be found here: https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

## Is this the only solution?
Far from it. Many initiatives have been made to write a solution for the same problem. From full-blown init systems to small signal-proxy-wrappers, such as ginit. Most of them contain more features and might offer you something specific that you need: To name a few:

* https://github.com/krallin/tini (language: C)
* https://github.com/Yelp/dumb-init (language: C)
* https://github.com/rciorba/pidunu (language: C)
* https://github.com/ohjames/smell-baron (language: C)
