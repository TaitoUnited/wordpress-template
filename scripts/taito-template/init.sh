#!/bin/bash -e
: "${taito_company:?}"
: "${taito_vc_repository:?}"
: "${taito_vc_repository_alt:?}"
: "${taito_project:?}"

if [[ ${taito_verbose:-} == "true" ]]; then
  set -x
fi

# Remove .gitignore to allow committing data to git
rm wordpress/data/.gitignore
mv wordpress/data/.gitkeep wordpress/data/.gitignore

# Replace default admin password
admin_password=$(openssl rand -base64 40 | sed -e 's/[^a-zA-Z0-9]//g')
if [[ ${#admin_password} -gt 30 ]]; then
  admin_password="${admin_password: -30}"
fi
sed -i "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" scripts/helm/values.yaml
sed -i "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" docker-compose.yaml
sed -i "s|password-change-it-7983p4nWgRE2p4No2d9|${admin_password}|g" README.md

# Determine project short name
if [[ $taito_project_short != "wptemplate" ]]; then
  taito_project_short="${taito_project_short}"
else
  taito_project_short="${taito_vc_repository}"
fi
taito_project_short="${taito_project_short//-/}"
if [[ ! ${taito_project_short} ]] || \
   [[ "${#taito_project_short}" -lt 5 ]] || \
   [[ "${#taito_project_short}" -gt 10 ]]; then
  echo "Give a short version of the project name '${taito_vc_repository}'."
  echo "It should be unique but also descriptive as it will be used"
  echo "as a database name and as a database username."
  echo
  export taito_project_short=""
  while [[ ! ${taito_project_short} ]] || \
    [[ "${#taito_project_short}" -lt 5 ]] || \
    [[ "${#taito_project_short}" -gt 10 ]]
  do
    echo "Short project name (5-10 characters)?"
    read -r taito_project_short
  done
fi
echo "Project short name: $taito_project_short"

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

echo "Generating unique random ports (avoid conflicts with other projects)..."
if [[ ! $ingress_port ]]; then ingress_port=$(shuf -i 8000-9999 -n 1); fi
if [[ ! $db_port ]]; then db_port=$(shuf -i 6000-7999 -n 1); fi
sed -i "s/7587/${db_port}/g" scripts/taito/config/main.sh docker-compose.yaml \
  scripts/taito/TAITOLESS.md &> /dev/null || :
sed -i "s/4635/${ingress_port}/g" docker-compose.yaml scripts/taito/config/main.sh \
  scripts/taito/TAITOLESS.md &> /dev/null || :

if [[ ${taito_provider:?} != "gcp" ]]; then
  echo "Removing database proxy"
  sed -i 'database-proxy-serviceaccount/d' scripts/taito/project.sh
  sed -i '# db-proxy/d' ./scripts/helm.yaml
  sed -i "s/db_database_host/db_database_real_host/" ./scripts/helm.yaml
fi

./scripts/taito-template/common.sh
echo init done
