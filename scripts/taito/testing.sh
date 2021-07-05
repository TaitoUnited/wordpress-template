#!/usr/bin/env bash
# shellcheck disable=SC2034
# shellcheck disable=SC2154

##########################################################################
# Testing settings
#
# NOTE: Variables are passed to the tests without the test_TARGET_ prefix.
##########################################################################

# Enable CI/CD tests only for dev and feature environments
if [[ $taito_target_env == "dev" ]] || [[ $taito_target_env == "f-"* ]]; then
  ci_exec_test=false             # enable this to execute test suites
  ci_exec_test_init=false        # enable to run 'init --clean' before each test suite
  ci_exec_test_init_after=false  # enable to run 'init --clean' after all tests
fi

# Environment specific settings
test_all_TEST_ENV=$taito_target_env
if [[ $taito_target_env == "local" ]]; then
  test_all_TEST_ENV_REMOTE=false
  ci_test_base_url=http://wordpress-template-ingress:80
else
  test_all_TEST_ENV_REMOTE=true
  if [[ $taito_command == "util-test" ]]; then
    # Constitute test url by combining basic auth secret and domain name
    ci_test_base_url=https://$(cat tmp/secrets/${taito_env}/${taito_project}-${taito_env}-basic-auth.auth | sed 's/:{PLAIN}/:/')@$taito_domain
  fi
fi

# URLs for tests
test_wordpress_TEST_URL=$ci_test_base_url
