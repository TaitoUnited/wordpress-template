# helm

This folder contains a reusable helm chart for wordpress sites. [Helm](https://helm.sh/) is a package manager for Kubernetes.

The subchart located in charts/wordpress was forked from https://github.com/bitnami/bitnami-docker-wordpress, but has been modified since:

- Added support for `externalDatabase.passwordSecretName` and `externalDatabase.passwordSecretKey` variables.
- Mount volumes only if `persistence.enabled` is true so that we can use also container data.
- Added `persistentVolumeReclaimPolicy: Retain` to prevent accidental deletion of persistent volume. --> But does it even work? Perhaps snapshots would be a better way?
- Modified svc.yaml (using simple ClusterIP)

Also:
- Added support for reading db settings from environment variables: `wordpress/init.sh` and `wordpress/helpers.js`

TODO: Either try to merge changes back to original chart or make a simplified custom chart.
