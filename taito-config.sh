#!/bin/bash
# shellcheck disable=SC2034
: "${taito_target_env:?}"

# Configuration instructions:
# - https://github.com/TaitoUnited/taito-cli/blob/master/docs/manual/05-configuration.md
# - https://github.com/TaitoUnited/taito-cli/blob/master/docs/plugins.md

# Taito-cli
taito_version=1
taito_plugins="
  terraform:-local
  default-secrets generate-secrets
  docker docker-compose:local kubectl:-local helm:-local
  mysql-db
  gcloud-ci:-local
  npm git-global links-global
  semantic-release
"

# Project labeling
taito_organization=${template_default_organization:?}
taito_organization_abbr=${template_default_organization_abbr:?}
taito_project=wordpress-template
# taito_project_short max 10 characters
taito_project_short=wptemplate
taito_random_name=wordpress-template
taito_company=companyname
taito_family=
taito_application=template
taito_suffix=

# Assets
taito_project_icon=$taito_project-dev.${template_default_domain:?}/favicon.ico

# Environments
taito_environments="dev stag prod"
taito_env=${taito_env/canary/prod} # canary -> prod

# URLs
taito_domain=$taito_project-$taito_target_env.${template_default_domain:?}
taito_default_domain=$taito_project-$taito_target_env.${template_default_domain:?}
taito_app_url=https://$taito_domain
taito_static_url=

# Provider and namespaces
taito_provider=${template_default_provider:?}
taito_provider_org_id=${template_default_provider_org_id:?}
taito_provider_region=${template_default_provider_region:?}
taito_provider_zone=${template_default_provider_zone:?}
taito_zone=${template_default_zone:?}
taito_namespace=$taito_project-$taito_env
taito_resource_namespace=$taito_organization_abbr-$taito_company-dev

# Repositories
taito_vc_repository=$taito_project
taito_image_registry=${template_default_container_registry:?}/$taito_vc_repository

# Stack
taito_targets="wordpress database"
taito_databases="database"
taito_storages="$taito_random_name-$taito_env"
taito_networks="default"

# Database definitions for database plugins
db_database_instance=${template_default_mysql:?}
db_database_type=mysql
db_database_name=${taito_project_short}${taito_env}
db_database_host=127.0.0.1
db_database_port=5001
db_database_real_host="${template_default_mysql_host:?}"
db_database_real_port=3306
db_database_master_username="${template_default_mysql_master_username:?}"
db_database_master_password_hint="${template_default_mysql_master_password_hint:?}"

# Storage definitions for Terraform
taito_storage_classes="${template_default_storage_class:-}"
taito_storage_locations="${template_default_storage_location:-}"
taito_storage_days=${template_default_storage_days:-}

# Storage backup definitions for Terraform
taito_backup_locations="${template_default_backup_location:-}"
taito_backup_days="${template_default_backup_days:-}"

# Messaging
taito_messaging_app=slack
taito_messaging_webhook=
taito_messaging_channel=companyname
taito_messaging_builds_channel=builds
taito_messaging_critical_channel=critical
taito_messaging_monitoring_channel=monitoring

# Misc
taito_default_password=secret1234

# CI/CD settings
# NOTE: Most of these should be enabled for dev and feature envs only
ci_exec_build=false        # build a container if does not exist already
ci_exec_deploy=${template_default_ci_exec_deploy:-true}        # deploy automatically
ci_exec_test=false         # execute test suites after deploy
ci_exec_test_wait=1        # how many seconds to wait for deployment/restart
ci_exec_test_init=false    # run 'init --clean' before each test suite
ci_exec_revert=false       # revert deploy automatically on fail

# ------ Plugin and provider specific settings ------

# Hour reporting and issue management plugins
toggl_project_id=
toggl_tasks="" # For example "task:12345 another-task:67890"
jira_project_id=

# Template plugin
template_name=WORDPRESS-TEMPLATE
template_source_git=git@github.com:TaitoUnited

# Kubernetes plugin
kubernetes_name=${template_default_kubernetes:?}
kubernetes_cluster="${template_default_kubernetes_cluster_prefix:?}${kubernetes_name}"
kubernetes_replicas=1
kubernetes_db_proxy_enabled=true

# Helm plugin
# helm_deploy_options="--recreate-pods" # Force restart

# Wordpress settings
# WARNING: Setting this from true to false deletes the existing persistent disk
wordpress_persistence_enabled=false
wordpress_plugin_update_flags="--all --debug --minor"

# --- Override settings for different environments ---

