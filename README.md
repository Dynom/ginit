[![Circle CI](https://circleci.com/gh/Dynom/ginit/tree/master.svg?style=shield)](https://circleci.com/gh/Dynom/ginit) [![Go Report Card](https://goreportcard.com/badge/github.com/Dynom/ginit)](https://goreportcard.com/report/github.com/Dynom/ginit)

# Introduction

ginit is a small signal proxy init program that solves the "Docker pid 1" problem.

# Use in your Docker image

First make sure that ginit is available on your image and change your CMD command to have ginit as it's first argument.

```dockerfile
ADD ginit /ginit
CMD ["/ginit", "/bin/sleep", "3600"]
```

# Building ginit

To produce a linux binary; Clone/download the repository and build it like so:

```sh
GOOS=linux go build
```

