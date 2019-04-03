#!/bin/bash -e

: "${template_project_path:?}"

echo
./scripts/taito-template/init.sh

# Copy files from template to project
yes | cp CONFIGURATION.md "${template_project_path}"
yes | cp DEVELOPMENT.md "${template_project_path}"
yes | cp cloudbuild.yaml "${template_project_path}"

mkdir -p "${template_project_path}/scripts/helm"
yes | cp -r "scripts/helm/requirements.yaml" \
  "${template_project_path}/scripts/helm/requirements.yaml" 2> /dev/null
yes | cp -r "scripts/update/*" \
  "${template_project_path}/scripts/update" 2> /dev/null
yes | cp -r "wordpress/Docker*" \
  "${template_project_path}/wordpress" 2> /dev/null

echo
echo
echo "--- Manual steps ---"
echo
echo "Recommended steps:"
echo "- Update wordpress plugins and other project dependencies."
echo
echo "If something stops working, try the following:"
echo "- Run 'taito upgrade' to upgrade your taito-cli"
echo "- Compare scripts/helm*.yaml with the template"
echo "- Compare taito-config.sh with the template"
echo "- Compare package.json with the template"
echo "- Compare cloudbuild.yaml with the previous version"
echo
