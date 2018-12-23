#!/bin/bash -e

# Updates wordpress and plugins automatically and merges changes to staging

git checkout dev
git pull
# TODO update version in Dockerfiles
docker-compose pull wordpress-template-wordpress
docker-compose pull wordpress-template-database
docker-compose up --detach
sleep 120
docker exec -it wordpress-template-wordpress \
  su -c '/opt/bitnami/wp-cli/bin/wp plugin update --all --debug' bitnami
docker-compose stop
date >> UPDATELOG
git add .
git commit -m 'wp autoupdate [ci update plugins]'
git push
git checkout stag
git pull
git merge dev
git push
git checkout dev

# TODO send notification?
