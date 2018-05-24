/*
# TODO execute the same steps that are defined in cloudbuild.yaml:

# Set environment variables
export taito_mode="ci"
export COMMIT_SHA="NOTE: get git commit sha from jenkins environment"
export BRANCH_NAME="NOTE: get git branch name from jenkins environment"

# Some preparations
taito ci-prepare:wordpress:$BRANCH_NAME $COMMIT_SHA ${taito_registry}
taito install:$BRANCH_NAME

# Prepare release notes and version tag
taito ci-release-pre:$BRANCH_NAME

# Build and push container images
taito ci-build:wordpress:$BRANCH_NAME $COMMIT_SHA ${taito_registry}
taito ci-push:wordpress:$BRANCH_NAME $COMMIT_SHA ${taito_registry}

# Deploy changes to server
taito db-deploy:$BRANCH_NAME
taito ci-deploy:$BRANCH_NAME $COMMIT_SHA

# Publish release notes and version tag
taito ci-release-post:$BRANCH_NAME
*/
