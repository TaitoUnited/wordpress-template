#!/bin/bash

# This is run (once) at container startup in local environment
# Delete data/wordpress/.user_scripts_initialized file and restart container to run again

pushd /bitnami/wordpress

composer install

popd
