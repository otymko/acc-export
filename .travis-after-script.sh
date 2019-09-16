#!/bin/bash
set -e
version='1.2.1'

if [ "$TRAVIS_SECURE_ENV_VARS" == "true" ]; then
  sonar-scanner \
      -Dsonar.host.url=$SONAR_HOST \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.projectVersion=$version\
      -Dsonar.scanner.skip=false
fi