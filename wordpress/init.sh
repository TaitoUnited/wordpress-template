#!/bin/bash -e

echo "init.sh: Making /bitnami symbolic link"
mv /bitnami /bitnami-old &> /dev/null || :
if [ ! -d /bitnami-pvc ]; then
  echo "init.sh: /bitnami-pvc does not exist. using data from container."
  echo "init.sh: Setting up symbolic link: /bitnami -> /bitnami-data"
  ln -s /bitnami-data /bitnami
else
  echo "init.sh: /bitnami-pvc is a permanent volume."
  echo "init.sh: Setting up symbolic link: /bitnami -> /bitnami-pvc"
  ln -s /bitnami-pvc /bitnami
fi

echo "init.sh: DONE"
