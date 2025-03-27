# security-scan-toolbox

**security-scan-toolbox** is a Docker image that packages multiple security scanning tools into a single, easy-to-use container. A built-in dispatcher binary routes your command-line arguments to the appropriate scanner, letting you quickly assess your Docker images for vulnerabilities using your host’s configuration and credentials.

---

## Purpose

The dispatcher in this image abstracts the invocation of various scanning tools. Instead of managing multiple containers or commands, you can run a single container that hosts several security tools. This setup ensures:
- **Consistent Environment:** Your AWS configurations, Docker socket, and project files are mounted inside the container.
- **Simplified Usage:** You only need to remember one base command and specify the desired scanning tool as a parameter.
- **Extensibility:** Additional scanners can be integrated later without changing your overall workflow.

---

## Running the Docker Container

Use the following command to run the container locally. Replace `{command}` with the specific scanner command you want to run.

```sh
docker run --rm -it \
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/project \
  -e AWS_PROFILE=<your-aws-profile> \
  -e HOME=/root \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox {command}
```

### Explanation of Configurable Parts

- `-v ~/.aws/:/root/.aws/:ro`: Mounts your local AWS configuration (credentials and config files) into the container at `/root/.aws`. Ensure your AWS credentials reside in `~/.aws/`.
- `-v /var/run/docker.sock:/var/run/docker.sock`: Grants the container access to the Docker daemon on your host.
- `-v "$PWD":/project`: Mounts the current working directory into `/project` inside the container, allowing scanners to read local files.
- `-e AWS_PROFILE=<your-aws-profile>`: Specifies the AWS profile to use. Replace `<your-aws-profile>` with the desired profile name.
- `-e HOME=/root`: Sets the home directory in the container so that tools correctly locate your AWS config and SSO cache.
- `-e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache`: Specifies the location of the cached SSO token, ensuring AWS SSO authentication works properly.

---

## Supported Tools

Within the toolbox, you can currently run the following security scanners:

### inspector-sbomgen
- **Purpose:** Scans container images using AWS Inspector to generate a Software Bill of Materials (SBOM) and identify vulnerable packages.
- **Example Command:**

```sh
inspector-sbomgen container --image security-toolbox --scan-sbom --scan-sbom-output-format inspector -o scan.json
```

This command:
- Invokes the `inspector-sbomgen` tool.
- Scans the specified Docker image (`security-toolbox`).
- Outputs the scan results in inspector format to `scan.json`.

### trivy
- **Purpose:** Uses the open-source Trivy tool to scan a Docker image for known vulnerabilities.
- **Example Command:**

```sh
trivy image security-toolbox
```

This command scans the `security-toolbox` Docker image for vulnerabilities and outputs the results to your console.

---

## Example Usage

To run an AWS Inspector SBOM scan:

```sh
docker run --rm -it \
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/project \
  -e AWS_PROFILE=audit-admin \
  -e HOME=/root \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox inspector-sbomgen container --image security-toolbox --scan-sbom --scan-sbom-output-format inspector -o scan.json
```

To run a Trivy vulnerability scan:

```sh
docker run --rm -it \
  -v ~/.aws/:/root/.aws/:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/project \
  -e AWS_PROFILE=audit-admin \
  -e HOME=/root \
  -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
  security-toolbox trivy image security-toolbox
```

---

## Output
- **inspector-sbomgen:** The scan output is saved to `scan.json` in your current directory.
- **trivy:** Scan results are displayed in the console.

---

## Extending the Toolbox

The design of `security-scan-toolbox` is modular. To add new scanners:
- Integrate the new tool into the container.
- Update the dispatcher binary to recognize the new command.
- Document the usage in this README.

---

## Note

Ensure you have the necessary permissions to access the Docker socket and AWS credentials. For AWS SSO profiles, run `aws sso login --profile <your-aws-profile>` before scanning.

---

This README is intended to evolve as new tools and features are added. Contributions and updates are welcome!