#!/bin/sh
# NOTE: You can use this shell script to execute a CI/CD build.
# BRANCH and IMAGE_TAG are given as parameters.

BRANCH=$1     # e.g. dev, test, stag, canary, or prod
IMAGE_TAG=$2  # e.g. commit SHA

# Set environment variables
set -e
set -a
taito_mode=ci
taito_target_env=${BRANCH/master/prod}
. taito-config.sh
set +a

# Prepare build
taito build-prepare:$BRANCH $IMAGE_TAG

# Prepare artifacts for deployment in parallel
taito artifact-prepare:wordpress:$BRANCH $IMAGE_TAG

# Update wordpress plugins
taito wp-plugin-update:$BRANCH || \
  echo WARNING: Failed updating wordpress plugins

# Deploy changes to target environment
taito deployment-deploy:$BRANCH $IMAGE_TAG

# Release artifacts in parallel
taito artifact-release:wordpress:$BRANCH $IMAGE_TAG

# Release build
taito build-release:$BRANCH

# TODO: revert on fail
