docker run --rm -it \ 
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"/project" \
  -e AWS_PROFILE=audit-admin \
  -e HOME=/root \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox inspector-sbomgen container \
    --image security-toolbox \
    --scan-sbom \
    --scan-sbom-output-format inspector \
    -o scan.json