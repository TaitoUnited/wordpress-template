#!/bin/sh

##################################################################
# NOTE: Run CI/CD builds locally with command 'taito ci run:ENV'
##################################################################

BRANCH=$1     # e.g. dev, test, stag, canary, or prod
IMAGE_TAG=$2  # e.g. commit SHA

set -e
export taito_mode=ci
# Always build with local CI:
echo "export ci_exec_build=true" >> ./taito-config.sh

# Prepare build
taito build prepare:$BRANCH $IMAGE_TAG

# Prepare artifacts for deployment
taito artifact prepare:wordpress:$BRANCH $IMAGE_TAG

# Update wordpress plugins
taito wp plugin update:$BRANCH || \
  echo WARNING: Failed updating wordpress plugins

# Deploy changes to target environment
taito deployment deploy:$BRANCH $IMAGE_TAG

# Release artifacts
taito artifact release:wordpress:$BRANCH $IMAGE_TAG

# Release build
taito build release:$BRANCH

# TODO: revert on fail
