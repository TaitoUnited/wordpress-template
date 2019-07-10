#!/bin/bash
# shellcheck disable=SC2034

##########################################################################
# Settings for all environments
##########################################################################

# Environments: In the correct order (e.g. dev test stag canary prod)
taito_environments="${template_default_environments:?}"

# Basic auth: Uncomment the line below to disable basic auth from ALL
# environments. Use taito-env-prod-config.sh to disable basic auth from prod
# environment only.
# taito_basic_auth_enabled=false

# Service account: Uncomment the line below to always create GCP service account
# gcp_service_account_enabled=true

# ------ Wordpress ------

# WARNING: Setting this from true to false deletes the existing persistent disk
wordpress_persistence_enabled=false
wordpress_plugin_update_flags="--all --debug --minor"

# ------ Stack ------

# Stack
taito_targets="wordpress database"
taito_storages="$taito_random_name-$taito_env"
taito_networks="default"

# Stack types ('container' by default)
taito_target_type_database=database

# Stack uptime monitoring
taito_uptime_targets="wordpress"
taito_uptime_paths="/"
taito_uptime_timeouts="5s"

# ------ Links ------
# Add custom links here. You can regenerate README.md links with
# 'taito project docs'.

link_urls="
  * wp[:ENV]#app=$taito_app_url Wordpress (:ENV)
  * admin[:ENV]#admin=$taito_admin_url Admin user interface (:ENV)
  * git=https://${template_default_vc_url:?}/$taito_vc_repository GitHub repository
"

# ------ Secrets ------
# Configuration instructions:
# https://taitounited.github.io/taito-cli/tutorial/06-env-variables-and-secrets/

taito_secrets="
  $db_database_name-db-mgr.password/devops:random
  $taito_project-$taito_env-basic-auth.auth:htpasswd-plain
  $taito_project-$taito_env-admin.initialpassword:random
"
