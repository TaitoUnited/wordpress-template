#!/bin/bash
# shellcheck disable=SC2034

##########################################################################
# Integration and end-to-end test parameters
# NOTE: Variables are passed to the tests without the test_TARGET_ prefix.
##########################################################################

# Environment specific settings
case $taito_env in
  local)
    # local environment
    ci_test_base_url=http://website-template-ingress:80
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
