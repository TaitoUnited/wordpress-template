#!/bin/bash -e

# Custom wordpress-template implementation for fetching database settings
# from environment variables.
# https://github.com/bitnami/bitnami-docker-wordpress/issues/128#issuecomment-389427845

# TODO: all secrets (e.g. db password) should be read from disk mount instead of env vars
# TODO: replace also salts and keys, so that they can be kept in kubernetes secrets
# TODO: wp-config.php: define( 'AUTOMATIC_UPDATER_DISABLED', true ); -> or leave on?
# TODO: wp-config.php: define( 'WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST'] . '/' );
# TODO: wp-config.php: define( 'WP_HOME', 'http://' . $_SERVER['HTTP_HOST'] . '/' );
# TODO: ---> replace all of this with a wp-config.php mounted from secret

echo "setup.sh: Adding support for database environment variables"

echo "setup.sh: Modifying getDatabaseProperties() function of helpers.js"
cp /.nami/components/com.bitnami.wordpress/helpers.js \
  /.nami/components/com.bitnami.wordpress/helpers.orig.js
sed 's/app.helpers.getDatabaseProperties/app.helpers.getDatabasePropertiesOrig/' \
  /.nami/components/com.bitnami.wordpress/helpers.orig.js \
  > /.nami/components/com.bitnami.wordpress/helpers.js
cat /template/helpers.js \
  >> /.nami/components/com.bitnami.wordpress/helpers.js

echo "setup.sh: Updating wp-config-sample.php with environment variable references"
cp /opt/bitnami/wordpress/wp-config-sample.php /opt/bitnami/wordpress/wp-config-sample.orig.php
sed "s/define( 'DB_NAME'.*$/define( 'DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
  /opt/bitnami/wordpress/wp-config-sample.orig.php |
sed "s/define( 'DB_USER'.*$/define( 'DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
sed "s/define( 'DB_PASSWORD'.*$/define( 'DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
sed "s/define( 'DB_HOST'.*$/define( 'DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
  > /opt/bitnami/wordpress/wp-config-sample.php

# TODO: duplicate code
echo "setup.sh: Updating wp-config.php with environment variable references"
cp /opt/bitnami/wordpress/wp-config.php /opt/bitnami/wordpress/wp-config.orig.php
sed "s/define( 'DB_NAME'.*$/define( 'DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
  /opt/bitnami/wordpress/wp-config.orig.php |
sed "s/define( 'DB_USER'.*$/define( 'DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
sed "s/define( 'DB_PASSWORD'.*$/define( 'DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
sed "s/define( 'DB_HOST'.*$/define( 'DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
  > /opt/bitnami/wordpress/wp-config.php

echo "setup.sh: DONE"
