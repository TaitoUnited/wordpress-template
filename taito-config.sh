#!/bin/bash
# shellcheck disable=SC2034
: "${taito_env:?}"
: "${taito_target_env:?}"

# Configuration instructions:
# - https://github.com/TaitoUnited/taito-cli/blob/master/docs/manual/04-configuration.md
# - https://github.com/TaitoUnited/taito-cli/blob/master/docs/plugins.md

# Taito-cli
taito_version=1
taito_plugins="
  mysql-db
  docker
  docker-compose:local
  terraform:-local secrets:-local kube-secrets:-local
  kubectl:-local helm:-local
  gcloud:-local gcloud-builder:-local
  semantic npm git links-global
"

# Project labeling
taito_organization=${template_default_organization:?}
taito_organization_abbr=${template_default_organization_abbr:?}
taito_project=wordpress-template
# taito_project_short max 10 characters
taito_project_short=wptemplate
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
taito_provider_region=${template_default_provider_region:?}
taito_provider_zone=${template_default_provider_zone:?}
taito_zone=${template_default_zone:?}
taito_namespace=$taito_project-$taito_env
taito_resource_namespace=$taito_organization_abbr-$taito_company-dev

# Repositories
taito_vc_repository=$taito_project
taito_image_registry=${template_default_registry:?}/$taito_zone/$taito_vc_repository

# Stack
taito_targets="wordpress database"
taito_databases="database"
taito_storages="$taito_project-$taito_env"
taito_networks="default"

# Database definitions for database plugins
db_database_instance=${template_default_mysql:?}
db_database_type=mysql
db_database_name=${taito_project_short}${taito_env}
db_database_host=127.0.0.1
db_database_proxy_port=5001
db_database_port=$db_database_proxy_port

# Messaging
taito_messaging_app=slack
taito_messaging_webhook=
taito_messaging_channel=companyname
taito_messaging_builds_channel=builds
taito_messaging_critical_channel=critical
taito_messaging_monitoring_channel=monitoring

# Monitoring
taito_monitoring_names=" wordpress "
taito_monitoring_paths=" / "
taito_monitoring_timeouts=" 5s "
# You can list all monitoring channels with `taito env info:prod`
taito_monitoring_uptime_channels="${template_default_monitoring_uptime_channels_prod:-}"

# CI/CD settings
# NOTE: Most of these should be enabled for dev and feature envs only
ci_exec_build=false        # build a container if does not exist already
ci_exec_deploy=true        # deploy automatically
ci_exec_test=false         # execute test suites after deploy
ci_exec_test_wait=1        # how many seconds to wait for deployment/restart
ci_exec_test_init=false    # run 'init --clean' before each test suite
ci_exec_revert=false       # revert deploy automatically on fail

# ------ Plugin specific settings ------

# Hour reporting and issue management plugins
toggl_project_id=
toggl_tasks="" # For example "task:12345 another-task:67890"
jira_project_id=

# Template plugin
template_name=WORDPRESS-TEMPLATE
template_source_git=git@github.com:TaitoUnited

# Google Cloud plugin
gcloud_org_id=${template_default_provider_org_id:?}
gcloud_sql_proxy_port=$db_database_proxy_port

# Kubernetes plugin
kubectl_name=${template_default_kubernetes:?}
kubectl_replicas=1

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
    taito_provider_region=${template_default_provider_region_prod:?}
    taito_provider_zone=${template_default_provider_zone_prod:?}
    taito_resource_namespace=$taito_organization_abbr-$taito_company-prod
    gcloud_org_id=${template_default_provider_org_id_prod:?}

    # NOTE: Set production domain here once you have configured DNS
    taito_domain=
    taito_default_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_app_url=https://$taito_domain
    kubectl_replicas=1
    monitoring_enabled=true
    ;;
  stag)
    taito_zone=${template_default_zone_prod:?}
    taito_provider_region=${template_default_provider_region_prod:?}
    taito_provider_zone=${template_default_provider_zone_prod:?}
    taito_resource_namespace=$taito_organization_abbr-$taito_company-prod
    gcloud_org_id=${template_default_provider_org_id_prod:?}

    taito_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_default_domain=$taito_project-$taito_target_env.${template_default_domain_prod:?}
    taito_app_url=https://$taito_domain

    # NOTE: dev/test not deployed on Kubernetes, therefore containers are
    # built for staging.
    ci_exec_build=true        # allow build of a new container
    ci_exec_deploy=true       # deploy automatically
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

# Provider and namespaces
taito_resource_namespace_id=$taito_resource_namespace

# Google Cloud plugin
gcloud_region=$taito_provider_region
gcloud_zone=$taito_provider_zone
gcloud_project=$taito_zone
gcloud_storage_locations=EU
gcloud_storage_classes=MULTI_REGIONAL

# Kubernetes plugin
kubectl_cluster=gke_${taito_zone}_${gcloud_zone}_${kubectl_name}
kubectl_user=$kubectl_cluster

# Link plugin
link_urls="
  * app[:ENV]#app=$taito_app_url Application (:ENV)
  * admin[:ENV]#admin=$taito_admin_url Admin user interface (:ENV)
  * git=https://github.com/${template_default_github_organization:?}/$taito_vc_repository GitHub repository
  * docs=https://github.com/${template_default_github_organization:?}/$taito_vc_repository/wiki Project documentation
  * project=https://github.com/${template_default_github_organization:?}/$taito_vc_repository/projects Project management
  * services[:ENV]=https://console.cloud.google.com/apis/credentials?project=$taito_resource_namespace_id Google services (:ENV)
  * builds=https://console.cloud.google.com/cloud-build/builds?project=$taito_zone&query=source.repo_source.repo_name%3D%22github-${template_default_github_organization:?}-$taito_vc_repository%22 Build logs
  * storage:ENV=https://console.cloud.google.com/storage/browser/$taito_project-$taito_env?project=$taito_resource_namespace_id Storage bucket (:ENV)
  * logs:ENV=https://console.cloud.google.com/logs/viewer?project=$taito_zone&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F$kubectl_name%2Fnamespace_id%2F$taito_namespace Logs (:ENV)
  * uptime=https://app.google.stackdriver.com/uptime?project=$taito_zone Uptime monitoring (Stackdriver)
"

# Secrets
taito_secrets="
  github-buildbot.token:read/devops
  $db_database_name-db-mgr.password:random
  $db_database_name-db-app.password:random
  $taito_project-$taito_env-basic-auth.auth:htpasswd-plain
"
