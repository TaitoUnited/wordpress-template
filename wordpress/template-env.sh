#!/bin/bash -e

echo "template-env.sh: Adding support for database environment variables"

if [ ! -f /root/.nami/components/com.bitnami.wordpress/helpers.orig.js ]; then
  echo "template-env.sh: Modifying getDatabaseProperties() function of helpers.js"
  cp /root/.nami/components/com.bitnami.wordpress/helpers.js \
    /root/.nami/components/com.bitnami.wordpress/helpers.orig.js
  sed '/$app.helpers.getDatabaseProperties/q' \
    /root/.nami/components/com.bitnami.wordpress/helpers.orig.js \
    > /root/.nami/components/com.bitnami.wordpress/helpers.js
  echo "return { database: process.env.WORDPRESS_DATABASE_NAME, username: process.env.WORDPRESS_DATABASE_USER, password: process.env.WORDPRESS_DATABASE_PASSWORD, hostPort: process.env.MARIADB_HOST + ':' + process.env.MARIADB_PORT_NUMBER, host: process.env.MARIADB_HOST, port: process.env.MARIADB_PORT_NUMBER }; };" \
    >> /root/.nami/components/com.bitnami.wordpress/helpers.js
fi

if [ -f /bitnami/wordpress/wp-config.php ]; then
  echo "template-env.sh: Updating wp-config.php with environment variable references"
  cp /bitnami/wordpress/wp-config.php /bitnami/wordpress/wp-config.orig.php
  sed "s/define('DB_NAME'.*$/define('DB_NAME', getenv('WORDPRESS_DATABASE_NAME'));/" \
    /bitnami/wordpress/wp-config.orig.php |
  sed "s/define('DB_USER'.*$/define('DB_USER', getenv('WORDPRESS_DATABASE_USER'));/" |
  sed "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', getenv('WORDPRESS_DATABASE_PASSWORD'));/" |
  sed "s/define('DB_HOST'.*$/define('DB_HOST', getenv('MARIADB_HOST') . ':' . getenv('MARIADB_PORT_NUMBER'));/" \
    > /bitnami/wordpress/wp-config.php
fi

echo "template-env.sh: DONE"
