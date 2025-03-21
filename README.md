# inspector-sbom-scanner
A Docker Image which allows the inspector sbom scanner binary to run on Docker through the host.

## Running the Docker Container

To run the Docker container locally, use the following command:

```sh
docker run --rm -it \
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"/project" \
  -e AWS_PROFILE={profile} inspector container --image {imagename:tag} --scan-sbom --scan-sbom-output-format inspector -o scan.json
```

### Explanation of Configurable Parts

- `-v ~/.aws/:/root/.aws/:ro`: This volume mounts your local AWS configuration directory to the container's AWS configuration directory. Ensure that your AWS credentials are stored in `~/.aws/`.

- `-v /var/run/docker.sock:/var/run/docker.sock`: This volume mounts the Docker socket, allowing the container to communicate with the Docker daemon on the host machine.

- `-v "$PWD":"/project"`: This volume mounts the current working directory to the `/project` directory inside the container. This allows the container to access the files in your current directory.

- `-e AWS_PROFILE={profile}`: This environment variable sets the AWS profile to use. Replace `{profile}` with the name of the AWS profile you want to use.

- `--image {imagename:tag}`: Replace `{imagename:tag}` with the name and tag of the Docker image you want to use.

### Output

The command will run the inspector sbom scanner with the specified options and output the results to `scan.json` in the current directory.

### Note

The AWS profile and Docker image tag used in the command will depend on who uses the image. Make sure to replace `{profile}` and `{imagename:tag}` with the appropriate values for your environment.


 @see {@link https://docs.aws.amazon.com/inspector/latest/user/cicd-custom.html#call-api|AWS Inspector Documentation} for more information on how to run the command.
 */