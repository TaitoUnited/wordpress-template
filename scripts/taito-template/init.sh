#!/bin/bash -e
# TODO: most of this has been pretty much copy pasted from server-template
: "${taito_organization:?}"
: "${taito_company:?}"
: "${taito_vc_repository:?}"
: "${taito_vc_repository_alt:?}"

: "${template_default_taito_image:?}"
: "${template_default_organization:?}"
: "${template_default_organization_abbr:?}"
: "${template_default_git_organization:?}"
: "${template_default_git_url:?}"
: "${template_default_sentry_organization:?}"
: "${template_default_domain:?}"
: "${template_default_domain_prod:?}"
: "${template_default_zone:?}"
: "${template_default_zone_prod:?}"
: "${template_default_provider:?}"
: "${template_default_provider_org_id:?}"
: "${template_default_provider_org_id_prod:?}"
: "${template_default_provider_region:?}"
: "${template_default_provider_region_prod:?}"
: "${template_default_provider_zone:?}"
: "${template_default_provider_zone_prod:?}"
: "${template_default_monitoring_uptime_channels_prod:-}"
: "${template_default_container_registry:?}"
: "${template_default_source_git:?}"
: "${template_default_dest_git:?}"
: "${template_default_kubernetes:?}"
: "${template_default_mysql:?}"
: "${template_default_storage_class:?}"

: "${template_project_path:?}"
: "${mode:?}"

${taito_setv:?}

# Remove .gitignore to allow committing data to git
rm wordpress/data/.gitignore
mv wordpress/data/.gitkeep wordpress/data/.gitignore

# Remove MIT license
# TODO leave a reference to the original?
rm LICENSE

######################
# Choose CI/CD
######################

ci=${template_default_ci_provider:-}
while [[ " aws azure bitbucket github gitlab gcloud jenkins shell travis " != *" $ci "* ]]; do
  echo "Select CI/CD: aws, azure, bitbucket, github, gitlab, gcloud, jenkins, shell, or travis"
  read -r ci
done

if [[ ${template_default_ci_deploy_with_spinnaker:-} ]]; then
  ci_deploy_with_spinnaker=$template_default_ci_deploy_with_spinnaker
else
  echo "Use Spinnaker for deployment (y/N)?"
  read -r confirm
  if [[ ${confirm} =~ ^[Yy]$ ]]; then
    ci_deploy_with_spinnaker=true
  fi
fi

#######################
# Replace some strings
#######################

if [[ ! ${taito_random_name} ]] || [[ ${taito_random_name} == "wordpress-template" ]]; then
  taito_random_name="$(taito -q util-random-words: 3)"
fi
echo "Setting random name: ${taito_random_name}"
sed -i "s/^taito_random_name=.*$/taito_random_name=${taito_random_name}/" taito-config.sh

# Replace repository url in package.json
sed -i \
  "s|TaitoUnited/wordpress-template.git|${taito_organization}/${taito_vc_repository}.git|g" package.json

