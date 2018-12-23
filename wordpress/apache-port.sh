#!/bin/bash -e

# Change apache port from 80 to 8080 so that processes can be run as non-root
# NOTE: Not in use -> running as non-root fails in file permissions

cp /bitnami/apache/conf/httpd.conf /bitnami/apache/conf/httpd-orig.conf
sed 's/Listen 80/Listen 8080/' /bitnami/apache/conf/httpd-orig.conf | \
  sed 's/localhost:80/localhost:8080/' > /bitnami/apache/conf/httpd.conf

cp /bitnami/apache/conf/bitnami/bitnami.conf /bitnami/apache/conf/bitnami/bitnami-orig.conf
sed 's/_default_:80/_default_:8080/' /bitnami/apache/conf/bitnami/bitnami-orig.conf \
  > /bitnami/apache/conf/bitnami/bitnami.conf
