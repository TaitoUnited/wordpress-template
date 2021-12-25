# Configuration

This file has been copied from [WORDPRESS-TEMPLATE](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/). Keep modifications minimal and improve the [original](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/blob/dev/scripts/taito/CONFIGURATION.md) instead.

## Prerequisites

- [npm](https://github.com/npm/cli) that usually ships with [Node.js](https://nodejs.org/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Taito CLI](https://taitounited.github.io/taito-cli/) (or see [TAITOLESS.md](TAITOLESS.md))

## Local development environment

Start your local development environment by running `taito develop`. Once the command starts to install libraries, you can leave it on the background while you continue with configuration. Once the application has started, open the web gui with `taito open wordpress`. You can open the admin gui with `taito open admin` and display initial admin credentials with `taito info`. If the application fails to start, run `taito trouble` to see troubleshooting. More information on local development you can find from [DEVELOPMENT.md](DEVELOPMENT.md).

It is recommended to use [composer](https://getcomposer.org) to install WordPress plugins:

- Move `wordpress/data/composer.json` file to `wordpress/data/wordpress/composer.json`, and add your plugins there.
- Run `taito composer update` to install the plugins.

## Basic settings

1. Run `taito open conventions` in the project directory to see organization specific settings that you should configure for your git repository. At least you should set `dev` as the default branch to avoid people using master branch for development by accident.
2. Modify `scripts/taito/project.sh` if you need to change some settings. The default settings are ok for most projects.
3. Run `taito project apply`
4. Commit and push changes

- [ ] All done

## Your first remote environment (stag)

> Operations on production and staging environments might require admin rights. Please contact devops personnel if necessary.

Make sure your authentication is in effect:

    taito auth:stag

Create the environment:

    taito env apply:stag          # NOTE: Please use a strong basic auth password on WP projects

OPTIONAL: If the git repository is private, you may choose to write down the basic auth credentials to [README.md#links](../../README.md#links):

    EDIT README.md                # Edit the links section

Push changes to dev branch with a [Conventional Commits](http://conventionalcommits.org/) commit message (e.g. `chore: configuration`):

    taito stage                   # Or just: git add .
    taito commit                  # Or just: git commit -m 'chore: configuration'
    taito push                    # Or just: git push

Merge changes to stag branch:

    taito env merge:dev stag

See it build and deploy:

    taito open builds:stag
    taito status:stag

> The first CI/CD run takes some time as build cache is empty. Subsequent runs should be faster.

> If CI/CD deployment fails on permissions error during the first run, the CI/CD account might not have enough permissions to deploy all the changes. In such case, execute the deployment manually with `taito deployment deploy:dev IMAGE_TAG`, and the retry the failed CI/CD build.

> If CI/CD tests fail on certificate error during the first CI/CD run, just retry the CI/CD run. Certificate manager probably had not retrieved the certificate yet.

> If you have some trouble creating an environment, you can destroy it by running `taito env destroy:dev` and then try again with `taito env apply:dev`.

Open site on browser and install wordpress according to instructions:

    taito open wordpress:stag     # Open site
    taito open admin:stag         # Open admin GUI

You should use really strong passwords for your admin accounts. You can generate a strong password for your user in the WordPress Admin GUI.

> TIP: You can copy local database to staging with `taito db dump:local dump.sql`, replace urls in dump.sql, `taito db import:stag dump.sql`, `rm dump.sql`.

- [ ] All done

## Configuring file persistence (for media, etc)

Persistent volume claim (PVC) is disabled by default. This means that all data must be saved either to database or storage bucket. Try to use such wordpress plugins that do not save any permanent data to local disk. If this is not possible, you can enable PVC in `scripts/taito/project.sh` with the `wordpress_persistence_enabled` setting and set persistent file paths in `scripts/helm.yaml` with the `persistentVolumeMounts` setting.

If you don't need to manage media files directly on the production website, you can manage media files with your locally running wordpress and save the media files in git. This way the media files will be under version control, and will be bundled inside the Docker container.

You can also store media files to a storage bucket with one of the following wp-plugins. Note that bucket and service account are created automatically by Terraform on `taito env apply:ENV`. You can use dev environment resources also for local development (see [Creating a new server environment](#creating-a-new-server-environment)). You can open the bucket with `taito open storage:ENV` and the service account details with `taito open services:ENV`.

- [wp-stateless](https://wordpress.org/plugins/wp-stateless/) for Google Cloud. Settings: mode=`Stateless`, bucket=`wordpress-template-ENV`, bucket folder=`/media`, create a JSON key for `wordpress-template-ENV` service account from gcp console (`taito open services:ENV` -> Credentials -> Create service account key).
- [https://github.com/humanmade/S3-Uploads](S3-Uploads) for AWS.

Remember to delete all service account keys and other secrets from your local disk.

> TIP: If you use a storage bucket or other external resources in your WordPress setup, but you do not need a the `dev` remote environment, you can create `dev` environment resources by running `taito env apply:dev terraform` and use those resources in local development. Or alternatively you can also use the `stag` environment resources directly also for local development (see [local development](DEVELOPMENT.md#local-development)).

- [ ] All done

---

## Custom provider

If you cannot use Docker containers on your remote environments, you can customize the deployment with a custom provider. Instead of deploying the application as docker container images, you can, for example, install everything directly on the remote host. You can enable the custom provider with the `taito_provider` setting in `scripts/taito/config/main.sh` and implement [custom deployment scripts](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/blob/master/scripts/custom-provider) yourself.

## Kubernetes

If you need to, you can configure Kubernetes settings by modifying `heml*.yaml` files located under the `scripts`-directory. The default settings, however, are ok for most sites.

## Secrets

You can add a new secret like this:

1. Add a secret definition to the `taito_secrets` or the `taito_remote_secrets` setting in `scripts/taito/project.sh`.
2. Map the secret definition to a secret in `docker-compose.yaml` for Docker Compose and in `scripts/helm.yaml` for Kubernetes.
3. Run `taito secret rotate:ENV SECRET` to generate a secret value for an environment. Run the command for each environment separately. Note that the rotate command restarts all pods in the same namespace.

You can use the following methods in your secret definition:

- `random`: Randomly generated string (30 characters).
- `random-N`: Randomly generated string (N characters).
- `random-words`: Randomly generated words (6 words).
- `random-words-N`: Randomly generated words (N words).
- `random-uuid`: Randomly generated UUID.
- `manual`: Manually entered string (min 8 characters).
- `manual-N`: Manually entered string (min N characters).
- `file`: File. The file path is entered manually.
- `template-NAME`: File generated from a template by substituting environment variables and secrets values.
- `htpasswd`: htpasswd file that contains 1-N user credentials. User credentials are entered manually.
- `htpasswd-plain`: htpasswd file that contains 1-N user credentials. Passwords are stored in plain text. User credentials are entered manually.
- `csrkey`: Secret key generated for certificate signing request (CSR).

> See the [Environment variables and secrets](https://taitounited.github.io/taito-cli/tutorial/06-env-variables-and-secrets) chapter of Taito CLI tutorial for more instructions.
