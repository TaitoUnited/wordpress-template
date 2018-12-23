# wordpress-template

[//]: # (TEMPLATE NOTE START)

Wordpress-template is a project template for WordPress sites. Create a new project from this template by running `taito project create: wordpress-template`.

TIP: A static site generator combined with a CMS system, git repository and some additional services provides a more secure and care-free alternative for WordPress sites. It also provides a sensible way to do version control and automatic migrations between environments. However, such implementation doesn't offer as much plug-and-play functionality as WordPress does. See [gatsby-template](https://github.com/TaitoUnited/gatsby-template) or [hugo-template](https://github.com/TaitoUnited/hugo-template) as an example.

[//]: # (TEMPLATE NOTE END)

Table of contents:

* [Links](#links)
* [Prerequisites](#prerequisites)
* [Workflow](#workflow)
* [Upgrading WordPress](#upgrading-wordpress)
* [Local development](#local-development)
* [Deployment](#deployment)
* [Version control](#version-control)
* [Configuration](#configuration)

## Links

If the credentials are shared, you probably know where to find them.

[//]: # (GENERATED LINKS START)

LINKS WILL BE GENERATED HERE

[//]: # (GENERATED LINKS END)

> You can update this section by configuring links in `taito-config.sh` and running `taito project docs`.

## Prerequisites

* [node.js](https://nodejs.org/)
* [docker-compose](https://docs.docker.com/compose/install/)
* Optional but highly recommended: [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)

## Workflow

It is recommended to do large modifications in local or staging environment. Use the production environment only for making frequent live modifications like creating new blog posts and managing users.

## Updating WordPress

> TODO: Automatically -> There are update scripts in `scripts/update` directory.
> TODO: Cache plugins should be disabled during an update?
> TODO: cloudbuild.yaml should take db export and volume snapshot automatically for prod

Manually:

1) **local wordpress**: Update WordPress version in `wordpress/Dockerfile` and `wordpress/Dockerfile.build` files. Push changes to dev branch.
2) **local plugins**: Update plugins either with `taito wp update plugins` command or by using the WordPress Admin GUI. Push changes to dev branch and add string `[ci update plugins]` in the commit message content. It informs CI that plugins should be updated after deployment if persistent volume claim is being used.
3) **staging wordpress**: Merge changes to staging branch, after deployment open admin GUI with `taito open admin:stag` and check that the version number has actually changed, plugins have been updated, and everything works ok.
4) **prod wordpress**: Merge changes to prod branch, after deployment open admin GUI with `taito open admin:prod` and check that the version number has actually changed, plugins have been updated, and everything works ok.

Reverting changes:

TODO how to revert: container image, database, volume snapshot, (storage bucket)

## Local development

> You can use either local or staging database for development by modifying `docker-compose.yaml`. If you use staging for development, you must enable one of the media storage plugins (see [server environments](#server-environments) chapter), but using a media storage plugin is highly recommended anyway. See [deployment](#deployment) chapter for instructions on copying data from one environment to another.

Install some libraries on host (add `--clean` for clean reinstall):

    taito install

Start containers (add `--clean` for clean rebuild and database init):

    taito start

Show user accounts and other information that you can use to log in:

    taito info:stag

Open app in browser:

    taito open app

Open admin GUI in browser:

    taito open admin

Access staging database:

    taito db connect:stag                     # access using a command-line tool
    taito db proxy:stag                       # access using a database GUI tool
    taito db import:stag ./database/file.sql  # import a sql script to database

Access data:

    # WordPress data is located locally in folder `wordpress/data`.
    # Add such files/folders to `wordpress/data/.gitignore` that should
    # not be committed to git.

In case you are using local database for development instead of staging, you need to save database dump of your local database to `database/init/init.sql` before committing changes to git:

    taito db dump ./database/init/init.sql

    > Try to synchronize your work with other developers to avoid conflicts. You can easily overwrite changes of another developer when you push your local database changes to git.

    > WARN: If production/staging database contains some confidential data like personally identifiable information of customers, you should never take a full database dump of production/staging data for development purposes. Or if you do, data should be anonymized carefully.

Start a shell on a container:

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

Run `taito -h` to get detailed instructions for all commands. Run `taito COMMAND -h` to show command help (e.g `taito vc -h`, `taito db -h`, `taito db import -h`). For troubleshooting run `taito --trouble`. See PROJECT.md for project specific conventions and documentation.

> If you run into authorization errors, authenticate with the `taito --auth:ENV` command.

> It's common that idle applications are run down to save resources on non-production environments. If your application seems to be down, you can start it by running `taito start:ENV`, or by pushing some changes to git.

### Without taito-cli

You can run this project without taito-cli, but it is not recommended as you'll lose many of the additional features that taito-cli provides.

Local development:

    npm install          # Install some libraries
    docker-compose up    # Start wordpress and database
    npm run              # Show all scripts that you can run with npm

## Version control

You can manage environment and feature branches using taito-cli. Run `taito vc -h` for examples.

All commit messages must be structured according to the [Conventional Commits](http://conventionalcommits.org/) convention as application version number and release notes are generated automatically during release by the [semantic-release](https://github.com/semantic-release/semantic-release) library. Commit messages are automatically validated before commit. You can also edit autogenerated release notes afterwards in GitHub (e.g. to combine some commits and clean up comments). Couple of commit message examples:

## Deployment

Deploying to different environments:

* staging: Push changes staging branch using fast-forward.
* TODO: Backup prod database before deploying to prod.
* TODO: Create snapshot of the prod persistent disk before deploying to prod.
* prod: Merge changes from staging branch to master branch using fast-forward. Version number and release notes are generated automatically by the CI/CD tool.

NOTE: Only Helm configuration from `./scripts` and data from `./wordpress/data` are deployed automatically on servers on git push. You have to migrate database and storage bucket data between environments using taito commands. Some examples below.

> Copy commands might not yet have been implemented

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

## Configuration

Done:
* [ ] GitHub settings
* [ ] Basic project settings
* [ ] Server environments: stag
* [ ] Server environments: prod

### GitHub settings

Recommended settings for most projects.

Options:
* Data services: Allow GitHub to perform read-only analysis: on
* Data services: Dependency graph: on
* Data services: Vulnerability alerts: on

Branches:
* Default branch: dev
* Protected branch: master (TODO: more protection settings)

Collaborators & teams:
* Teams: Select admin permission for the Admins team
* Teams: Select write permission for the Developers team
* Collaborators: Add additional collaborators if required.
* Collaborators: Remove repository creator (= yourself) from the collaborator list (NOTE: Set all the other GitHub settings before this one!)

### Basic project settings

1. Configure `taito-config.sh` if you need to change some settings. The default settings are ok for most projects.
2. Run `taito project apply`
3. Commit and push changes

### Server environments

> Operations on production and staging environments require admin rights, if they contain confidential data. Please contact devops personnel.

#### Creating a new server environment

* *Only for production: Configure DNS record.*
* *Only for production: Configure app url in `taito-config.sh`*
* Run `taito env apply:ENV` to create an environment.
* At some point you will be asked to create basic auth credentials. The basic auth credentials are used only for hiding non-production environments, but since WordPress has security issues, it's best to use a strong autogenerated password for each environment. You can always show the password with `taito info:ENV` and share it with `taito passwd share`.
* Deploy wordpress to the newly created environment by pushing/merging some changes to the environment branch in question.
* Generate a new password for the admin user by using the WordPress admin GUI (`taito open admin:ENV`). The initial admin password is: `admin-pass-change-it-7983p4nWgRE2p4No2d9`. If the admin account is shared, save the new password to a secure shared location. And never use the same admin password for every environment, as dev database is committed to git.

#### Configuring file persistence (for media, etc)

* Persistent volume claim (PVC) is disabled by default. This means that all data must be saved either to database or storage bucket. Try to use wordpress plugins that do not save any permanent data to local disk. If this is not possible, you can enable PVC in `taito-config.sh` with the `wordpress_persistence_enabled` setting. With the setting enabled, the data from `wordpress/data` folder will be copied automatically to the permanent volume by the `wordpress/template-copy.sh` script.
* If it seems that media files are only files that need to be stored permanently on disk, it is recommended to use storage bucket instead of persistent volume claim. You can store media files to a storage bucket with one of the following wp-plugins. Note that bucket and service account are created automatically by Terraform if terraform plugin is enabled in `taito-config.sh`. You can open the bucket with `taito open storage:ENV` and the service account details with `taito open services:ENV`.
  * [wp-stateless](https://wordpress.org/plugins/wp-stateless/) for Google Cloud. Settings: mode=`Stateless`, bucket=`wordpress-template-ENV`, bucket folder=`/media`, create a JSON key for `wordpress-template-ENV` service account from gcloud console (`taito open project:ENV` -> APIs & Services -> Credentials -> Create service account key).
  * [https://github.com/humanmade/S3-Uploads](S3-Uploads) for AWS.
* Remember to delete the service account keys that you created in the previous step from your local disk.

TODO backup persistent volume (e.g. disk snapshots)

#### Kubernetes

If you need to, you can configure Kubernetes settings by modifying `heml*.yaml` files located under the `scripts`-directory. The default settings, however, are ok for most sites.

#### Secrets

If you need to, you can add new secrets like this:

1. Add a secret definition to `taito-config.sh` (taito_secrets)
2. Map secret to an environment variable in some of the `helm.yaml` files located under the `scripts`-directory.
3. Run `taito env rotate:ENV [SECRET]` to generate a secret value for an environment. Run the command for each environment separately. Note that the rotate command restarts all pods in the same namespace.

> For local development you can just define secrets as normal environment variables in `docker-compose.yaml` given that they are not confidential.

### Upgrading to the latest version of the project template

Run `taito template upgrade`. The command copies the latest versions of reusable Helm charts, terraform templates and CI/CD scripts to your project folder, and also this README.md file. You should not make project specific modifications to them as they are designed to be reusable and easily configurable for various needs. Improve the originals instead, and then upgrade.
