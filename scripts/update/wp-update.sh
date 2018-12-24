#!/bin/bash -e

if [[ "${taito_env}" == "local" ]] || [[ "${wordpress_persistence_enabled}" == "true" ]]; then
  echo "TODO automatically create db backup and snapshot first"
  echo "wordpress_plugin_update_flags: ${wordpress_plugin_update_flags}"
  taito "exec:wordpress:${taito_env}" \
    su -c "/opt/bitnami/wp-cli/bin/wp plugin update ${wordpress_plugin_update_flags}" bitnami
else
  echo "Persistence not enabled. WP plugin update not needed."
fi
