#!/bin/bash

# NOTE: does not work -> currently not in use
sudo su -s /bin/bash daemon
export PATH=/opt/bitnami/varnish/bin:/opt/bitnami/sqlite/bin:/opt/bitnami/php/bin:/opt/bitnami/mysql/bin:/opt/bitnami/apache2/bin:/opt/bitnami/common/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
cd /opt/bitnami/wordpress
wp plugin update --all --debug
