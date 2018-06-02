#!/bin/bash

# Taito-cli settings
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

# Basic project settings for all plugins
export taito_organization="${template_default_organization:?}"
export taito_zone="${template_default_zone:?}"
export taito_provider="${template_default_provider:?}"
export taito_repo_location="github-${taito_organization}"
export taito_repo_name="wordpress-template"
export taito_project="wordpress-template"
export taito_company="companyname"
export taito_family=""
export taito_application="template"
export taito_suffix=""
export taito_namespace="${taito_project}-${taito_env:?}"
export taito_resource_namespace="${taito_company}-dev"
export taito_registry="${template_default_registry:?}/${taito_zone}/${taito_repo_location}-${taito_repo_name}"
export taito_app_url="https://${taito_namespace}.${template_default_domain:?}"
export taito_admin_url="${taito_app_url}/admin/"

# Structure definitions for all plugins
export taito_environments="dev prod"
export taito_targets="wordpress database"
export taito_databases="database"
export taito_storages="${taito_project}-${taito_env}"

# Database definitions for database plugins
export db_database_instance="common-mysql"
export db_database_type="mysql"
export db_database_name="${taito_project//-/_}_${taito_env}"
export db_database_host="localhost"
export db_database_proxy_port="5001"
export db_database_port="${db_database_proxy_port}"

# docker plugin
export dockerfile=Dockerfile

# gcloud plugin
export gcloud_org_id="${template_default_provider_org_id:?}"
export gcloud_region="${template_default_provider_region:?}"
export gcloud_zone="${template_default_provider_zone:?}"
export gcloud_billing_account="${template_default_provider_billing_account:-}"
export gcloud_sql_proxy_port="${db_database_proxy_port}"
export gcloud_cdn_enabled=false

# Kubernetes plugin
export kubectl_name="kube1" # TODO rename to common-kubernetes

# Helm plugin
# export helm_charts="stable/wordpress stable/gcloud-sqlproxy"
# export helm_deploy_options="--recreate-pods" # Force restart

# Template plugin
export template_name="orig-template"
export template_source_git="git@github.com:TaitoUnited"

# Settings for builds
# NOTE: Most of these should be enabled for dev and feature envs only
export ci_exec_build=false        # build a container if does not exist already
export ci_exec_deploy=true        # deploy automatically
export ci_exec_test=false         # execute test suites after deploy
export ci_exec_test_wait=1        # how many seconds to wait for deployment/restart
export ci_exec_test_init=false    # run 'init --clean' before each test suite
export ci_exec_revert=false       # revert deploy automatically on fail

# Override settings for different environments:
# local, feature, dev, test, staging, prod
case "${taito_env}" in
  prod)
    # prod overrides
    export taito_zone="${template_default_zone_prod:?}"
    export gcloud_org_id="${template_default_provider_org_id_prod:?}"
    export gcloud_region="${template_default_provider_region_prod:?}"
    export gcloud_zone="${template_default_provider_zone_prod:?}"
    export taito_resource_namespace="${taito_company}-prod"
    ;;
  staging)
    # staging overrides
    export taito_zone="${template_default_zone_prod:?}"
    export gcloud_org_id="${template_default_provider_org_id_prod:?}"
    export gcloud_region="${template_default_provider_region_prod:?}"
    export gcloud_zone="${template_default_provider_zone_prod:?}"
    export taito_resource_namespace="${taito_company}-prod"
    ;;
  test)
    # test overrides
    ;;
  dev|feature)
    # dev and feature overrides
    export ci_exec_build=true        # allow build of a new container
    export ci_exec_deploy=true       # deploy automatically
    # NOTE: enable tests once you have implemented some integration or e2e tests
    export ci_exec_test=true         # execute test suites
    export ci_exec_test_init=false   # run 'init --clean' before each test suite
    export ci_exec_revert=false      # revert deploy if previous steps failed
    ;;
  local)
    # local overrides
    export ci_exec_test_init=false   # run 'init --clean' before each test suite
    export taito_app_url="http://localhost:4635"
    export taito_admin_url="${taito_app_url}/admin/"
    export db_database_external_port="7587"
    export db_database_host="${taito_project}-database"
    export db_database_port="3306"
    export db_database_password="secret"
esac

# --- Derived values ---

# gcloud plugin
export gcloud_project="${taito_zone}"
export gcloud_resource_project="${taito_resource_namespace}"
export gcloud_resource_project_id="${taito_organization}-${taito_resource_namespace}"
export gcloud_storage_regions="${gcloud_region}"
export gcloud_storage_classes="REGIONAL"

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
  * project[:ENV]=https://console.cloud.google.com/home/dashboard?project=${gcloud_resource_project_id} Google project (:ENV) \
  * builds=https://console.cloud.google.com/gcr/builds?project=${taito_zone}&query=source.repo_source.repo_name%3D%22${taito_repo_location}-${taito_repo_name}%22 Build logs \
  * storage:ENV#storage=https://console.cloud.google.com/storage/browser/${taito_project}-${taito_env}?project=${gcloud_resource_project_id} Storage bucket (:ENV) \
  * logs:ENV#logs=https://console.cloud.google.com/logs/viewer?project=${taito_zone}&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F${kubectl_name}%2Fnamespace_id%2F${taito_namespace} Logs (:ENV) \
  * uptime=https://app.google.stackdriver.com/uptime?project=${taito_zone} Uptime monitoring (Stackdriver) \
"

# Secrets
# NOTE: Secret naming: type.target_of_type.purpose[/namespace]:generation_method
export taito_secrets="
  git.github.build:read/devops
  gcloud.cloudsql.proxy:copy/devops
  db.${db_database_name}.build/devops:random
  db.${db_database_name}.app:random
  storage.${taito_project}.gateway:random
  gcloud.${taito_project}-${taito_env}.multi:file
"
