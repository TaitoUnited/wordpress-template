#!/bin/bash -e

if [ ! -d /bitnami/wordpress ]; then
  echo "init.sh: /bitnami/wordpress does not exist. using data from container image."
  echo "init.sh: Setting up symbolic link: /bitnami/wordpress -> /data-image/wordpress"
  ln -s /data-image/wordpress /bitnami/wordpress
else
  echo "init.sh: using /bitnami/wordpress permanent volume."
fi

echo "init.sh: DONE"
