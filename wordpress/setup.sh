#!/bin/bash -e

# TODO: all secrets should be read from disk mount secret instead of env vars
# TODO: replace also salts and keys, so that they can be kept in kubernetes secrets
# TODO: wp-config.php: define( 'AUTOMATIC_UPDATER_DISABLED', true ); -> or leave on?
# TODO: wp-config.php: define( 'WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] . '/' );
# TODO: wp-config.php: define( 'WP_HOME', 'http://' . $_SERVER['HTTP_HOST'] . '/' );
# TODO: ---> replace all of this with a wp-config.php mounted from secret

echo "setup.sh: Move non-public files from Wordpress content root"
mkdir -p /moved
mv /opt/bitnami/wordpress/readme.html /moved
mv /opt/bitnami/wordpress/license.txt /moved
mv /opt/bitnami/wordpress/licenses /moved

echo "setup.sh: DONE"
