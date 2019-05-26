# NOTE: This is a quick example that has not yet been tested at all.
# Here we run the same CI/CD steps that are defined also in
# bitbucket-pipelines.yml, cloudbuild.yaml, and build.sh.

workflow "Build, deploy, test, publish" {
  on = "push"
  resolves = ["build-release"]
}

# Prepare build

action "build-prepare" {
  uses = "docker://$template_default_taito_image"
  runs = ["bash", "-c", "taito build prepare:${GITHUB_REF#refs/heads/}"]
  env = {
    taito_mode = "ci"
  }
}

# Prepare artifacts in parallel

action "artifact-prepare:wordpress" {
  needs = "build-prepare"
  uses = "docker://$template_default_taito_image"
  runs = [
    "bash", "-c",
    "taito artifact prepare:wordpress:${GITHUB_REF#refs/heads/} $GITHUB_SHA"
  ]
  env = {
    taito_mode = "ci"
  }
}

# Update wordpress plugins

action "wp-plugin-update" {
  uses = "docker://$template_default_taito_image"
  runs = ["bash", "-c", "taito wp plugin update:${GITHUB_REF#refs/heads/} || echo WARNING: Failed updating wordpress plugins"]
  env = {
    taito_mode = "ci"
  }
}

# Deploy

action "deployment-deploy" {
  uses = "docker://$template_default_taito_image"
  runs = ["bash", "-c", "taito deployment deploy:${GITHUB_REF#refs/heads/} $GITHUB_SHA"]
  env = {
    taito_mode = "ci"
  }
}

# Release artifacts

action "artifact-release:wordpress" {
  needs = "deployment-deploy"
  uses = "docker://$template_default_taito_image"
  runs = [
    "bash", "-c",
    "taito artifact release:wordpress:${GITHUB_REF#refs/heads/} $GITHUB_SHA"
  ]
  env = {
    taito_mode = "ci"
  }
}

# Release build

action "build-release" {
  uses = "docker://$template_default_taito_image"
  runs = [
    "bash", "-c",
    "taito build release:${GITHUB_REF#refs/heads/}"
  ]
  env = {
    taito_mode = "ci"
  }
}
