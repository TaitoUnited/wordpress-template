#!/bin/bash

: "${taito_organization:?}"
: "${taito_company:?}"
: "${taito_repo_name:?}"
: "${taito_repo_name_alt:?}"

: "${template_default_taito_image:?}"
: "${template_default_organization:?}"
: "${template_default_domain:?}"
: "${template_default_zone:?}"
: "${template_default_zone_prod:?}"
: "${template_default_provider:?}"
: "${template_default_provider_org_id:?}"
: "${template_default_provider_org_id_prod:?}"
: "${template_default_provider_region:?}"
: "${template_default_provider_region_prod:?}"
: "${template_default_provider_zone:?}"
: "${template_default_provider_zone_prod:?}"
: "${template_default_registry:?}"
: "${template_default_source_git:?}"
: "${template_default_dest_git:?}"

: "${template_project_path:?}"
: "${mode:?}"

# Determine sed options
if [ "$(uname)" = "Darwin" ]; then
 sedi="-i ''"
else
 sedi="-i"
fi

# Remove .gitignore to allow committing data to git
rm wordpress/data/.gitignore

# Remove MIT license
# TODO leave a reference to the original?
rm LICENSE
# grep -v '"license":' < package.json > package.json.tmp
# mv package.json.tmp package.json

# Replace repository url in package.json
sed ${sedi} -- "s|TaitoUnited/wordpress-template.git|${taito_organization}/${taito_repo_name}.git|g" package.json

# Add some do not modify notes
echo "Adding do not modify notes..."

# Replace NOTE of README.md with a 'do not modify' note
{
sed '/TEMPLATE NOTE START/q' README.md
echo
echo "> This file has been copied from \
[orig-template](https://github.com/TaitoUnited/orig-template/). Keep \
modifications minimal and improve the original instead. Project \
specific documentation is located in PROJECT.md."
echo
sed -n -e '/TEMPLATE NOTE END/,$p' README.md
} > temp
truncate --size 0 README.md
cat temp > README.md

# Add 'do not modify' note to readme of helm chart
# echo \
# "> NOTE: This helm chart has been copied from \
# [orig-template](https://github.com/TaitoUnited/orig-template/). It is \
# located here only to avoid accidental build breaks. Do not modify it. \
# Improve the original instead." | \
#   cat - scripts/helm/README.md > temp && \
#   truncate --size 0 scripts/helm/README.md && \
#   cat temp > scripts/helm/README.md

# Add 'do not modify' note to readme of terraform
echo \
"> NOTE: These terraform scripts have been copied from \
[orig-template](https://github.com/TaitoUnited/orig-template/). They are \
located here only to avoid accidental build breaks. Do not modify them. \
Improve the originals instead." | \
  cat - scripts/terraform/README.md > temp && \
  truncate --size 0 scripts/terraform/README.md && \
  cat temp > scripts/terraform/README.md

# Add 'do not modify' note to cloudbuild.yaml
printf \
"# NOTE: This file has been generated from orig-template by taito-cli.\n\
# It is located here only to avoid accidental build breaks. Keep modifications \n\
# minimal and improve the original instead.\n\n" | \
  cat - cloudbuild.yaml > temp && \
  truncate --size 0 cloudbuild.yaml && \
  cat temp > cloudbuild.yaml

# Replace some strings

echo "Give a short version of the project name '${taito_project}'."
echo "It should be unique but also descriptive as it will be used"
echo "as a database name and as a database user name."
echo
while \
  [[ -z "${taito_project_short}" ]] || \
  [[ "${#taito_project_short}" -gt 10 ]]
do
  echo "Short project name (max 10 chars)?"
  read -r taito_project_short
done

echo "Replacing project and company names in files. Please wait..."
if [ "$(uname)" = "Darwin" ]; then
  find . -type f -exec sed -i '' \
    -e "s/wptemplate/${taito_project_short}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i '' \
    -e "s/wordpress_template/${taito_repo_name_alt}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i '' \
    -e "s/wordpress-template/${taito_repo_name}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i '' \
    -e "s/companyname/${taito_company}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i '' \
    -e "s/orig-template/wordpress-template/g" 2> /dev/null {} \;
else
  find . -type f -exec sed -i \
    -e "s/wptemplate/${taito_project_short}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i \
    -e "s/wordpress_template/${taito_repo_name_alt}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i \
    -e "s/wordpress-template/${taito_repo_name}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i \
    -e "s/companyname/${taito_company}/g" 2> /dev/null {} \;
  find . -type f -exec sed -i \
    -e "s/orig-template/wordpress-template/g" 2> /dev/null {} \;
fi

# Generate ports
echo "Generating unique random ports (avoid conflicts with other projects)..."

ingress_port=$(shuf -i 8000-9999 -n 1)
db_port=$(shuf -i 6000-7999 -n 1)
sed ${sedi} -- "s/7587/${db_port}/g" taito-config.sh &> /dev/null
sed ${sedi} -- "s/7587/${db_port}/g" docker-compose.yaml &> /dev/null
sed ${sedi} -- "s/4635/${ingress_port}/g" docker-compose.yaml taito-config.sh \
  ./admin/package.json ./client/package.json &> /dev/null

echo "Replacing template variables with the given settings..."

# Replace template variables in taito-config.sh with the given settings
sed ${sedi} -- "s/export taito_company=\".*\"/export taito_company=\"${taito_company}\"/g" taito-config.sh
sed ${sedi} -- "s/export taito_family=\".*\"/export taito_family=\"${taito_family:-}\"/g" taito-config.sh
sed ${sedi} -- "s/export taito_application=\".*\"/export taito_application=\"${taito_application:-}\"/g" taito-config.sh
sed ${sedi} -- "s/export taito_suffix=\".*\"/export taito_suffix=\"${taito_suffix:-}\"/g" taito-config.sh
sed ${sedi} -- "s/export taito_repo_name=\".*\"/export taito_repo_name=\"${taito_repo_name}\"/g" taito-config.sh
sed ${sedi} -- "s/export taito_project=\".*\"/export taito_project=\"${taito_repo_name}\"/g" taito-config.sh

echo "Replacing template variables with the user specific settings..."

# Replace template variables in taito-config.sh with user specific settings
sed ${sedi} -- "s/\${template_default_organization:?}/${template_default_organization}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_domain:?}/${template_default_domain}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_zone:?}/${template_default_zone}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_zone_prod:?}/${template_default_zone_prod}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider:?}/${template_default_provider}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider:?}/${template_default_provider_billing_account:-}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider:?}/${template_default_provider_org_id}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider:?}/${template_default_provider_org_id_prod}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider_region:?}/${template_default_provider_region}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider_zone:?}/${template_default_provider_zone}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider_region_prod:?}/${template_default_provider_region_prod}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_provider_zone_prod:?}/${template_default_provider_zone_prod}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_registry:?}/${template_default_registry}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_source_git:?}/${template_default_source_git}/g" taito-config.sh
sed ${sedi} -- "s/\${template_default_dest_git:?}/${template_default_dest_git}/g" taito-config.sh

echo "Removing template settings from cloudbuild.yaml..."

sed ${sedi} -- "s|\${_TEMPLATE_DEFAULT_TAITO_IMAGE}|${template_default_taito_image}|g" cloudbuild.yaml
sed ${sedi} -- '/_TEMPLATE_DEFAULT_/d' cloudbuild.yaml
sed ${sedi} -- '/template_default_taito_image/d' cloudbuild.yaml

rm -f temp
