#!/bin/bash

# Taito-cli
export taito_version="1"
export taito_image="taitounited/taito-cli:latest"
export taito_extensions=""
export taito_plugins=" \
  mysql-db \
  docker \
  docker-compose:local \
  terraform:-local secrets:-local kube-secrets:-local \
  kubectl:-local helm:-local \
  gcloud:-local gcloud-builder:-local \
  semantic npm git links-global \
"

# Project
export taito_organization="${template_default_organization:?}"
export taito_project="wordpress-template"
export taito_project_short="wptemplate" # Max 10 characters
export taito_company="companyname"
export taito_family=""
export taito_application="template"
export taito_suffix=""

# Provider and namespaces
export taito_zone="${template_default_zone:?}"
export taito_provider="${template_default_provider:?}"
export taito_provider_region="${template_default_provider_region:?}"
export taito_provider_zone="${template_default_provider_zone:?}"
export taito_namespace="${taito_project}-${taito_env:?}"
export taito_resource_namespace="${taito_company}-prod"
export taito_environments="stag prod"

# Repositories
# TODO change taito_repo and taito_registry naming, add also repo url?
export taito_repo_location="github-${taito_organization}"
export taito_repo_name="${taito_project}"
export taito_registry="${template_default_registry:?}/${taito_zone}/${taito_repo_location}-${taito_repo_name}"

# Stack
export taito_targets="wordpress database"
export taito_databases="database"
export taito_storages="${taito_project}-${taito_env}"
export taito_networks="default"

# Database definitions for database plugins
export db_database_instance="${template_default_mysql:?}"
export db_database_type="mysql"
export db_database_name="${taito_project_short}${taito_env}"
export db_database_host="127.0.0.1"
export db_database_proxy_port="5001"
export db_database_port="${db_database_proxy_port}"

# URLs
export taito_domain="${taito_project}-${taito_env:?}.${template_default_domain:?}"
export taito_app_url="https://${taito_domain}"

# Wordpress configs
# WARNING: Setting this from true to false deletes the existing persistent disk
export wordpress_persistence_enabled="false"

# Docker plugin
export dockerfile=Dockerfile

# Google Cloud plugin
export gcloud_org_id="${template_default_provider_org_id:?}"
export gcloud_sql_proxy_port="${db_database_proxy_port}"
export gcloud_cdn_enabled=false

# Kubernetes plugin
export kubectl_name="${template_default_kubernetes:?}"
export kubectl_replicas="1"

# Helm plugin
# export helm_deploy_options="--recreate-pods" # Force restart

# Template plugin
export template_name="WORDPRESS-TEMPLATE"
export template_source_git="git@github.com:TaitoUnited"

# CI/CD settings
# NOTE: Most of these should be enabled for dev and feature envs only
export ci_exec_build=false        # build a container if does not exist already
export ci_exec_deploy=true        # deploy automatically
export ci_exec_test=false         # execute test suites after deploy
export ci_exec_test_wait=1        # how many seconds to wait for deployment/restart
export ci_exec_test_init=false    # run 'init --clean' before each test suite
export ci_exec_revert=false       # revert deploy automatically on fail

# --- Override settings for different environments ---

case "${taito_env}" in
  prod)
    export taito_app_url="https://${taito_namespace}.${template_default_domain:?}"
    export taito_zone="${template_default_zone_prod:?}"
    export taito_provider_region="${template_default_provider_region_prod:?}"
    export taito_provider_zone="${template_default_provider_zone_prod:?}"
    export taito_resource_namespace="${taito_company}-prod"
    export gcloud_org_id="${template_default_provider_org_id_prod:?}"

    # NOTE: Set production domain here
    export taito_domain="${taito_project}-${taito_env:?}.${template_default_domain_prod:?}"
    export taito_app_url="https://${taito_domain}"
    export kubectl_replicas="1"
    ;;
  stag)
    export taito_app_url="https://${taito_namespace}.${template_default_domain:?}"
    export taito_zone="${template_default_zone_prod:?}"
    export taito_provider_region="${template_default_provider_region_prod:?}"
    export taito_provider_zone="${template_default_provider_zone_prod:?}"
    export taito_resource_namespace="${taito_company}-prod"
    export gcloud_org_id="${template_default_provider_org_id_prod:?}"

    export taito_domain="${taito_project}-${taito_env:?}.${template_default_domain_prod:?}"
    export taito_app_url="https://${taito_domain}"

    export ci_exec_build=true        # allow build of a new container
    export ci_exec_deploy=true       # deploy automatically
    ;;
  test)
    # test overrides
    ;;
  dev|feat)
    # dev and feature overrides
    export ci_exec_build=true        # allow build of a new container
    export ci_exec_deploy=true       # deploy automatically
    ;;
  local)
    # local overrides
    export ci_exec_test_init=false   # run 'init --clean' before each test suite
    export taito_app_url="http://localhost:4635"
    export db_database_external_port="7587"
    export db_database_host="${taito_project}-database"
    export db_database_port="3306"
    export db_database_password="secret"
    export db_database_username="${taito_project_short}${taito_env}"
esac

# --- Derived values ---

# Namespaces
export taito_resource_namespace_id="${taito_organization}-${taito_resource_namespace}"

# URLs
export taito_admin_url="${taito_app_url}/admin/"

# Google Cloud plugin
export gcloud_region="${taito_provider_region}"
export gcloud_zone="${taito_provider_zone}"
export gcloud_project="${taito_zone}"
export gcloud_storage_locations="EU"
export gcloud_storage_classes="MULTI_REGIONAL"

# Kubernetes plugin
export kubectl_cluster="gke_${taito_zone}_${gcloud_zone}_${kubectl_name}"
export kubectl_user="${kubectl_cluster}"

# Link plugin
export link_urls="\
  * app[:ENV]#app=${taito_app_url} Application (:ENV) \
  * admin[:ENV]#admin=${taito_admin_url} Admin user interface (:ENV) \
  * docs=https://github.com/${taito_organization}/${taito_repo_name}/wiki Project documentation \
  * git=https://github.com/${taito_organization}/${taito_repo_name} GitHub repository \
  * kanban=https://github.com/${taito_organization}/${taito_repo_name}/projects Kanban boards \
  * project[:ENV]=https://console.cloud.google.com/home/dashboard?project=${taito_resource_namespace_id} Google project (:ENV) \
  * resources[:ENV]=https://console.cloud.google.com/home/dashboard?project=${taito_resource_namespace_id} Google resources (:ENV) \
  * services[:ENV]=https://console.cloud.google.com/apis/credentials?project=${taito_resource_namespace_id} Google services (:ENV) \
  * builds=https://console.cloud.google.com/gcr/builds?project=${taito_zone}&query=source.repo_source.repo_name%3D%22${taito_repo_location}-${taito_repo_name}%22 Build logs \
  * storage:ENV#storage=https://console.cloud.google.com/storage/browser/${taito_project}-${taito_env}?project=${taito_resource_namespace_id} Storage bucket (:ENV) \
  * logs:ENV#logs=https://console.cloud.google.com/logs/viewer?project=${taito_zone}&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F${kubectl_name}%2Fnamespace_id%2F${taito_namespace} Logs (:ENV) \
  * uptime=https://app.google.stackdriver.com/uptime?project=${taito_zone} Uptime monitoring (Stackdriver) \
"

# Secrets
# TODO change secret naming convention
export taito_secrets="
  github-buildbot.token:read/devops
  ${db_database_name}-db-mgr.password:random
  ${db_database_name}-db-app.password:random
  ${taito_project}-${taito_env}-basic-auth.auth:htpasswd-plain
"
