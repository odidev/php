#!/usr/bin/env bash
# arg1: name of destination dockerhub
# arg2: dockerhub username
# arg3: dockerhub password

set -x -e

buildnumber=${4-$(date -u +"%y%m%d%H%M")}

docker login -u "$2" -p "$3"

# build base images
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name samplekit
docker buildx use samplekit
docker buildx inspect --bootstrap
docker buildx build -t "$1"/php:5.6-apache_"$buildnumber" --platform linux/arm64,linux/amd64 --push 5.6-apache
docker buildx build -t "$1"/php:7.0-apache_"$buildnumber" --platform linux/arm64,linux/amd64 --push 7.0-apache
docker buildx build -t "$1"/php:7.2-apache_"$buildnumber" --platform linux/arm64,linux/amd64 --push 7.2-apache
docker buildx build -t "$1"/php:7.3-apache_"$buildnumber" -t "$1"/php:latest_"$buildnumber" -t "$1"/php:latest --platform linux/arm64,linux/amd64 --push 7.3-apache

# xdebug depends on base images
# generate dockerfile for xdebug
sed -e s/reponame/"$1"/g -e s/buildnumber/"$buildnumber"/g 5.6-apache-xdebug/Dockerfile.template > 5.6-apache-xdebug/Dockerfile
sed -e s/reponame/"$1"/g -e s/buildnumber/"$buildnumber"/g 7.0-apache-xdebug/Dockerfile.template > 7.0-apache-xdebug/Dockerfile
sed -e s/reponame/"$1"/g -e s/buildnumber/"$buildnumber"/g 7.2-apache-xdebug/Dockerfile.template > 7.2-apache-xdebug/Dockerfile
sed -e s/reponame/"$1"/g -e s/buildnumber/"$buildnumber"/g 7.3-apache-xdebug/Dockerfile.template > 7.3-apache-xdebug/Dockerfile

# build xdebug images
docker buildx build -t "$1"/5.6-apache-xdebug_"$buildnumber" --platform linux/arm64,linux/amd64 --push 5.6-apache-xdebug
docker buildx build -t "$1"/7.0-apache-xdebug_"$buildnumber" --platform linux/arm64,linux/amd64 --push 7.0-apache-xdebug
docker buildx build -t "$1"/7.2-apache-xdebug_"$buildnumber" --platform linux/arm64,linux/amd64 --push 7.2-apache-xdebug
docker buildx build -t "$1"/7.3-apache-xdebug_"$buildnumber" -t "$1"/php:latest-xdebug_"$buildnumber" -t "$1"/php:latest-xdebug --platform linux/arm64,linux/amd64 --push 7.3-apache-xdebug
docker buildx rm samplekit 
docker logout
