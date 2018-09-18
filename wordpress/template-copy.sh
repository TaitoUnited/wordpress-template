#!/bin/bash

exit_code=0

mv /bitnami /bitnami-old &> /dev/null

if [ ! -d /bitnami-pvc ]; then
  echo "template-copy.sh: /bitnami-pvc does not exist. using data from container."
  echo "template-copy.sh: Setting up symbolic link: /bitnami -> /bitnami-data"
  ln -s /bitnami-data /bitnami
else
  echo "template-copy.sh: /bitnami-pvc is a permanent volume."
  echo "template-copy.sh: Setting up symbolic link: /bitnami -> /bitnami-pvc"
  ln -s /bitnami-pvc /bitnami

  echo "template-copy.sh: Checking if we need to copy data to bitnami-pvc."
  while [ -f /bitnami-pvc/copying ] && ! find /bitnami-pvc/copying -mmin +10
  do
    echo "template-copy.sh: Waiting for other container to finish copying data"
    sleep 5
  done

  # copy data if timestamp on docker image is newer than the timestamp
  # on PVC mount
  # TODO timezones might cause problems or if datetime is not in sync
  if [ ! -f /bitnami-pvc/apache/data-timestamp ] || \
     [ -z $(find /bitnami-pvc/apache/data-timestamp -newer /data-timestamp) ]; then
    echo "template-copy.sh: Copying data from /bitnami-data to /bitnami-pvc"
    touch /bitnami-pvc/copying && \
      yes | cp -rf /bitnami-data/* /bitnami-pvc && \
      touch /bitnami-pvc/apache/data-timestamp && \
      echo "template-copy.sh: DONE!"
    exit_code=$?
    # always remove copying flag, even on error
    rm /bitnami-pvc/copying
  else
    echo "template-copy.sh: /bitnami-pvc is up-to-date"
  fi
fi

exit ${exit_code}
