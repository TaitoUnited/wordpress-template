# Development

This file has been copied from [WORDPRESS-TEMPLATE](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/). Keep modifications minimal and improve the [original](https://github.com/TaitoUnited/WORDPRESS-TEMPLATE/blob/dev/DEVELOPMENT.md) instead. Project specific conventions are located in [README.md](README.md#conventions). See the [taito-cli tutorial](https://github.com/TaitoUnited/taito-cli/blob/master/docs/tutorial/README.md) for more thorough development instructions. Note that taito-cli is optional (see [usage without taito-cli](#usage-without-taito-cli)).

Table of contents:

* [Prerequisites](#prerequisites)
* [Workflow](#workflow)
* [Local development](#local-development)
* [Version control](#version-control)
* [Deployment](#deployment)
* [Usage without Taito CLI](#usage-without-taito-cli)
* [Upgrading](#upgrading)

## Prerequisites

* [node.js](https://nodejs.org/)
* [docker-compose](https://docs.docker.com/compose/install/)
* Optional: [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)

## Workflow

It is recommended to do most modifications in local or staging environment. Use the production environment only for making frequent live modifications like creating new blog posts and managing users.

## Local development

> You can use either local or staging database for development by modifying `docker-compose.yaml`. If you use staging database for development, you must enable one of the media storage plugins (see [server environments](#server-environments) chapter). See [deployment](#deployment) chapter for instructions on copying data from one environment to another.

Install some libraries on host (add `--clean` for clean reinstall):

    taito install

Start containers (add `--clean` for clean rebuild and database init):

    taito start

Initialize database with `database/data/local.sql` data:

    taito init --clean

Show user accounts and other information that you can use to log in:

    taito info
    taito info:stag

Open app in browser:

    taito open app

Open admin GUI in browser:

    taito open admin

Access local or staging database:

    taito db connect                          # access using a command-line tool
    taito db connect:stag                     # access using a command-line tool
    taito db proxy                            # access using a database GUI tool
    taito db proxy:stag                       # access using a database GUI tool
    taito db import file.sql                  # import a sql script to database
    taito db import:stag file.sql             # import a sql script to database
    taito db dump file.sql                    # dump database to a file
    taito db dump:stag file.sql               # dump database to a file

Access data:

    # WordPress data is located locally in folder `wordpress/data`.
    # The data is copied inside the wordpress container image to `/data-image`
    # directory during build. However, the data will only be used on Kubernetes
    # if wordpress_persistence_enabled is turned off (no permanent volume).
    # If permanent volume is being used, you can copy data to the volume by
    # logging in to the container with `taito shell:wordpress:ENV` and copying
    # data from `/data-image` to `/bitnami`.

    # Add such files/folders to `wordpress/data/.gitignore` that should
    # not be committed to git. For example, example files used in development
    # only.

In case you are using local database for development instead of staging, you need to save database dump of your local database to `database/data/local.sql` before committing changes to git:

    taito db dump data

> Try to synchronize your work with other developers to avoid database change conflicts. You can easily overwrite changes of another developer when you push your local database changes to git.

> WARN: If production/staging database contains some confidential data like personally identifiable information of customers, you should never take a full database dump of production/staging data for development purposes. Or if you do, data should be anonymized carefully.

Start a shell on the wordpress container:

    taito shell:wordpress

Stop containers:

    taito stop

List all project related links and open one of them in browser:

    taito open -h
    taito open xxx

Cleaning:

    taito clean:wordpress                   # TODO
    taito clean:database                    # TODO
    taito clean:data                        # TODO: Clean gitignored wp data
    taito clean:npm                         # Delete node_modules directories
    taito clean                             # Clean everything

The commands mentioned above work also for server environments (`feat`, `dev`, `test`, `stag`, `prod`). Some examples for staging environment:

    taito open app:stag                     # Open application in browser
    taito open admin:stag                   # Open admin GUI in browser
    taito info:stag                         # Show info
    taito status:stag                       # Show status of dev environment
    taito shell:wordpress:stag              # Start a shell on wordpress container
    taito logs:wordpress:stag               # Tail logs of wordpress container
    taito open logs:stag                    # Open logs on browser
    taito open storage:stag                 # Open storage bucket on browser
    taito db connect:stag                   # Access database on command line
    taito db proxy:stag                     # Start a proxy for database access
    taito db import:stag ./database/fil.sql # Import a file to database
    taito db dump:stag                      # Dump database to a file
    taito db diff:stag test                 # Show diff between dev and test schemas
    taito db copy to:stag prod              # Copy prod database to stag

Run `taito -h` to get detailed instructions for all commands. Run `taito COMMAND -h` to show command help (e.g `taito db -h`, `taito db import -h`). For troubleshooting run `taito --trouble`. See PROJECT.md for project specific conventions and documentation.

> If you run into authorization errors, authenticate with the `taito auth:ENV` command.

> It's common that idle applications are run down to save resources on non-production environments. If your application seems to be down, you can start it by running `taito start:ENV`, or by pushing some changes to git.

## Version control

You can manage environment and feature branches using taito-cli. Run `taito env -h`, `taito feat -h`, and `taito hotfix -h` for examples.

All commit messages must be structured according to the [Conventional Commits](http://conventionalcommits.org/) convention as application version number and release notes are generated automatically during release by the [semantic-release](https://github.com/semantic-release/semantic-release) library. Commit messages are automatically validated before commit. You can also edit autogenerated release notes afterwards in GitHub (e.g. to combine some commits and clean up comments). Couple of commit message examples:

## Deployment

Deploying to different server environments:

* staging: Merge changes from dev to stag branch using fast-forward.
* production: Merge changes from stag branch to master branch using fast-forward. Version number and release notes are generated automatically by the CI/CD tool.

You can use the taito commands to manage branches, builds, and deployments. Run `taito env -h`, `taito feat -h`, `taito hotfix -h`, and `taito deployment -h` for instructions. Run `taito open builds` to see the build logs.

NOTE: Only Helm configuration from `./scripts` and the container image are deployed automatically on servers on git push. You have to migrate data manually between environments using taito commands. Some examples below.

> All copy commands have not yet have been implemented

Copy all data from production to staging:

```
    # Copy permanent volume data
    # NOTE: Required only if 'wordpress_persistence_enabled' is true
    taito data copy between:wordpress:prod:stag /bitnami /bitnami

    # Copy storage and database data
    taito storage copy between:prod:stag
    taito db copy between:prod:stag
    # TODO example for replacing '-prod' suffix with '-stag' on media urls

    # Merge some changes from dev to staging branch (deploys wordpress/data)

```

Copy all data from staging to production (WARNING: not always suitable):

```
    taito storage copy between:stag:prod
    taito db copy between:stag:prod
    # TODO example for replacing '-prod' suffix with '-stag' on media urls
    # Merge changes to master branch (deploys wordpress/data)
```

Migrate some data from staging to production:

```
    taito storage copy between:stag:prod SOURCE DEST
    taito db dump:stag ./stag-dump.sql
    ...create imports.sql manually...
    # TODO example for replacing '-prod' suffix with '-stag' on media urls
    taito db import:prod ./imports.sql
    # Merge changes to master branch (deploys wordpress/data)
```

> TODO: CI will update wp plugins installed on permanent volume automatically if `wordpress_persistence_enabled` is `true`. Otherwise wordpress will use plugins directly from the container image built based on the `wordpress/data` directory. --> OR always use plugins from container and mount only certain data directories?

> TODO: cloudbuild.yaml should take db export and volume snapshot automatically for prod.

## Usage without taito-cli

You can run this project without taito-cli, but it is not recommended as you'll lose many of the additional features that taito-cli provides.

Local development:

    npm install          # Install some libraries
    docker-compose up    # Start wordpress and database
    npm run              # Show all scripts that you can run with npm

## Upgrading

### WordPress and plugins

Manually:

1) **local wordpress**: Update WordPress version in `wordpress/Dockerfile` and `wordpress/Dockerfile.build` files. Push changes to dev branch.
2) **local clean start**: Clean start with `taito start --clean`, `taito init --clean`.
3) **local database**: Open admin GUI with `taito open admin` and update the database by clicking the database update button. Also check that the version number has actually changed, plugins have been updated, and everything works ok. Update local database dump with `taito db dump data`.
4) **local plugins**: Update plugins with `taito wp plugin update` command and push changes to dev branch. NOTE: By default only minor and patch versions are updated. This can be configured with `wordpress_plugin_update_flags` in `taito-config.sh`. Once in a while remove the `--minor` flag to update major version. You should also try `--patch` or major update if plugin update fails using the `--minor` flag.
5) **staging wordpress**: Merge changes to staging branch. After deployment open admin GUI with `taito open admin:stag` and update the database with button. Also check that the version number has actually changed, plugins have been updated, and everything works ok.
6) **prod wordpress**: Merge changes to prod branch. After deployment open admin GUI with `taito open admin:prod` and update the database with button. Also check that the version number has actually changed, plugins have been updated, and everything works ok.

Reverting changes:

TODO how to revert: container image, database, volume snapshot, (storage bucket)

> TODO: Update automatically (there are already some update scripts in `scripts/update` directory).

> TODO: cloudbuild.yaml should take db export and volume snapshot automatically for prod

### Project template

Run `taito template upgrade`. The command copies the latest versions of reusable Helm charts, terraform templates and CI/CD scripts to your project folder, and also this README.md file. You should not make project specific modifications to them as they are designed to be reusable and easily configurable for various needs. Improve the originals instead, and then upgrade.
