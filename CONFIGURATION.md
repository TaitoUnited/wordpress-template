# Configuration

This file has been copied from [WORDPRESS-TEMPLATE](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/). Keep modifications minimal and improve the [original](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/blob/dev/CONFIGURATION.md) instead.

## Prerequisites

* [npm](https://github.com/npm/cli) that usually ships with [Node.js](https://nodejs.org/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [Taito CLI](https://taitounited.github.io/taito-cli/) (or see [TAITOLESS.md](TAITOLESS.md))

## Local development environment

Start your local development environment by running `taito kaboom`. Once the command starts to install libraries, you can leave it on the background while you continue with configuration. Once the application has started, open the web gui with `taito open wordpress`. You can open the admin gui with `taito open admin` and display initial admin credentials with `taito info`. If the application fails to start, run `taito trouble` to see troubleshooting. More information on local development you can find from [DEVELOPMENT.md](DEVELOPMENT.md).

## Basic settings

1. Run `taito open conventions` in the project directory to see organization specific settings that you should configure for your git repository. At least you should set `dev` as the default branch to avoid people using master branch for development by accident.
2. Modify `taito-env-all-config.sh` if you need to change some settings. The default settings are ok for most projects.
3. Run `taito project apply`
4. Commit and push changes

* [ ] All done

## Your first remote environment (stag)

> Operations on production and staging environments might require admin rights. Please contact devops personnel if necessary.

Make sure your authentication is in effect:

    taito auth:stag

Create the environment:

    taito env apply:stag          # NOTE: Please use a strong basic auth password on WP projects

Write down the basic auth credentials to [README.md#links](README.md#links):

    EDIT README.md                # Edit the links section

Write down the basic auth credentials to `taito-testing-config.sh`:

    EDIT taito-testing-config.sh  # Edit this: ci_test_base_url=https://username:secretpassword@...

Push changes to dev branch with a [Conventional Commits](http://conventionalcommits.org/) commit message (e.g. `chore: configuration`):

    taito stage                   # Or just: git add .
    taito commit                  # Or just: git commit -m 'chore: configuration'
    taito push                    # Or just: git push

Merge changes to stag branch:

    taito env merge:dev stag

See it build and deploy:

    taito open builds:stag
    taito status:stag

Open site on browser and install wordpress according to instructions:

    taito open wordpress:stag     # Open site
    taito open admin:stag         # Open admin GUI

You should use really strong passwords for your admin accounts. You can generate a strong password for your user in the WordPress Admin GUI.

> TIP: You can copy local database to staging with `taito db dump:local dump.sql`, replace urls in dump.sql, `taito db import:stag dump.sql`, `rm dump.sql`.

> If you have some trouble creating an environment, you can destroy it by running `taito env destroy:stag` and then try again with `taito env apply:stag`.

* [ ] All done

## Configuring file persistence (for media, etc)

Persistent volume claim (PVC) is disabled by default. This means that all data must be saved either to database or storage bucket. Try to use such wordpress plugins that do not save any permanent data to local disk. If this is not possible, you can enable PVC in `taito-env-all-config.sh` with the `wordpress_persistence_enabled` setting and set persistent file paths in `scripts/helm.yaml` with the `persistentVolumeMounts` setting.

If you don't need to manage media files directly on the production website, you can manage media files with your locally running wordpress and save the media files in git. This way the media files will be under version control, and will be bundled inside the Docker container.

You can also store media files to a storage bucket with one of the following wp-plugins. Note that bucket and service account are created automatically by Terraform on `taito env apply:ENV`. You can use dev environment resources also for local development (see [Creating a new server environment](#creating-a-new-server-environment)). You can open the bucket with `taito open storage:ENV` and the service account details with `taito open services:ENV`.
  * [wp-stateless](https://wordpress.org/plugins/wp-stateless/) for Google Cloud. Settings: mode=`Stateless`, bucket=`wordpress-template-ENV`, bucket folder=`/media`, create a JSON key for `wordpress-template-ENV` service account from gcp console (`taito open services:ENV` -> Credentials -> Create service account key).
  * [https://github.com/humanmade/S3-Uploads](S3-Uploads) for AWS.

Remember to delete all service account keys and other secrets from your local disk.

> TIP: If you use a storage bucket or other external resources in your WordPress setup, but you do not need a the `dev` remote environment, you can create `dev` environment resources by running `taito env apply:dev terraform` and use those resources in local development. Or alternatively you can also use the `stag` environment resources directly also for local development (see [local development](DEVELOPMENT.md#local-development)).

* [ ] All done

---

## Custom provider

If you cannot use Docker containers on your remote environments, you can customize the deployment with a custom provider. Instead of deploying the application as docker container images, you can, for example, install everything directly on the remote host. You can enable the custom provider with the `taito_provider` setting in `taito-config.sh` and implement [custom deployment scripts](https://github.com/TaitoUnited/FULL-STACK-TEMPLATE/blob/master/scripts/custom-provider) yourself.

## Kubernetes

If you need to, you can configure Kubernetes settings by modifying `heml*.yaml` files located under the `scripts`-directory. The default settings, however, are ok for most sites.

## Secrets

You can add a new secret like this:

1. Add a secret definition to the `taito_secrets` setting in `taito-env-all-config.sh`.
2. Map the secret definition to a secret in `docker-compose.yaml` for Docker Compose and in `scripts/helm.yaml` for Kubernetes.
3. Run `taito env rotate:ENV SECRET` to generate a secret value for an environment. Run the command for each environment separately. Note that the rotate command restarts all pods in the same namespace.
