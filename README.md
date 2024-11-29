![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/kunai-project/kunai-build-docker/docker-image.yml?style=for-the-badge)

This repository contains a way to build kunai on any Linux distribution

# Prepare the docker container

⚠️ The preparation step needs to be run only once to create the docker container we will use

1. `git clone https://github.com/kunai-project/kunai-build-docker.git`
1. `cd kunai-build-docker`
1. `docker build -t kunai-build ./`

# Build kunai with the container

1. `git clone https://github.com/kunai-project/kunai.git`
1. `docker run -it --rm -v $PWD/kunai:/kunai-src -w /kunai-src kunai-build cargo xbuild --release`


