[![Circle CI](https://circleci.com/gh/Dynom/ginit/tree/master.svg?style=shield)](https://circleci.com/gh/Dynom/ginit) [![Go Report Card](https://goreportcard.com/badge/github.com/Dynom/ginit)](https://goreportcard.com/report/github.com/Dynom/ginit)

# Introduction

ginit is a small signal proxy program that solves the "Docker pid 1" problem. It's written in Go and it's being used at https://pimmr.com/ and in a Docker container near you.

# Use in your Docker image

Make sure that ginit is available on your image and change your CMD command to have ginit as it's first argument.

```dockerfile
ADD ginit /ginit
CMD ["/ginit", "/bin/sleep", "3600"]
```

# Building ginit

To produce a linux binary; Clone/download the repository and build it like so:

```sh
GOOS=linux go build
```

It should work fine on most linux distributions, but it's thoroughly tested and compatible with https://www.alpinelinux.org/.

# More information

## When should I use it?
Whenever you run a single application (not deamon) within a Docker container, which is typically so when you follow the [12 factor application design approach](http://12factor.net/). Applications that spawn daemons, like Postgresql for example, have mechanisms to handle the child-process reaping problems themselves.

## What does ginit support?
It's designed to support only one program (child) to launch. To call ginit a real init replacement system is therefor stretching it's  definition.

## The Docker pid 1 problem?
A thorough write-up can be found here: https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

## Is this the only solution?
Far from it, many initiatives have been made to write a small signal-proxy-wrapper. Most of them contain more features and may do other things you're looking for. To name a few:

* https://github.com/krallin/tini (language: C)
* https://github.com/Yelp/dumb-init (language: C)
* https://github.com/rciorba/pidunu (language: C)
* https://github.com/ohjames/smell-baron (language: C)
