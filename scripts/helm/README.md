# helm

This folder contains a reusable helm chart for wordpress sites. [Helm](https://helm.sh/) is a package manager for Kubernetes.

The subchart located in charts/wordpress was forked from https://github.com/bitnami/bitnami-docker-wordpress, but has been modified since:

- Added support for `externalDatabase.passwordSecretName` and `externalDatabase.passwordSecretKey` variables.
- Added support for reading db settings from environment variables: `wordpress/app-entrypoint.sh` and `wordpress/template-env.sh`
- Added support for copying data from container image to pvc on container start:
  * Use `/bitnami-pvc` as mount path instead of `/bitnami`.
  * Mount volumes only if `persistence.enabled` is true so that we can determine if PVC is enabled during container bootstrap.
  * Copy data from container to pvc on container start: `wordpress/app-entrypoint.sh` -> `template-env.sh`

TODO: Either try to merge changes back to original chart or make a simplified custom chart.
