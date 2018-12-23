#!/bin/bash -e

# Custom wordpress-template implementation for fetching database settings
# from environment variables.
# https://github.com/bitnami/bitnami-docker-wordpress/issues/128#issuecomment-389427845
# TODO: db password should be read from disk mount

echo "template-env.sh: Adding support for database environment variables"

if [ ! -f /root/.nami/components/com.bitnami.wordpress/helpers.orig.js ]; then
  echo "template-env.sh: Modifying getDatabaseProperties() function of helpers.js"
  cp /root/.nami/components/com.bitnami.wordpress/helpers.js \
    /root/.nami/components/com.bitnami.wordpress/helpers.orig.js
  sed 's/app.helpers.getDatabaseProperties/app.helpers.getDatabasePropertiesOrig/' \
    /root/.nami/components/com.bitnami.wordpress/helpers.orig.js \
    > /root/.nami/components/com.bitnami.wordpress/helpers2.js
  cat /template/helpers.js \
    >> /root/.nami/components/com.bitnami.wordpress/helpers2.js
fi

if [ -f /bitnami/wordpress/wp-config.php ]; then
  echo "template-env.sh: Updating wp-config.php with environment variable references"
  cp /bitnami/wordpress/wp-config.php /bitnami/wordpress/wp-config.orig.php
  sed "s/define('DB_NAME'.*$/define('DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
    /bitnami/wordpress/wp-config.orig.php |
  sed "s/define('DB_USER'.*$/define('DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
  # TODO: db password should be read from disk mount
  sed "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
  sed "s/define('DB_HOST'.*$/define('DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
    > /bitnami/wordpress/wp-config.php
fi

echo "template-env.sh: DONE"
