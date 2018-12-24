#!/bin/bash -e

# Updates wordpress and plugins automatically and merges changes to staging

git checkout dev
git pull
# TODO check latest version with docker and update version in Dockerfiles
docker-compose pull wordpress-template-wordpress
docker-compose pull wordpress-template-database
docker-compose up --detach
# TODO poll until some configured text is found on landing page + timeout
docker exec -it wordpress-template-wordpress \
  su -c '/opt/bitnami/wp-cli/bin/wp plugin update --all --debug' bitnami
# TODO check that configured text is still shown on landing page + timeout
docker-compose stop
date >> UPDATELOG
git add .
git commit -m 'wp autoupdate'
git push
git checkout stag
git pull
git merge dev
git push
git checkout dev

# TODO send notification?
