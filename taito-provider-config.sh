#!/bin/bash
# shellcheck disable=SC2034

# NOTE: These settings have been copied from WORDPRESS-TEMPLATE.
# Do not modify them. Improve the original settings instead.

case $taito_provider in
  aws)
    taito_plugins="
      aws:-local
      ${taito_plugins}
      aws-storage:-local
    "

    link_urls="
      ${link_urls}
      * logs:ENV=https://${taito_provider_region}.console.aws.amazon.com/cloudwatch/home?region=${taito_provider_region}#logs: Logs (:ENV)
    "
    ;;
  gcp)
    taito_plugins="
      gcp:-local
      gcp-secrets:-local
      ${taito_plugins}
      gcp-storage:-local
      gcp-monitoring:-local
    "

    link_urls="
      ${link_urls}
      * services[:ENV]=https://console.cloud.google.com/apis/dashboard?project=$taito_resource_namespace_id Google services (:ENV)
      * logs:ENV=https://console.cloud.google.com/logs/viewer?project=$taito_zone&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2F$kubernetes_name%2Fnamespace_id%2F$taito_namespace Logs (:ENV)
    "

    taito_remote_secrets="
      $taito_remote_secrets
      cloudsql-gserviceaccount.key:copy/devops
      $taito_project-$taito_env-gserviceaccount.key:file
    "

    kubernetes_db_proxy_enabled=false # use google cloud sql proxy instead
    gcp_service_account_enabled=true
    ;;
  linux)
    # Enable ssh and run plugins
    taito_plugins="
      ssh:-local
      run:-local
      ${taito_plugins}
    "
    run_scripts_location="scripts/linux-provider"
    # Set some configuration parameters for scripts/linux-provider scripts
    LINUX_SUDO=sudo # NOTE: Put empty value if sudo is not required or allowed
    LINUX_CLIENT_MAX_BODY_SIZE=1m
    # Use Docker Compose instead of Kubernetes and Helm
    taito_plugins="${taito_plugins/docker-compose:local/docker-compose}"
    taito_plugins="${taito_plugins/kubectl:-local/}"
    taito_plugins="${taito_plugins/helm:-local/}"
    # Use SSH plugin as database proxy
    export ssh_db_proxy="\
      -L 0.0.0.0:\${database_port}:\${database_host}:\${database_real_port} \${taito_ssh_user}@\${database_real_host}"
    export ssh_forward_for_db="${ssh_db_proxy}"
    ;;
  custom)
    # Enable run plugin
    taito_plugins="
      run:-local
      ${taito_plugins}
    "
    run_scripts_location="scripts/custom-provider"
    # Do not use Docker, Kubernetes and Helm on remote environments
    taito_plugins="${taito_plugins/docker /docker:local }"
    taito_plugins="${taito_plugins/kubectl:-local/}"
    taito_plugins="${taito_plugins/helm:-local/}"
    ;;
esac

case $taito_uptime_provider in
  gcp)
    taito_plugins="${taito_plugins/gcp:-local/}"
    taito_plugins="
      gcp:-local
      ${taito_plugins}
    "
    link_urls="
      ${link_urls}
      * uptime=https://app.google.stackdriver.com/uptime?project=$taito_zone&f.search=$taito_project Uptime monitoring (Stackdriver)
    "
    ;;
esac

case $taito_ci_provider in
  bitbucket)
    taito_plugins="
      ${taito_plugins}
      bitbucket-ci:-local
    "
    link_urls="
      ${link_urls}
      * builds=https://$taito_vc_repository_url/addon/pipelines/home Build logs
      * artifacts=https://TODO-DOCS-AND-TEST-REPORTS Generated documentation and test reports
    "
    ;;
  gcp)
    taito_plugins="
      ${taito_plugins}
      gcp-ci:-local
    "
    link_urls="
      ${link_urls}
      * builds[:ENV]=https://console.cloud.google.com/cloud-build/builds?project=$taito_zone&query=source.repo_source.repo_name%3D%22github_${template_default_vc_organization:?}_$taito_vc_repository%22 Build logs
      * artifacts=https://TODO-DOCS-AND-TEST-REPORTS Generated documentation and test reports
    "
    # Google Cloud build does not support storing build secrets on user account
    # or organization level. Therefore we use Kubernetes devops namespace.
    if [[ $taito_plugins == *"semantic-release:$taito_env"* ]]; then
      taito_remote_secrets="
        $taito_remote_secrets
        github-buildbot.token:read/devops
      "
    fi
    ;;
  local)
    link_urls="
      ${link_urls}
      * builds=./local-ci.sh Local CI/CD
    "
    ;;
esac

case $taito_vc_provider in
  bitbucket)
    link_urls="
      ${link_urls}
      * docs=https://$taito_vc_repository_url/wiki/Home Project documentation
      * project=https://$taito_vc_repository_url/addon/trello/trello-board Project management
    "
    ;;
  github)
    link_urls="
      ${link_urls}
      * docs=https://$taito_vc_repository_url/wiki Project documentation
      * project=https://$taito_vc_repository_url/projects Project management
    "
    ;;
esac

case $taito_container_registry_provider in
  aws)
    # Enable AWS auth
    taito_plugins="${taito_plugins/aws:-local/}"
    taito_plugins="
      aws:-local
      ${taito_plugins}
    "
    ;;
  docker)
    # Enable Docker Hub auth
    taito_plugins="
      docker-registry:-local
      ${taito_plugins}
    "
    ;;
  gcp)
    # Enable gcp auth
    taito_plugins="${taito_plugins/gcp:-local/}"
    taito_plugins="
      gcp:-local
      ${taito_plugins}
    "
    ;;
  local)
    ;;
esac

if [[ $taito_plugins == *"sentry"* ]]; then
  sentry_organization=${template_default_sentry_organization:-}
  link_urls="
    ${link_urls}
    * errors:ENV=https://sentry.io/${template_default_sentry_organization:-}/$taito_project/?query=is%3Aunresolved+environment%3A$taito_target_env Sentry errors (:ENV)
  "
fi
