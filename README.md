# wordpress-template

[//]: # (TEMPLATE NOTE START)

Wordpress-template is a project template for WordPress sites. Create a new project from this template by running `taito template create: wordpress-template`.

[//]: # (TEMPLATE NOTE END)

## Links

[//]: # (GENERATED LINKS START)

* [Admin user interface (dev)](https://wordpress-template-dev.taitodev.com/admin/)
* [Admin user interface (prod)](https://wordpress-template-prod.taitodev.com/admin/)
* [Application (dev)](https://wordpress-template-dev.taitodev.com)
* [Application (prod)](https://wordpress-template-prod.taitodev.com)
* [Build logs](https://console.cloud.google.com/gcr/builds?project=gcloud-temp1&query=source.repo_source.repo_name%3D%22github-taitounited-wordpress-template%22)
* [GitHub repository](https://github.com/taitounited/wordpress-template)
* [Google project (dev)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-dev)
* [Google project (prod)](https://console.cloud.google.com/home/dashboard?project=taitounited-companyname-prod)
* [Kanban boards](https://github.com/taitounited/wordpress-template/projects)
* [Logs (dev)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-dev)
* [Logs (prod)](https://console.cloud.google.com/logs/viewer?project=gcloud-temp1&minLogLevel=0&expandAll=false&resource=container%2Fcluster_name%2Fkube1%2Fnamespace_id%2Fwordpress-template-prod)
* [Project documentation](https://github.com/taitounited/wordpress-template/wiki)
* [Storage bucket (dev)](https://console.cloud.google.com/storage/browser/wordpress-template-dev?project=taitounited-companyname-dev)
* [Storage bucket (prod)](https://console.cloud.google.com/storage/browser/wordpress-template-prod?project=taitounited-companyname-prod)
* [Uptime monitoring (Stackdriver)](https://app.google.stackdriver.com/uptime?project=gcloud-temp1)

[//]: # (GENERATED LINKS END)

> You can update this section by configuring links in `taito-config.sh` and running `taito project docs`.

## Prerequisites

* Optional: [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)
* Optional: [docker-compose](https://docs.docker.com/compose/install/)

## Editing the site without taito-cli

It is recommended to do most modifications in dev environment first and use production environment only for making frequent modifications like creating new blog posts and managing users.

Just edit the site and data files using your browser (see links at the beginning of this README.md). Hopefully someone will commit your changes to git and eventually migrate them to production.

## Upgrading WordPress

TODO

## Quick start for remote development

If multiple developers are working on the same site simultaneously using a local development environment, migrating all changes together may be an error-prone process. To mitigate this problem, developers can use a remote development environment that is shared among all developers.

Install git hooks and some libraries on host (add `--clean` for clean reinstall):

    taito install

Open remote admin GUI, data storage and database:

    taito open admin:dev
    taito open storage:dev
    taito info:dev
    taito db connect:dev    # Alternatively: taito db proxy:dev

> If you run into authorization errors, authenticate with the `taito --auth:ENV` command.

> It's common that idle applications are run down to save resources on non-production environments. If your application seems to be down, you can start it by running `taito start:ENV`, or by pushing some changes to git.

Mount remote data storage so that you can make changes directly:

* Run `taito storage mount:dev`
* Modify files located in `./mounts/wordpress-template-dev`

Commit changes made to remote data:

* Warn other developers that you are going to sync the data to git
* Pull latest changes: `git pull --rebase`
* Sync remote data to local disk `taito storage sync to:local dev`
* Commit and push changes

Deploy changes from dev to production:

* Deploy taito and helm configuration changes: `taito vc env merge`
* Migrate files and database manually or by using a migration plugin (support for automation coming later).

Migrate changes from production to dev:

* Migrate files and database manually or by using a migration plugin (support for automation coming later)
* NOTE: You should not migrate/copy the whole database and all the files, if the data contains confidential data like personal accounts, personal photos, contact details, payments or private messaging.

Some additional commands for operating remote environments:

    taito status:dev                        # Show status of dev environment
    taito shell:wordpress:dev               # Start a shell on wordpress container
    taito logs:wordpress:dev                # Tail logs of wordpress container
    taito open logs:dev                     # Open logs on browser
    taito db import:dev ./database/file.sql # Import a file to database
    taito db dump:dev                       # Dump database to a file
    taito db diff:dev prod                  # Show diff between dev and prod schemas
    taito db copy to:dev prod               # Copy prod database to dev

Run `taito -h` to get detailed instructions for all commands. Run `taito COMMAND -h` to show command help (e.g `taito vc -h`, `taito db -h`, `taito db import -h`). For troubleshooting run `taito --trouble`. See PROJECT.md for project specific conventions and documentation.

## Quick start for local development

Install some libraries on host (add `--clean` for clean reinstall):

    taito install

Start containers (add `--clean` for clean rebuild):

    taito start

Initislize local database with a database dump taken from dev:

    taito init

Open app in browser:

    taito open app

Open admin GUI in browser:

    taito open admin

Show user accounts and other information that you can use to log in:

    taito info

Access database:

    taito db connect                        # access using a command-line tool
    taito db proxy                          # access using a database GUI tool
    taito db import: ./database/file.sql    # import a sql script to database

Start a shell on a container:

    taito shell:wordpress

Stop containers:

    taito stop

List all project related links and open one of them in browser:

    taito open -h
    taito open xxx

Cleaning:

    taito clean:wordpress                   # Remove wordpress container image
    taito clean:npm                         # Delete node_modules directories
    taito clean                             # Clean everything

The commands mentioned above work also for server environments (`feature`, `dev`, `test`, `staging`, `prod`). Some examples for dev environment:

    taito open app:dev                      # Open application in browser
    taito open admin:dev                    # Open admin GUI in browser
    taito info:dev                          # Show info
    taito status:dev                        # Show status of dev environment
    taito shell:wordpress:dev               # Start a shell on wordpress container
    taito logs:wordpress:dev                # Tail logs of wordpress container
    taito open logs:dev                     # Open logs on browser
    taito open storage:dev                  # Open storage bucket on browser
    taito db connect:dev                    # Access database on command line
    taito db proxy:dev                      # Start a proxy for database access
    taito db import:dev ./database/file.sql # Import a file to database
    taito db dump:dev                       # Dump database to a file
    taito db diff:dev test                  # Show diff between dev and test schemas
    taito db copy to:dev prod               # Copy prod database to dev

Run `taito -h` to get detailed instructions for all commands. Run `taito COMMAND -h` to show command help (e.g `taito vc -h`, `taito db -h`, `taito db import -h`). For troubleshooting run `taito --trouble`. See PROJECT.md for project specific conventions and documentation.

> If you run into authorization errors, authenticate with the `taito --auth:ENV` command.

> It's common that idle applications are run down to save resources on non-production environments. If your application seems to be down, you can start it by running `taito start:ENV`, or by pushing some changes to git.

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

Development is executed in dev and feature branches. Using feature branches is optional, but they are recommended to be used at least in the following situations:

* **Making changes to existing production functionality**: Use feature branches and pull-requests for code reviews. This will decrease the likelyhood that the change will brake something in production. It is also easier to keep the release log clean by using separate feature branches.
* **A new project team member**: Use pull-requests for code reviews. This way you can help the new developer in getting familiar with the coding conventions and application logic of the project.
* **Teaching a new technology**: Pull-requests can be very useful in teaching best practices for an another developer.

Code reviews are very important at the beginning of a new software project, because this is the time when the basic foundation is built for the future development. At the beginning, however, it is usually more sensible to do occasional code reviews across the entire codebase instead of feature specific code reviews based on pull-requests.

Note that most feature branches should be short-lived and located only on your local git repository, unless you are going to make a pull-request.

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

## Deployment

Deploying to different environments:

* feature: Push to feature branch.
* dev: Push to dev branch.
* test: Merge changes to test branch using fast-forward.
* staging: Merge changes to staging branch using fast-forward.
* prod: Merge changes to master branch using fast-forward. Version number and release notes are generated automatically by the CI/CD tool.

> NOTE: Feature, test and staging branches are optional.

> NOTE: You can use taito-cli to [manage environment branches](#version-control).

> Automatic deployment might be turned off for critical environments (`ci_exec_deploy` setting in `taito-config.sh`). In such case the deployment must be run manually with the `taito -a deployment deploy:prod VERSION` command using an admin account after the CI/CD process has ended successfully.

Advanced features:

* **Copy production data to staging**: Often it's a good idea to copy production database to staging before merging changes to the staging branch: `taito db copy to:staging prod`. If you are sure nobody is using the production database, you can alternatively use the quick copy (`taito db copyquick to:staging prod`), but it disconnects all other users connected to the production database until copying is finished and also requires that both databases are located in the same database cluster.
* **Feature branch**: You can create also an environment for a feature branch: Destroy the old environment first if it exists (`taito env destroy:feature`) and create a new environment for your feature branch (`taito env apply:feature BRANCH`). Currently only one feature environment can exist at a time and therefore the old one needs to be destroyed before the new one is created.

NOTE: Some of the advanced operations might require admin credentials (e.g. staging/production operations). If you don't have an admin account, ask devops personnel to execute the operation for you.

## Configuration

Done:
* [ ] GitHub settings
* [ ] Basic project settings
* [ ] Dev environment
* [ ] Prod environment

### GitHub settings

Recommended settings for most projects.

Options:
* Data services: Allow GitHub to perform read-only analysis: on
* Data services: Vulnerability alerts: on

Branches:
* Default branch: dev
* Protected branch: master (TODO more protection settings)

Collaborators & teams:
* Teams: Select admin permission for the Admins team
* Teams: Select write permission for the Developers team
* Collaborators: Add additional collaborators if required.
* Collaborators: Remove repository creator (= yourself) from the collaborator list (NOTE: do this last!)

### Basic project settings

1. Configure `taito-config.sh` if you need to change some settings. The default settings are ok for most projects.
2. Run `taito project apply`
3. Commit and push changes

### Server environments

Creating a new server environment:

* Run `taito env apply:ENV` to create an environment for `dev` or `prod`.
* Deploy wordpress to the environment either by pushing changes to the correct branch or by triggering the deployment manually: `taito deployment trigger:ENV`.
* Immediately generate a new password for the admin user by using the WordPress admin GUI (`taito open admin:ENV`). The default password is: `initial-password-change-it-on-wp-admin-immediately`. If it's a non-production environment, you can write the new admin username/password to info:ENV script of `package.json` file.
* For a non-production environment: Protect the environment from web crawlers by installing and activating the [HTTP Auth](https://wordpress.org/plugins/http-auth/) plugin for the `Complete Site`. Write the basic auth username/password to info:ENV script of `package.json` file.

> All operations on production and staging environments require admin rights. Please contact devops personnel.

#### Kubernetes

TODO

#### Secrets

1. Add a secret definition to `taito-config.sh` (taito_secrets)
2. Map secret to an environment variable in `scripts/helm.yaml`
3. Run `taito env rotate:ENV [SECRET]` to generate a secret value for an environment. Run the command for each environment separately. Note that the rotate command restarts all pods in the same namespace.

> For local development you can just define secrets as normal environment variables in `docker-compose.yaml` given that they are not confidential.

### Upgrading to the latest version of the project template

Run `taito template upgrade`. The command copies the latest versions of reusable Helm charts, terraform templates and CI/CD scripts to your project folder, and also this README.md file. You should not make project specific modifications to them as they are designed to be reusable and easily configurable for various needs. Improve the originals instead, and then upgrade.
