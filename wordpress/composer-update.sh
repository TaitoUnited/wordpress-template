#!/bin/bash

# Run with "taito composer update" inside the container

pushd /bitnami/wordpress

composer update

popd
