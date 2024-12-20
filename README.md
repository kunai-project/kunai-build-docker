![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/kunai-project/kunai-build-docker/docker-image.yml?style=for-the-badge)

This repository contains a way to build kunai on any OS capable of running docker.

# Prepare the docker image

⚠️ The preparation step needs to be run **only once** to create the docker image we will use

1. `git clone https://github.com/kunai-project/kunai-build-docker.git`
1. `cd kunai-build-docker`
1. `docker build -t kunai-build ./`

# Build kunai with in a container

1. `git clone https://github.com/kunai-project/kunai.git`
1. `docker run -it --rm -v $PWD/kunai:/kunai-src -w /kunai-src kunai-build cargo xbuild --release`
1. Find compiled binary in `./kunai/target` directory

