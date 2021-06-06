# Without Taito CLI

This file has been copied from [WORDPRESS-TEMPLATE](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/). Keep modifications minimal and improve the [original](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/blob/dev/scripts/taito/TAITOLESS.md) instead. Project specific conventions are located in [README.md](../../README.md#conventions).

Table of contents:

* [Prerequisites](#prerequisites)
* [Quick start](#quick-start)
* [Testing](#testing)
* [Configuration](##onfiguration)

## Prerequisites

* [npm](https://github.com/npm/cli) that usually ships with [Node.js](https://nodejs.org/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [MySQL client](https://dev.mysql.com/doc/refman/8.0/en/programs-client.html)

## Quick start

Install mandatory libraries on host:

    npm install

Install additional libraries on host for autocompletion/linting on editor (optional):

    npm run install-dev

Set up environment variables required by `docker-compose.yaml`:

    . ./taito-config.sh

Setup secrets required by `docker-compose.yaml`:

> See the secret file paths at the end of `docker-compose.yaml` and set the secret file contents accordingly. Use `secret1234` as value for all 'randomly generated' secrets like database password. Ask other secret values from you colleagues or just retrieve them from dev environment with `kubectl get secrets -o yaml --namespace full-stack-template-dev`. You need to decode the base64 encoded values with the `base64` command-line tool).

Start containers defined in `docker-compose.yaml`:

    docker-compose up

Connect development database using password `secret1234`:

    mysql -h localhost -P 7587 -D $db_database_name -u $db_database_mgr_username

Open the application on browser:

    http://localhost:4635

Use `npm`, `docker-compose` and `docker` normally to run commands and operate containers.

If you would like to use some of the additional commands provided by Taito CLI also without using Taito CLI, first run the command with verbose option (`taito -v`) to see which commands Taito CLI executes under the hood, and then implement them in your `package.json` or `Makefile`.

## Configuration

Instructions defined in [CONFIGURATION.md](CONFIGURATION.md) apply. You just need to run commands with `npm` or `docker-compose` directly instead of Taito CLI. If you want to setup the application environments or run CI/CD steps without Taito CLI, see the following instructions.

### Creating an environment

* Run taito-config.sh to set the environment variables for the environment in question (dev, test, stag, canary, or prod):
    ```
    export taito_target_env=dev
    . taito-config.sh
    ```
* Run terraform scripts that are located at `scripts/terraform/`. Use `scripts/terraform/common/backend.tf` as backend, if you want to store terraform state on git. Note that the terraform scripts assume that a cloud provider project defined by `taito_resource_namespace` and `taito_resource_namespace_id` already exists and Terraform is allowed to create resources for that project.
* (TODO: create database with terraform instead): Create a relational database (or databases) for an environment e.g. by using cloud provider web UI. See `db_*` settings in `scripts/taito/main.sh` for database definitions. Create two user accounts for the database: `FULL_STACK_TEMPLATE_ENV` for deploying the database migrations (broad user rights) and `FULL_STACK_TEMPLATE_ENV_app` for the application (concise user rights). Configure also database extensions if required by the application (see `database/db.sql`).
* Set Kubernetes secret values with `kubectl`. The secrets are defined by `taito_secrets` in `scripts/taito/project.sh`, and they are referenced in `scripts/helm*.yaml` files.

### Setting up CI/CD

You can easily implement CI/CD steps without Taito CLI. See [continuous integration and delivery](https://taitounited.github.io/taito-cli/docs/06-continuous-integration-and-delivery) chapter of Taito CLI manual for instructions.
