#!/usr/bin/env bash

# Get input options
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -i | --image )
    shift; image=$1
    ;;
  -r | --registry )
    shift; registry=$1
    ;;
  -c | --container )
    shift; container=$1
    ;;
  -o | --options )
    shift; options=$1
    ;;
  -s | --start )
    start=1
    ;;
  --prune )
    prune=1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

# Validate options
if [[ -z "$image" ]]; then
  echo "Specify the image label!" 1>&2; exit 1
fi

if [[ -z "$container" ]]; then
  echo "Specify container name!" 1>&2; exit 1
fi

# End validation

if [[ -n "$registry" ]]; then
  imgprefix="$registry/"
fi

# Stop the container
echo "> Stopping container $container"
docker stop $container

# Remove the container
echo "> Removing container $container"
docker rm $container

# Create a new container
echo "> Creating container $container with options $options from image $imgprefix$image"
docker create --name $container $options $imgprefix$image || exit 1

# Start the container
if [[ $start == 1 ]]; then
    echo "> Starting $container"
    docker start $container || exit 1
fi

if [[ $prune == 1 ]]; then
  echo "> Pruning stuff"
  docker system prune -f
fi