# TODO

## Links

* [Storage bucket (dev)](https://console.cloud.google.com/storage/browser/wordpress-template-dev?project=taitounited-companyname-dev)
* [Storage bucket (prod)](https://console.cloud.google.com/storage/browser/wordpress-template-prod?project=taitounited-companyname-prod)

## Prerequisites

* Optional: [taito-cli](https://github.com/TaitoUnited/taito-cli#readme)
* Optional: [docker-compose](https://docs.docker.com/compose/install/)

## Editing the site

It is recommended to do most modifications in dev environment first and use the production environment only for making frequent modifications like creating new blog posts and managing users.

Edit the site with the WordPress Admin GUI (see the links at the beginning of this README). You can also modify WordPress data files located in the storage bucket by using your browser. Ask someone to commit your changes to git and to migrate them to production, if you cannot do it yourself.

> TODO Or edit files with an WordPress plugin?

## Upgrading WordPress

CI/CD trigger deploys the latest WordPress version by default:

* Upgrade WordPress in dev: `taito deployment trigger:dev`
* Check that everything seems ok.
* Upgrade WordPress in prod: `taito deployment trigger:prod`

TODO automatic upgrade process: check for new versions, upgrade all non-production wordpresses, send notifications about the upgrade, wait for a few days, upgrade all production wordpresses.

## Remote development

If multiple developers are working on the same site simultaneously using a local development environment, migrating all changes together may be an error-prone process. To mitigate this problem, developers can use a remote development environment that is shared among all developers.

Install git hooks and some libraries on host (add `--clean` for clean reinstall):

    taito install

Open the WordPress site, the admin GUI and the storage bucket:

    taito info:dev
    taito open app:dev
    taito open admin:dev
    taito open storage:dev

> It's common that idle applications are run down to save resources on non-production environments. If your application seems to be down, you can start it by running `taito start:ENV`, or by pushing some changes to git.

> If you run into authorization errors, authenticate with the `taito --auth:ENV` command.

Mount remote storage bucket to your local disk so that you can make changes to remote files directly (FOR LINUX ONLY):

* Run `taito storage mount:dev`
* Modify files located in `./mnt/wordpress-template-dev`

Sync data/files from local disk to the remote storage bucket:

* Warn other developers that you are going to sync the data from git
* Sync data/files to the remote bucket `taito sync to:dev`. The command retrieves latest changes from git before sync and it does not sync user accounts or other confidential data.

Sync data/files located in remote storage bucket to local disk and git:

* Warn other developers that you are going to sync the data to git
* Sync data and files from the remote dev environment to your local disk: `taito sync from:dev`. The command retrieves latest changes from git before sync. The command does not sync user accounts or other confidential data.
* Add such directories/files to `.gitignore` that should not be committed to git.
* Commit and push changes to git

Migrate changes from dev to production:

* Deploy taito-cli and Kubernetes configuration changes: `taito vc env merge`
* Migrate storage bucket files and database changes either manually or by using a WordPress migration plugin (TODO support for automation coming later). NOTE: You should not migrate/copy the whole database and all the files, if they contain development data or development user accounts.

Migrate changes from production to dev:

* Migrate storage bucket files and database changes either manually or by using a WordPress migration plugin (TODO support for automation coming later). NOTE: You should not migrate/copy the whole database and all the files, if they contain confidential data like personal user accounts, personal photos, contact details, payments or private messaging.

Some additional commands for operating remote environments:

    taito status:dev                        # Show status of dev environment
    taito shell:wordpress:dev               # Start a shell on wordpress container
    taito logs:wordpress:dev                # Tail logs of wordpress container
    taito open logs:dev                     # Open logs on browser
    taito db connect:dev                    # Connect to database from command-line
    taito db proxy:dev                      # Start a proxy for connecting database with a GUI tool
    taito db import:dev ./database/file.sql # Import a file to database
    taito db dump:dev                       # Dump database to a file
    taito db diff:dev prod                  # Show diff between dev and prod db schemas
    taito db copy to:dev prod               # Copy prod database to dev

Run `taito -h` to get detailed instructions for all commands. Run `taito COMMAND -h` to show command help (e.g `taito vc -h`, `taito db -h`, `taito db import -h`). For troubleshooting run `taito --trouble`. See PROJECT.md for project specific conventions and documentation.
