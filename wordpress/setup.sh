#!/bin/bash -e

# Custom wordpress-template implementation for fetching database settings
# from environment variables.
# https://github.com/bitnami/bitnami-docker-wordpress/issues/128#issuecomment-389427845
# TODO: db password should be read from disk mount

echo "setup.sh: Adding support for database environment variables"

echo "setup.sh: Modifying getDatabaseProperties() function of helpers.js"
cp /root/.nami/components/com.bitnami.wordpress/helpers.js \
  /root/.nami/components/com.bitnami.wordpress/helpers.orig.js
sed 's/app.helpers.getDatabaseProperties/app.helpers.getDatabasePropertiesOrig/' \
  /root/.nami/components/com.bitnami.wordpress/helpers.orig.js \
  > /root/.nami/components/com.bitnami.wordpress/helpers.js
cat /template/helpers.js \
  >> /root/.nami/components/com.bitnami.wordpress/helpers.js

echo "setup.sh: Updating wp-config-sample.php with environment variable references"
cp /opt/bitnami/wordpress/wp-config-sample.php /opt/bitnami/wordpress/wp-config-sample.orig.php
sed "s/define('DB_NAME'.*$/define('DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
  /opt/bitnami/wordpress/wp-config-sample.orig.php |
sed "s/define('DB_USER'.*$/define('DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
# TODO: db password should be read from disk mount
sed "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
sed "s/define('DB_HOST'.*$/define('DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
  > /opt/bitnami/wordpress/wp-config-sample.php

# TODO: duplicate code
echo "setup.sh: Updating wp-config.php with environment variable references"
cp /opt/bitnami/wordpress/wp-config.php /opt/bitnami/wordpress/wp-config.orig.php
sed "s/define('DB_NAME'.*$/define('DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
  /opt/bitnami/wordpress/wp-config.orig.php |
sed "s/define('DB_USER'.*$/define('DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
# TODO: db password should be read from disk mount
sed "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
sed "s/define('DB_HOST'.*$/define('DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
  > /opt/bitnami/wordpress/wp-config.php

echo "setup.sh: DONE"
