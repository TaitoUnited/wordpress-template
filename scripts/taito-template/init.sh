#!/bin/bash -e
# TODO: most of this has been pretty much copy pasted from server-template
: "${taito_organization:?}"
: "${taito_company:?}"
: "${taito_vc_repository:?}"
: "${taito_vc_repository_alt:?}"

: "${template_default_taito_image:?}"
: "${template_default_organization:?}"
: "${template_default_organization_abbr:?}"
: "${template_default_github_organization:?}"
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
: "${template_default_registry:?}"
: "${template_default_source_git:?}"
: "${template_default_dest_git:?}"
: "${template_default_kubernetes:?}"
: "${template_default_mysql:?}"

: "${template_project_path:?}"
: "${mode:?}"

${taito_setv:?}

# Remove .gitignore to allow committing data to git
rm wordpress/data/.gitignore
mv wordpress/data/.gitkeep wordpress/data/.gitignore

# Remove MIT license
# TODO leave a reference to the original?
rm LICENSE

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
sed -i "s/\${template_default_github_organization:?}/${template_default_github_organization}/g" taito-config.sh
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
sed -i "s/\${template_default_registry:?}/${template_default_registry}/g" taito-config.sh
sed -i "s/\${template_default_source_git:?}/${template_default_source_git}/g" taito-config.sh
sed -i "s/\${template_default_dest_git:?}/${template_default_dest_git}/g" taito-config.sh
sed -i \
  "s/\${template_default_kubernetes:?}/${template_default_kubernetes}/g" taito-config.sh
sed -i \
  "s/\${template_default_mysql:?}/${template_default_mysql}/g" taito-config.sh

echo "Setting random name..."
if [[ ! ${taito_random_name} ]]; then
  taito_random_name=$(taito -q util random words: 3)
fi
sed -i "s/^taito_random_name=.*$/taito_random_name=${taito_random_name}/g" taito-config.sh

echo "Removing template settings from cloudbuild.yaml..."

sed -i "s|\${_TEMPLATE_DEFAULT_TAITO_IMAGE}|${template_default_taito_image}|g" cloudbuild.yaml
sed -i '/_TEMPLATE_DEFAULT_/d' cloudbuild.yaml
sed -i '/template_default_taito_image/d' cloudbuild.yaml

rm -f temp || :
