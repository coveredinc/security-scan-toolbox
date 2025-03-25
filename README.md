# security-scan-toolbox
A Docker Image which enables different scanning tools to run on Docker through the host.

## Running the Docker Container

To run the Docker container locally, use the following command:

```sh
docker run --rm -it \ 
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"/project" \
  -e AWS_PROFILE=$(AWS_PROFILE) \
  -e HOME=/root \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox inspector-sbomgen container \
    --image security-toolbox \
    --scan-sbom \
    --scan-sbom-output-format inspector \
    -o scan.json
```

### Explanation of Configurable Parts

- `-v ~/.aws/:/root/.aws/:ro`: This volume mounts your local AWS configuration directory to the container's AWS configuration directory. Ensure that your AWS credentials are stored in `~/.aws/`.

- `-v /var/run/docker.sock:/var/run/docker.sock`: This volume mounts the Docker socket, allowing the container to communicate with the Docker daemon on the host machine.

- `-v "$PWD":"/project"`: This volume mounts the current working directory to the `/project` directory inside the container. This allows the container to access the files in your current directory.

- `-e AWS_PROFILE=$(AWS_PROFILE)`: This environment variable sets the AWS profile to use. Replace `$(AWS_PROFILE)` with the name of the AWS profile you want to use.

- `-e HOME=/root`: This environment variable sets the home directory inside the container.

- `-e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache`: This environment variable sets the AWS SSO cache directory inside the container.

- `security-toolbox inspector-sbomgen container --image security-toolbox --scan-sbom --scan-sbom-output-format inspector -o scan.json`: This command runs the `inspector-sbomgen` tool inside the container, scanning the specified Docker image and outputting the results to `scan.json`.

### Output

The output of the scan will be saved to `scan.json` in the current working directory.

### Note

Ensure that you have the necessary permissions to access the Docker socket and AWS credentials.