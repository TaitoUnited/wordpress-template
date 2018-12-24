#!/bin/bash -e

if [ ! -d /bitnami ]; then
  echo "init.sh: /bitnami does not exist. using data from container image."
  echo "init.sh: Setting up symbolic link: /bitnami -> /data-image"
  ln -s /data-image /bitnami
else
  echo "init.sh: using /bitnami permanent volume."
fi

echo "init.sh: DONE"
