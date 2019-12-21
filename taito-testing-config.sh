#!/usr/bin/env bash
# shellcheck disable=SC2034
# shellcheck disable=SC2154

##########################################################################
# Testing settings
#
# NOTE: Variables are passed to the tests without the test_TARGET_ prefix.
##########################################################################

# Environment specific settings
case $taito_env in
  local)
    # local environment
    ci_test_base_url=http://wordpress-template-ingress:80
    ;;
  *)
    # dev and feature environments
    if [[ $taito_env == "dev" ]] || [[ $taito_env == "f-"* ]]; then
      ci_exec_test=false        # enable this to execute test suites
      ci_exec_test_init=false   # run 'init --clean' before each test suite
      ci_test_base_url=https://username:secretpassword@$taito_domain
    fi
    ;;
esac
