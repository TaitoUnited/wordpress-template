#!/usr/bin/env bash
# shellcheck disable=SC2034
# shellcheck disable=SC2154

##########################################################################
# Project specific settings
##########################################################################

# Taito CLI: Project specific plugins (for the selected database, etc.)
taito_plugins="
  ${taito_plugins}
  mysql-db
"

# Environments: In the correct order (e.g. dev test uat stag canary prod)
taito_environments="dev stag prod"

# Basic auth: Uncomment the line below to disable basic auth from ALL
# environments. Use scripts/taito/env-prod.sh to disable basic auth from prod
# environment only.
# taito_basic_auth_enabled=false

# Service account: Uncomment the line below to always create Cloud provider
# service account
# provider_service_account_enabled=true

# ------ Wordpress ------

# WARNING: Setting this from true to false deletes the existing persistent disk
wordpress_persistence_enabled=false
wordpress_plugin_update_flags="--all --debug --minor"

# ------ Stack ------

# Stack
taito_targets="wordpress database"
taito_networks="default"

# Stack types ('container' by default)
taito_target_type_database=database

# Stack uptime monitoring
taito_uptime_targets="wordpress"
taito_uptime_paths="/"
taito_uptime_timeouts="5"

# ------ Links ------
# Add custom links here. You can regenerate README.md links with
# 'taito project docs'.

link_urls="
  * wordpress[:ENV]#app=$taito_app_url Wordpress (:ENV)
  * admin[:ENV]#admin=$taito_admin_url Admin user interface (:ENV)
  * git=https://$taito_vc_repository_url Git repository
"

# ------ Secrets ------
# Configuration instructions:
# https://taitounited.github.io/taito-cli/tutorial/06-env-variables-and-secrets/

taito_remote_secrets="
  $db_database_mgr_secret:random
  $taito_project-$taito_env-basic-auth.auth:htpasswd-plain
  database-proxy-serviceaccount.key:copy/db-proxy
"
taito_local_secrets="
"
taito_secrets="
  $db_database_app_secret:random
  $taito_project-$taito_env-admin.initialpassword:random
"
