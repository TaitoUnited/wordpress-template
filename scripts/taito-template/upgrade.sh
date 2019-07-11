#!/bin/bash -e

: "${template_project_path:?}"

# Read original random ports from docker-compose.yaml
export ingress_port
ingress_port=$(grep ":80\"" "${template_project_path}/docker-compose.yaml" | head -1 | sed 's/.*"\(.*\):.*/\1/')
export db_port
db_port=$(grep ":5432\"\|:3306\"" "${template_project_path}/docker-compose.yaml" | head -1 | sed 's/.*"\(.*\):.*/\1/')

${taito_setv:-}
./scripts/taito-template/init.sh

shopt -s dotglob

echo "Remove obsolete root files not to be copied"
rm -f \
  docker-* \
  README.md \
  taito-env-all-config.sh \
  taito-env-prod-config.sh \
  taito-testing-config.sh \
  trouble.txt

echo "Mark all configurations as 'done'"
sed -i "s/\[ \] All done/[x] All done/g" CONFIGURATION.md

echo "Copy all root files from template"
(yes | cp * "${template_project_path}" 2> /dev/null || :)

echo "Copy helm scripts from template"
mkdir -p "${template_project_path}/scripts/helm"
yes | cp -f scripts/helm/* "${template_project_path}/scripts/helm"

echo "Copy terraform scripts from template"
cp -rf scripts/terraform "${template_project_path}/scripts"

echo "Copy update scripts from template"
yes | cp -r scripts/update/* \
  "${template_project_path}/scripts/update/" 2> /dev/null

echo "Copy dockerfiles from template"
yes | cp wordpress/* \
  "${template_project_path}/wordpress/" 2> /dev/null || :

echo "Generate README.md links"
(cd "${template_project_path}" && (taito project docs || :))

echo
echo
echo "--- Manual steps ---"
echo
echo "Recommended steps:"
echo "- Review all changes before committing them to git"
echo
echo "If something stops working, try the following:"
echo "- Run 'taito upgrade' to upgrade your Taito CLI"
echo "- Compare scripts/helm*.yaml with the template"
echo "- Compare taito-*config.sh with the template"
echo "- Compare package.json with the template"
echo