case $taito_env in
  prod)
    taito_zone=${template_default_zone_prod:?}
    taito_provider_org_id=${template_default_provider_org_id_prod:?}
    taito_provider_region=${template_default_provider_region_prod:?}
    taito_provider_zone=${template_default_provider_zone_prod:?}
    taito_resource_namespace=$taito_organization_abbr-$taito_company-prod

    # NOTE: Set production domain here once you have configured DNS
    taito_domain=
    taito_default_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_app_url=https://$taito_domain
    kubernetes_cluster="${template_default_kubernetes_cluster_prefix_prod:?}${kubernetes_name}"
    kubernetes_replicas=1
    db_database_real_host="${template_default_mysql_host_prod:?}"

    # Storage definitions for Terraform
    taito_storage_classes="${template_default_storage_class_prod:-}"
    taito_storage_locations="${template_default_storage_location_prod:-}"
    taito_storage_days=${template_default_storage_days_prod:-}

    # Storage backup definitions for Terraform
    taito_backup_locations="${template_default_backup_location_prod:-}"
    taito_backup_days="${template_default_backup_days_prod:-}"

    # Monitoring
    taito_monitoring_targets=" wordpress "
    taito_monitoring_paths=" / "
    taito_monitoring_timeouts=" 5s "
    # You can list all monitoring channels with `taito env info:prod`
    taito_monitoring_uptime_channels="${template_default_monitoring_uptime_channels_prod:-}"

    # CI/CD
    ci_exec_deploy=${template_default_ci_exec_deploy_prod:-true}
    ;;
  stag)
    taito_zone=${template_default_zone_prod:?}
    taito_provider_org_id=${template_default_provider_org_id_prod:?}
    taito_provider_region=${template_default_provider_region_prod:?}
    taito_provider_zone=${template_default_provider_zone_prod:?}
    taito_resource_namespace=$taito_organization_abbr-$taito_company-prod

    taito_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_default_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_app_url=https://$taito_domain
    kubernetes_cluster="${template_default_kubernetes_cluster_prefix_prod:?}${kubernetes_name}"
    db_database_real_host="${template_default_mysql_host_prod:?}"

    # CI/CD
    ci_exec_deploy=${template_default_ci_exec_deploy_prod:-true}
    # NOTE: dev/test not deployed on Kubernetes, therefore containers are
    # built for staging.
    ci_exec_build=true        # allow build of a new container
    ;;
  local)
    # local overrides
    ci_exec_test_init=false   # run 'init --clean' before each test suite
    taito_app_url=http://localhost:4635
    db_database_external_port=7587
    db_database_host=$taito_project-database
    db_database_port=3306
    db_database_password=secret
    db_database_username=${taito_project_short}${taito_env}
esac

# --- Derived values ---

# URLs
taito_admin_url=$taito_app_url/wp-admin/
taito_storage_url="https://console.cloud.google.com/storage/browser/$taito_random_name-$taito_env?project=$taito_resource_namespace_id"

# Provider and namespaces
taito_resource_namespace_id=$taito_resource_namespace

# Link plugin
link_urls="
  * wp[:ENV]#app=$taito_app_url Wordpress (:ENV)
  * admin[:ENV]#admin=$taito_admin_url Admin user interface (:ENV)
  * git=https://${template_default_git_url:?}/$taito_vc_repository GitHub repository
  * docs=https://${template_default_git_url:?}/$taito_vc_repository/wiki Project documentation
  * project=https://${template_default_git_url:?}/$taito_vc_repository/projects Project management
  * builds=https://console.cloud.google.com/cloud-build/builds?project=$taito_zone&query=source.repo_source.repo_name%3D%22github-${template_default_git_organization:?}-$taito_vc_repository%22 Build logs
  * storage:ENV=$taito_storage_url Storage bucket (:ENV)
"

# ------ Secrets ------

taito_secrets="
  github-buildbot.token:read/devops
  $db_database_name-db-app.password:random
  $taito_project-$taito_env-basic-auth.auth:htpasswd-plain
  $taito_project-$taito_env-admin.initialpassword:random
"

# Define database mgr password for automatic CI/CD deployments
if [[ $ci_exec_deploy == "true" ]]; then
  taito_remote_secrets="
    $db_database_name-db-mgr.password/devops:random
  "
fi

# ------ Provider specific settings ------

case $taito_provider in
  aws)
    taito_plugins="
      aws:-local
      ${taito_plugins}
      aws-storage:-local
    "

    link_urls="
      ${link_urls}
      * logs:ENV=https://${template_default_provider_region}.console.aws.amazon.com/cloudwatch/home?region=${template_default_provider_region}#logs: Logs (:ENV)
    "
    ;;
  gcloud)
    taito_plugins="
      gcloud:-local
      gcloud-secrets:-local
      ${taito_plugins}
      gcloud-storage:-local
      gcloud-monitoring:-local
    "

    link_urls="
      ${link_urls}
      * services[:ENV]=https://console.cloud.google.com/apis/dashboard?project=$taito_resource_namespace_id Google services (:ENV)
      * logs:ENV=https://console.cloud.google.com/logs/viewer?project=$taito_zone&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F$kubernetes_name%2Fnamespace_id%2F$taito_namespace Logs (:ENV)
      * uptime=https://app.google.stackdriver.com/uptime?project=$taito_zone&f.search=$taito_project Uptime monitoring (Stackdriver)
    "

    kubernetes_db_proxy_enabled=false # use google cloud sql proxy instead
    gcloud_service_account_enabled=true
    ;;
esac
