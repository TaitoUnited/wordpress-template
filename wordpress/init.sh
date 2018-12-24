#!/bin/bash -e

echo "init.sh: Making /bitnami symbolic link"
mv /bitnami /bitnami-old &> /dev/null || :
if [ ! -d /data-volume ]; then
  echo "init.sh: /data-volume does not exist. using data from container image."
  echo "init.sh: Setting up symbolic link: /bitnami -> /data-image"
  ln -s /data-image /bitnami
else
  echo "init.sh: using /data-volume as a permanent volume."
  echo "init.sh: Setting up symbolic link: /bitnami -> /data-volume"
  ln -s /data-volume /bitnami
fi

echo "init.sh: DONE"
