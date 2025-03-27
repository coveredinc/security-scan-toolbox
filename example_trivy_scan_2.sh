#!/bin/bash
docker run --rm -it -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"/project" \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox trivy image security-toolbox  --compliance "docker-cis-1.6.0" --format table