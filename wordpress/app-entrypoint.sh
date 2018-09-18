#!/bin/bash -e

# wordpress-template setup

./template-copy.sh
./template-env.sh

# original bitnami setup

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

print_welcome_page

if [[ "$1" == "nami" && "$2" == "start" ]] || [[ "$1" == "/init.sh" ]]; then
  . /init.sh
  nami_initialize apache php mysql-client wordpress
  info "Starting wordpress... "
fi

exec tini -- "$@"
