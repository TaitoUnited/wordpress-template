// Custom wordpress-template implementation for fetching database settings
// from environment variables.
// https://github.com/bitnami/bitnami-docker-wordpress/issues/128#issuecomment-389427845
// TODO: db password should be read from disk mount

$app.helpers.getDatabaseProperties = function() {
  return {
    database: process.env.WORDPRESS_DATABASE_NAME,
    username: process.env.WORDPRESS_DATABASE_USER,
    password: process.env.WORDPRESS_DATABASE_PASSWORD,
    hostPort: process.env.MARIADB_HOST + ':' + process.env.MARIADB_PORT_NUMBER,
    host: process.env.MARIADB_HOST, port: process.env.MARIADB_PORT_NUMBER
  };
};
