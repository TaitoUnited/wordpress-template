#!/bin/bash
# shellcheck disable=SC2034

##########################################################################
# Environment settings
##########################################################################

taito_environments="dev stag prod"

# NOTE: Uncomment this line to disable basic auth from ALL environments.
# Use taito-domain-config.sh to disable basic auth from PROD env only.
# taito_basic_auth_enabled=false

# ------ Links ------

link_urls="
  * wp[:ENV]#app=$taito_app_url Wordpress (:ENV)
  * admin[:ENV]#admin=$taito_admin_url Admin user interface (:ENV)
  * git=https://${template_default_vc_url:?}/$taito_vc_repository GitHub repository
  * storage:ENV=$taito_storage_url Storage bucket (:ENV)
"

# ------ Secrets ------
# Configuration instructions:
# https://taitounited.github.io/taito-cli/tutorial/06-env-variables-and-secrets/

taito_secrets="
  $db_database_name-db-mgr.password/devops:random
  $taito_project-$taito_env-basic-auth.auth:htpasswd-plain
  $taito_project-$taito_env-admin.initialpassword:random
"
