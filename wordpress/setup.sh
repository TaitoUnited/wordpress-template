#!/bin/bash -e

echo "setup.sh: Move non-public files from Wordpress content root"
mkdir -p /moved
mv /opt/bitnami/wordpress/readme.html /moved
mv /opt/bitnami/wordpress/license.txt /moved
mv /opt/bitnami/wordpress/licenses /moved

echo "setup.sh: DONE"
