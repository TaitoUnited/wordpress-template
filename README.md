# wordpress-template

[//]: # (TEMPLATE NOTE START)

Wordpress-template is a project template for WordPress sites. Create a new project from this template by running `taito template create: wordpress-template`.

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

Non-production basic auth credentials: TODO: change `user` / `painipaini`. If the admin account is shared among people, you can find the admin credentials from shared password manager.

[//]: # (GENERATED LINKS START)

* [Admin user interface (prod)](https://wordpress-template-prod.taitodev.com/admin/)
* [Admin user interface (stag)](https://wordpress-template-stag.taitodev.com/admin/)
* [Application (prod)](https://wordpress-template-prod.taitodev.com)
* [Application (stag)](https://wordpress-template-stag.taitodev.com)
* [Build logs](https://console.cloud.google.com/gcr/builds?project=gcloud-temp1&query=source.repo_source.repo_name%3D%22github-taitounited-wordpress-template%22)
* [GitHub repository](https://github.com/taitounited/wordpress-template)
* [Google project (prod)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-prod)
* [Google project (stag)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-prod)
* [Kanban boards](https://github.com/taitounited/wordpress-template/projects)
* [Logs (prod)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-prod)
* [Logs (stag)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-stag)
* [Project documentation](https://github.com/taitounited/wordpress-template/wiki)
* [Storage bucket (prod)](https://console.cloud.google.com/storage/browser/wordpress-template-prod?project=taitounited-companyname-prod)
* [Storage bucket (stag)](https://console.cloud.google.com/storage/browser/wordpress-template-stag?project=taitounited-companyname-prod)
* [Uptime monitoring (Stackdriver)](https://app.google.stackdriver.com/uptime?project=gcloud-temp1)

[//]: # (GENERATED LINKS END)

> You can update this section by configuring links in `taito-config.sh` and running `taito project docs`.

## Prerequisites

* [node.js](https://nodejs.org/)
* [docker-compose](https://docs.docker.com/compose/install/)

Optional but highly recommended:

* [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)

## Workflow

It is recommended to do most modifications in local or staging environment first. Use the production environment only for making frequent live modifications like creating new blog posts and managing users.

## Upgrading WordPress

Upgrade WordPress version both in `docker-compose.yaml` and in `scripts/heml.yaml`. Push the change to different environment branches. Check that the upgrade doesn't break anything before pushing it to master branch.

## Local development

> You can use either the local or staging database for development by modifying `docker-compose.yaml`. It is recommended to use the staging database also for local development, if it does not contain any confidential data.

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

In case you are using local database for development, you need to save database dump to `database/init/init.sql` before committing changes to git:

    taito db dump

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

## Deployment

Deploying to different environments:

* staging: Merge changes from dev branch to staging branch using fast-forward.
* prod: Merge changes from staging branch to master branch using fast-forward. Version number and release notes are generated automatically by the CI/CD tool.

> You can use taito-cli to [manage environment branches](#version-control).

NOTE: Currently only Helm configuration is deployed automatically on git push. You have to migrate database data and files yourself using taito commands. Some examples:

```
    # Access staging
    taito shell:wordpress:stag
    taito db connect:stag

    # Copy a theme to staging
    taito exec:wordpress:stag rm -rf /bitnami/wordpress/wp-content/themes/mytheme
    taito copy to:wordpress:stag ./wordpress/data/wordpress/wp-content/mytheme /bitnami/wordpress/wp-content/themes

    # Copy a theme to production
    taito exec:wordpress:prod rm -rf /bitnami/wordpress/wp-content/themes/mytheme
    taito copy to:wordpress:prod ./wordpress/data/wordpress/wp-content/mytheme /bitnami/wordpress/wp-content/themes

    # Migrate some database data from staging to production
    taito db dump:stag ./stag-dump.sql
    taito db dump:prod ./prod-dump.sql
    ...modify files...
    taito db import:prod ./imports.sql
    taito db connect:prod

    # Access storage buckets
    taito open storage:stag
    taito open storage:prod
```

TODO: Automcatic migrations between environments.
TODO: Command for copying all data from production to staging.

## Version control

You can manage environment and feature branches using taito-cli. Some examples:

    taito vc env list                # List all environment branches
    taito vc env: dev                # Switch to the dev environment branch
    taito vc env merge               # Merge the current environment branch to the next environment branch

    taito vc feat list               # List all feature branches
    taito vc feat: pricing           # Switch to the pricing feature branch
    taito vc feat rebase             # Rebase current feature branch with dev branch
    taito vc feat merge              # Merge current feature branch to the dev branch, optionally rebase first
    taito vc feat squash             # Merge current feature branch to the dev as a single commit
    taito vc feat pr                 # Create a pull-request for merging current feature branch to the dev branch

> Alternatively you can use git commands directly. Just remember that merge between environment branches should always be executed as fast-forward.

### Development branches

Development is executed mainly in dev branch. You can also use feature branches if you synchronize your work with other developers so that there wont be any nasty conflicts with `database/init/init.sql` and `wordpress/data/*`.

### Commit messages

All commit messages must be structured according to the [Conventional Commits](http://conventionalcommits.org/) convention as application version number and release notes are generated automatically during release by the [semantic-release](https://github.com/semantic-release/semantic-release) library. Commit messages are automatically validated before commit. You can also edit autogenerated release notes afterwards in GitHub (e.g. to combine some commits and clean up comments). Couple of commit message examples:

```
feat(dashboard): Added news on the dashboard.
```

```
docs: Added news on the dashboard.

[skip ci]
```

```
fix(login): Fixed header alignment.

Problem persists with IE9, but IE9 is no longer supported.

Closes #87, #76
```

```
feat(ux): New look and feel

BREAKING CHANGE: Not really breaking anything, but it's a good time to
increase the major version number.
```

Meanings:
* Closes #xx, #xx: Closes issues
* Issues #xx, #xx: References issues
* BREAKING CHANGE: Introduces a breaking change that causes major version number to be increased in the next production release.
* [skip ci]: Skips continuous integration build when the commit is pushed.

You can use any of the following types in your commit message. Use at least types `fix` and `feat`.

* `wip`: Work-in-progress (small commits that will be squashed later to one larger commit before merging them to one of the environment branches)
* `feat`: A new feature
* `fix`: A bug fix
* `docs`: Documentation only changes
* `style`: Code formatting
* `refactor`: Refactoring
* `perf`: Performance tuning
* `test`: Implementing missing tests or correcting existing ones
* `revert`: Revert previous commit.
* `build`: Build system changes
* `ci`: Continuous integration changes (cloudbuild.yaml)
* `chore`: maintenance

> Optionally you can use `npm run commit` to write your commit messages by using commitizen, though often it is quicker to write commit messages by hand.

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

Creating a new server environment:

* Only for production environment: Configure correct IP on DNS record.
* Only for production environment: Configure app url in `taito-config.sh` and hostname in `scripts/wordpress/helm-prod.yaml` file. (TODO: taito-config.sh should suffice)
* Run `taito env apply:ENV` to create an environment. Use the same basic auth credentials for all environments. Basic auth credentials don't have to be strong, but still do not reuse the same password for multiple projects. Update the basic auth username/password to the `package.json` file and to the beginning of this `README.md`, if they are not up-to-date.
* Deploy wordpress to the environment either by pushing some changes to the environment branch or by triggering the deployment manually: `taito deployment trigger:ENV`.
* Immediately generate a new password for the admin user by using the WordPress admin GUI (`taito open admin:ENV`). The initial admin password is: `initial-password-change-it-on-wp-admin-immediately`. If the admin account is shared, save the new password to a shared password manager. And never use the same admin password for every environment, as dev database is committed to git.
* Install one of the following plugins. Note that bucket and service account was already created by Terraform so you should configure plugin settings manually. You can open the bucket by running `taito open storage:ENV`.
  * [wp-stateless](https://wordpress.org/plugins/wp-stateless/) for Google Cloud. Settings: mode=`Stateless`, bucket=`wordpress-template-ENV`, bucket folder=`/media`, create a JSON key for `wordpress-template-ENV` service account from gcloud console (`taito open project:ENV` -> APIs & Services -> Credentials -> Create service account key).
  * [https://github.com/humanmade/S3-Uploads](S3-Uploads) for AWS.
* Delete service account keys from your local disk that were created in the previous step.
* If the staging database does not contain any condifidential data, add the staging database password to `docker-compose.yaml` for development purposes.

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
