#!/usr/bin/env bash

# Get input options
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -i | --image )
    shift; image=$1
    ;;
  -r | --registry )
    shift; registry=$1
    ;;
  -u | --user )
    shift; user=$1
    ;;
  -p | --password )
    shift; password=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

# Validate options
if [[ -z "$image" ]]; then
  echo "Specify the image label!" 1>&2; exit 1
fi

if [[ -n "$user" ]] && [[ -z "$password" ]]; then
  echo "Specify registry password!" 1>&2; exit 1
fi

if [[ -z "$user" ]] && [[ -n "$password" ]]; then
  echo "Specify registry login!" 1>&2; exit 1
fi

# End validation

# Login to registry if required
if [[ -n "$user" ]]; then
  echo "> Logging in to registry $registry"
  docker login -u "$user" -p "$password" $registry || exit 1
fi

# Pull the image
if [[ -n "$registry" ]]; then
  imgprefix="$registry/"
fi

echo "> Pulling image $imgprefix$image"
docker pull $imgprefix$image || exit 1

# Logout from registry
if [[ -n "$user" ]]; then
  echo "> Logging out from registry $registry"
  docker logout $registry
fi
