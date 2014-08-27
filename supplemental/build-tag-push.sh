#!/bin/bash

# Simple script to build and tag the images for these
# benchmark tests and push them to a private repo for
# ease of testing.

# Pass the hostname of your repository as the single
# argument to this script.

BASEDIR=$(pwd)
REMOTE_REPO="$1"

for DOCKERFILE in $(find . -iname Dockerfile) ; do
  DIRNAME=$(dirname $DOCKERFILE)
  BASENAME=$(echo $DIRNAME | sed 's|./||')
  cd $DIRNAME && \
  sudo docker build -t $BASENAME .
  sudo docker tag $BASENAME $REMOTE_REPO/bench-$BASENAME
  sudo docker push $REMOTE_REPO/bench-$BASENAME
  cd $BASEDIR
done
