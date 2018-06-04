# wordpress-template

[//]: # (TEMPLATE NOTE START)

Wordpress-template is a project template for WordPress sites. Create a new project from this template by running `taito template create: wordpress-template`.

TIP: A static site generator combined with a CMS system, git repository and some additional services provides a more secure and care-free alternative for WordPress sites. It also provides a sensible way to do version control, makes a clear distinction between production and development data, and offers a hassle-free way to do automatic migrations between environments. However, such implementation doesn't offer as much plug-and-play functionality as WordPress does. See the [gatsby example](https://github.com/TaitoUnited/server-template-alt/tree/master/client-gatsby) that can be used with the [server-template](https://github.com/TaitoUnited/server-template) if you need also some custom backend functionality.

[//]: # (TEMPLATE NOTE END)

Table of contents:

* [Links](#links)
* [Prerequisites](#prerequisites)
* [Important](#important)
* [Upgrading WordPress](#upgrading-wordpress)
* [Local development](#local-development)
* [Deployment](#deployment)
* [Version control](#version-control)
* [Configuration](#configuration)

## Links

Non-production basic auth credentials: TODO: change `user` / `painipaini`. If the admin account is shared among people, you can find the admin credentials from a shared password manager.

[//]: # (GENERATED LINKS START)

* [Admin user interface (prod)](https://wordpress-template-prod.taitodev.com/admin/)
* [Admin user interface (stag)](https://wordpress-template-stag.taitodev.com/admin/)
* [Application (prod)](https://wordpress-template-prod.taitodev.com)
* [Application (stag)](https://wordpress-template-stag.taitodev.com)
* [Build logs](https://console.cloud.google.com/gcr/builds?project=gcloud-temp1&query=source.repo_source.repo_name%3D%22github-taitounited-wordpress-template%22)
* [GitHub repository](https://github.com/taitounited/wordpress-template)
* [Google project (prod)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-prod)
* [Google project (stag)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-dev)
* [Kanban boards](https://github.com/taitounited/wordpress-template/projects)
* [Logs (prod)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-prod)
* [Logs (stag)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-stag)
* [Project documentation](https://github.com/taitounited/wordpress-template/wiki)
* [Uptime monitoring (Stackdriver)](https://app.google.stackdriver.com/uptime?project=gcloud-temp1)

[//]: # (GENERATED LINKS END)

> You can update this section by configuring links in `taito-config.sh` and running `taito project docs`.

## Prerequisites

* [docker-compose](https://docs.docker.com/compose/install/)
* [node.js](https://nodejs.org/)
* [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)

## Important

It is recommended to do most modifications in local dev environment first. Use the production environment only for making frequent live modifications like creating new blog posts and managing users.

If the production database contains some confidential data like personally identifiable information of customers, you should never take a full database dump of production data for development purposes. Or if you do, data should anonymized carefully. However, if most modifications are made in local development environment and committed to git, there should be no need for production data at all. You can use the staging environment to make sure that the modifications made in local development environment work also with the current production data.

## Upgrading WordPress

Upgrade WordPress version both in `docker-compose.yaml` and in `scripts/heml.yaml`. Push the change to different environment branches. Use the staging environment to check that the upgrade doesn't break anything, before pushing the change to production.

## Local development

> Try to synchronize your work with other developers to avoid conflicts. You can easily overwrite changes of another developer when you push your local database changes to git.

> Support for remote development environment might be coming later (see README_remote.md)

Install some libraries on host (add `--clean` for clean reinstall):

    taito install

    # TODO: gitignored 'wordpress/data' should also be deleted on --clean

Start containers (add `--clean` for clean rebuild and db init using `database/init/*`):

    taito start

Show user accounts and other information that you can use to log in:

    taito info

Open app in browser:

    taito open app

Open admin GUI in browser:

    taito open admin

Access database:

    taito db connect                        # access using a command-line tool
    taito db proxy                          # access using a database GUI tool
    taito db import: ./database/file.sql    # import a sql script to database

Access data:

    # WordPress data is located in `wordpress/data`. Add such files/folders to
    # `wordpress/data/.gitignore` that should not be committed to git.

Save database dump to `database/init/init.sql` before committing changes to git:

    # WARN: Never commit confidential production data to git.
    taito db dump

Start a shell on a container:

    taito shell:wordpress
    taito shell:database

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

## Deployment

Deploying to different environments:

* staging: Merge changes from dev branch to staging branch using fast-forward.
* prod: Merge changes from staging branch to master branch using fast-forward. Version number and release notes are generated automatically by the CI/CD tool.

> You can use taito-cli to [manage environment branches](#version-control).

TODO: Automation for data/db migrations.
TODO: Command for copying data from production to staging.

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

Creating a new server environment:

* For a production environment: Configure correct IP on DNS record.
* For a production environment: Configure app url in `taito-config.sh` and hostname in `scripts/wordpress/helm-prod.yaml` file. (TODO: taito-config.sh should suffice)
* Run `taito env apply:ENV` to create an environment. Use the same basic auth credentials for all environments. Basic auth credentials don't have to be strong, but still do not reuse the same password for multiple projects. Update the basic auth username/password to the `package.json` file and to the beginning of this README, if they are not up-to-date.
* Deploy wordpress to the environment either by pushing some changes to the environment branch or by triggering the deployment manually: `taito deployment trigger:ENV`.
* Immediately generate a new password for the admin user by using the WordPress admin GUI (`taito open admin:ENV`). The initial admin password is: `initial-password-change-it-on-wp-admin-immediately`. If the admin account is shared, save the new password to a shared password manager. And never use the same admin password for every environment, as dev database is committed to git.
* TODO: Connect persistent volume disk to a separate vm dedicated for file access. In development, rsync files also to a storage bucket for easier access?

> Operations on production and staging environments require admin rights, if they contain confidential data. Please contact devops personnel.

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