# Replace default admin password
admin_password=$(openssl rand -base64 40 | sed -e 's/[^a-zA-Z0-9]//g')
if [[ ${#admin_password} -gt 30 ]]; then
  admin_password="${admin_password: -30}"
fi
sed -i \
  "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" scripts/helm/values.yaml
sed -i \
  "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" docker-compose.yaml
sed -i \
  "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" README.md

# Add some do not modify notes
echo "Adding do not modify notes..."

# Remove template note from README.md
{
sed '/TEMPLATE NOTE START/q' README.md
sed -n -e '/TEMPLATE NOTE END/,$p' README.md
} > temp
truncate --size 0 README.md
cat temp > README.md

# Add 'do not modify' note to readme of helm chart
echo \
"> NOTE: This helm chart has been copied from \
[WORDPRESS-TEMPLATE](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/). It is \
located here only to avoid accidental build breaks. Do not modify it. \
Improve the original instead." | \
  cat - scripts/helm/README.md > temp && \
  truncate --size 0 scripts/helm/README.md && \
  cat temp > scripts/helm/README.md

# Add 'do not modify' note to cloudbuild.yaml
printf \
"# NOTE: This file has been generated from WORDPRESS-TEMPLATE by taito-cli.\n\
# It is located here only to avoid accidental build breaks. Keep modifications \n\
# minimal and improve the original instead.\n\n" | \
  cat - cloudbuild.yaml > temp && \
  truncate --size 0 cloudbuild.yaml && \
  cat temp > cloudbuild.yaml

# Replace some strings

if [[ ${mode} != "upgrade" ]] || [[ -z "${taito_project_short}" ]]; then
  echo "Give a short version of the project name '${taito_project}'."
  echo "It should be unique but also descriptive as it will be used"
  echo "as a database name and as a database username."
  echo
  export taito_project_short=""
  while [[ "${#taito_project_short}" -lt 5 ]] || \
    [[ "${#taito_project_short}" -gt 10 ]]
  do
    echo "Short project name (5-10 characters)?"
    read -r taito_project_short
  done
fi

echo "Replacing project and company names in files. Please wait..."

find . -type f -exec sed -i \
  -e "s/wptemplate/${taito_project_short}/g" 2> /dev/null {} \;
find . -type f -exec sed -i \
  -e "s/wordpress_template/${taito_vc_repository_alt}/g" 2> /dev/null {} \;
find . -type f -exec sed -i \
  -e "s/wordpress-template/${taito_vc_repository}/g" 2> /dev/null {} \;
find . -type f -exec sed -i \
  -e "s/companyname/${taito_company}/g" 2> /dev/null {} \;
find . -type f -exec sed -i \
  -e "s/WORDPRESS-TEMPLATE/wordpress-template/g" 2> /dev/null {} \;

# TODO: everything below has been pretty much copy pasted from server-template

echo "Generating unique random ports (avoid conflicts with other projects)..."

ingress_port=$(shuf -i 8000-9999 -n 1)
db_port=$(shuf -i 6000-7999 -n 1)
sed -i "s/7587/${db_port}/g" taito-config.sh docker-compose.yaml \
  TAITOLESS.md &> /dev/null
sed -i "s/4635/${ingress_port}/g" docker-compose.yaml taito-config.sh \
  TAITOLESS.md &> /dev/null

echo "Replacing template variables with the given settings..."

# Replace template variables in taito-config.sh with the given settings
sed -i "s/taito_company=.*/taito_company=${taito_company}/g" taito-config.sh
sed -i "s/taito_family=.*/taito_family=${taito_family:-}/g" taito-config.sh
sed -i "s/taito_application=.*/taito_application=${taito_application:-}/g" taito-config.sh
sed -i "s/taito_suffix=.*/taito_suffix=${taito_suffix:-}/g" taito-config.sh
sed -i "s/taito_project=.*/taito_project=${taito_vc_repository}/g" taito-config.sh

echo "Replacing template variables with the user specific settings..."

# Replace template variables in taito-config.sh with user specific settings
sed -i "s/\${template_default_organization:?}/${template_default_organization}/g" taito-config.sh
sed -i "s/\${template_default_organization_abbr:?}/${template_default_organization_abbr}/g" taito-config.sh
sed -i "s/\${template_default_git_organization:?}/${template_default_git_organization}/g" taito-config.sh
sed -i "s/\${template_default_git_url:?}/${template_default_git_url//\//\\/}/g" taito-config.sh
sed -i "s/\${template_default_sentry_organization:?}/${template_default_sentry_organization}/g" taito-config.sh
sed -i "s/\${template_default_domain:?}/${template_default_domain}/g" taito-config.sh
sed -i "s/\${template_default_domain_prod:?}/${template_default_domain_prod}/g" taito-config.sh
sed -i "s/\${template_default_zone:?}/${template_default_zone}/g" taito-config.sh
sed -i "s/\${template_default_zone_prod:?}/${template_default_zone_prod}/g" taito-config.sh
sed -i "s/\${template_default_provider:?}/${template_default_provider}/g" taito-config.sh
sed -i "s/\${template_default_provider_org_id:?}/${template_default_provider_org_id}/g" taito-config.sh
sed -i "s/\${template_default_provider_org_id_prod:?}/${template_default_provider_org_id_prod}/g" taito-config.sh
sed -i "s/\${template_default_provider_region:?}/${template_default_provider_region}/g" taito-config.sh
sed -i "s/\${template_default_provider_zone:?}/${template_default_provider_zone}/g" taito-config.sh
sed -i "s/\${template_default_provider_region_prod:?}/${template_default_provider_region_prod}/g" taito-config.sh
sed -i "s/\${template_default_provider_zone_prod:?}/${template_default_provider_zone_prod}/g" taito-config.sh
sed -i "s/\${template_default_monitoring_uptime_channels_prod:-}/${template_default_monitoring_uptime_channels_prod//\//\\\/}/g" taito-config.sh
sed -i "s/\${template_default_container_registry:?}/${template_default_container_registry}/g" taito-config.sh
sed -i "s/\${template_default_source_git:?}/${template_default_source_git}/g" taito-config.sh
sed -i "s/\${template_default_dest_git:?}/${template_default_dest_git}/g" taito-config.sh

# Kubernetes
sed -i \
  "s/\${template_default_kubernetes:?}/${template_default_kubernetes}/g" taito-config.sh

# Database
sed -i \
  "s/\${template_default_mysql:?}/${template_default_mysql}/g" taito-config.sh
sed -i \
  "s/\${template_default_mysql_host:?}/${template_default_mysql_host}/g" taito-config.sh
sed -i \
  "s/\${template_default_mysql_host_prod:?}/${template_default_mysql_host_prod}/g" taito-config.sh
sed -i \
  "s/\${template_default_mysql_master_username:?}/${template_default_mysql_master_username}/g" taito-config.sh
sed -i \
  "s/\${template_default_mysql_master_password_hint:?}/${template_default_mysql_master_password_hint}/g" taito-config.sh

# Storage
sed -i "s/\${template_default_storage_class:-}/${template_default_storage_class:-}/g" taito-config.sh
sed -i "s/\${template_default_storage_class_prod:-}/${template_default_storage_class_prod:-}/g" taito-config.sh
sed -i "s/\${template_default_storage_location:-}/${template_default_storage_location:-}/g" taito-config.sh
sed -i "s/\${template_default_storage_location_prod:-}/${template_default_storage_location_prod:-}/g" taito-config.sh
sed -i "s/\${template_default_storage_days:-}/${template_default_storage_days:-}/g" taito-config.sh
sed -i "s/\${template_default_storage_days_prod:-}/${template_default_storage_days_prod:-}/g" taito-config.sh

# Backups
sed -i "s/\${template_default_backup_class:-}/${template_default_backup_class:-}/g" taito-config.sh
sed -i "s/\${template_default_backup_class_prod:-}/${template_default_backup_class_prod:-}/g" taito-config.sh
sed -i "s/\${template_default_backup_location:-}/${template_default_backup_location:-}/g" taito-config.sh
sed -i "s/\${template_default_backup_location_prod:-}/${template_default_backup_location_prod:-}/g" taito-config.sh
sed -i "s/\${template_default_backup_days:-}/${template_default_backup_days:-}/g" taito-config.sh
sed -i "s/\${template_default_backup_days_prod:-}/${template_default_backup_days_prod:-}/g" taito-config.sh

echo "Removing template settings from cloudbuild.yaml..."

sed -i "s|\${_TEMPLATE_DEFAULT_TAITO_IMAGE}|${template_default_taito_image}|g" cloudbuild.yaml
sed -i '/_TEMPLATE_DEFAULT_/d' cloudbuild.yaml
sed -i '/template_default_taito_image/d' cloudbuild.yaml

############################
# Replace provider settings
############################

echo "Configuring provider settings for ${template_default_provider}"
if [[ "${template_default_provider}" == "gcloud" ]]; then
  echo "gcloud already configured by default"
elif [[ "${template_default_provider}" == "aws" ]]; then
  sed -i "s/ gcloud:-local/ aws:-local/" taito-config.sh
  sed -i "s/ gcloud-secrets:-local//" taito-config.sh
  sed -i "s/ gcloud-storage:-local/ aws-storage:-local/" taito-config.sh
  sed -i '/gcloud-monitoring:-local/d' taito-config.sh
  sed -i "s/kubernetes_db_proxy_enabled=false/kubernetes_db_proxy_enabled=true/" taito-config.sh
  sed -i '/gserviceaccount/d' taito-config.sh

  # Links
  sed -i '/* services/d' taito-config.sh
  sed -i "s|^  \\* logs:ENV=.*|  * logs:ENV=https://${template_default_provider_region}.console.aws.amazon.com/cloudwatch/home?region=${template_default_provider_region}#logs: Logs (:ENV)|" taito-config.sh
  # TODO: monitoring

  # AWS credentials
  sed -i '/^  _IMAGE_REGISTRY:/a\  _AWS_ACCESS_KEY_ID:\n  _AWS_SECRET_ACCESS_KEY:' cloudbuild.yaml
  sed -i '/^    - taito_mode=ci/a\    - AWS_ACCESS_KEY_ID=$_AWS_ACCESS_KEY_ID\n    - AWS_SECRET_ACCESS_KEY=$_AWS_SECRET_ACCESS_KEY' cloudbuild.yaml
  sed -i "/^    # TODO: should be implemented in taito-cli plugin\$/,/^$/d" cloudbuild.yaml

  echo "TODO: remove Google Cloud storage gateway"
else
  echo "ERROR: Unknown provider '${template_default_provider}'"
  exit 1
fi

######################
# Initialize CI/CD
######################

echo "Initializing CI/CD: $ci"
ci_script=

# aws
if [[ $ci == "aws" ]]; then
  ci_script=aws-pipelines.yml
  sed -i "s/ gcloud-ci:-local/aws-ci:-local/" taito-config.sh
  echo "NOTE: AWS CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -f aws-pipelines.yml
fi

# azure
if [[ $ci == "azure" ]]; then
  ci_script=azure-pipelines.yml
  sed -i "s/ gcloud-ci:-local/azure-ci:-local/" taito-config.sh
  echo "NOTE: Azure CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -f azure-pipelines.yml
fi

# bitbucket
if [[ $ci == "bitbucket" ]]; then
  ci_script=bitbucket-pipelines.yml
  sed -i "s/ gcloud-ci:-local/ bitbucket-ci:-local/" taito-config.sh

  # Links
  sed -i "s|^  \\* builds.*|  * builds=https://bitbucket.org/${template_default_git_organization:?}/${taito_vc_repository}/addon/pipelines/home Build logs|" taito-config.sh
  sed -i "s|^  \\* project=.*|  * project=https://bitbucket.org/${template_default_git_organization:?}/${taito_vc_repository}/addon/trello/trello-board Project management|" taito-config.sh
  # TODO: project documentation
else
  rm -f bitbucket-pipelines.yml
fi

# github
if [[ $ci == "github" ]]; then
  ci_script=.github/main.workflow
  sed -i "s/ gcloud-ci:-local/github-ci:-local/" taito-config.sh
  echo "NOTE: GitHub CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -rf .github
fi

# gitlab
if [[ $ci == "gitlab" ]]; then
  ci_script=.gitlab-ci.yml
  sed -i "s/ gcloud-ci:-local/gitlab-ci:-local/" taito-config.sh
  echo "NOTE: GitLab CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -rf .gitlab-ci.yml
fi

# gcloud
if [[ $ci == "gcloud" ]]; then
  ci_script=cloudbuild.yaml
  sed -i "s|\${_TEMPLATE_DEFAULT_TAITO_IMAGE}|${template_default_taito_image}|g" cloudbuild.yaml
  sed -i '/_TEMPLATE_DEFAULT_/d' cloudbuild.yaml
  sei -i '/taito project create/d' cloudbuild.yaml
  sed -i '/template_default_taito_image/d' cloudbuild.yaml
  sed -i "s|_IMAGE_REGISTRY: eu.gcr.io/\$PROJECT_ID|_IMAGE_REGISTRY: ${template_default_container_registry}|" cloudbuild.yaml
else
  rm -f cloudbuild.yaml
fi

# jenkins
if [[ $ci == "jenkins" ]]; then
  ci_script=Jenkinsfile
  sed -i "s/ gcloud-ci:-local/jenkins-ci:-local/" taito-config.sh
  echo "NOTE: Jenkins CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -f Jenkinsfile
fi

# shell
if [[ $ci == "shell" ]]; then
  ci_script=build.sh
  sed -i "s/ gcloud-ci:-local//" taito-config.sh
else
  rm -f build.sh
fi

# spinnaker
if [[ $ci_deploy_with_spinnaker == "true" ]]; then
  echo "NOTE: Spinnaker CI/CD not yet implemented."
  read -r
fi

# travis
if [[ $ci == "travis" ]]; then
  ci_script=.travis.yml
  sed -i "s/ gcloud-ci:-local/travis-ci:-local/" taito-config.sh
  echo "NOTE: Travis CI/CD not yet implemented. Implement it in '${ci_script}'."
  read -r
else
  rm -f .travis.yml
fi

# common
sed -i "s/\$template_default_taito_image_username/${template_default_taito_image_username:-}/g" "${ci_script}"
sed -i "s/\$template_default_taito_image_password/${template_default_taito_image_password:-}/g" "${ci_script}"
sed -i "s/\$template_default_taito_image_email/${template_default_taito_image_email:-}/g" "${ci_script}"
sed -i "s|\$template_default_taito_image|${template_default_taito_image}|g" "${ci_script}"

##############################
# Initialize semantic-release
##############################

if [[ "${template_default_git_provider}" != "github.com" ]]; then
  echo "Disabling semantic-release for git provider '${template_default_git_provider}'"
  echo "TODO: implement semantic-release support for '${template_default_git_provider}'"
  sed -i "s/release-pre:prod\": \"semantic-release/_release-pre:prod\": \"echo DISABLED semantic-release/g" package.json
  sed -i "s/release-post:prod\": \"semantic-release/_release-post:prod\": \"echo DISABLED semantic-release/g" package.json
  sed -i '/github-buildbot/d' taito-config.sh
fi

######################
# Clean up
######################

echo "Cleaning up"
rm -f temp || :
