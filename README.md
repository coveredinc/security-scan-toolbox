# security-scan-toolbox

**security-scan-toolbox** is a Docker image that packages multiple security scanning tools into a single, easy-to-use container. The recommended scans generally all align with Stride requirements, although there are additional scans available as well.

---

## Purpose

The dispatcher in this image abstracts the invocation of various scanning tools. Instead of managing multiple containers or commands, you can run a single container that hosts several security tools. This setup ensures:
- **Consistent Environment:** Your AWS configurations, Docker socket, and project files are mounted inside the container.
- **Extensibility:** Additional scanners can be integrated later without changing your overall workflow.

---

## Building the Container Locally

To build the `security-scan-toolbox` Docker image locally, follow these steps:

1. Clone the repository:
  ```sh
  git clone git@github.com:coveredinc/security-scan-toolbox.git
  cd security-scan-toolbox
  ```

2. Build the Docker image:
  ```sh
  docker build -t security-toolbox .
  ```

3. Verify the image was built successfully:
  ```sh
  docker images | grep security-toolbox
  ```

This will create a local Docker image named `security-toolbox` that you can use for scanning.

## Prebuilt Image Availability

The `security-scan-toolbox` Docker image is also available as a prebuilt image hosted on Amazon ECR. You can pull it using the following command:

```sh
docker pull 025748181824.dkr.ecr.us-west-2.amazonaws.com/appsec/inspector-scanner:latest
```

This allows you to skip the local build process and use the latest version directly.

### Important Note on Container Naming

For the prebuilt scripts to function correctly, the Docker image must be named `security-toolbox`. Whether you build the image locally or pull it from the prebuilt repository, ensure the image is tagged as `security-toolbox`. 

To rename the image after pulling, use the following command:

```sh
docker tag 025748181824.dkr.ecr.us-west-2.amazonaws.com/prod-security-scan-toolbox-ecr:latest security-toolbox
```

This ensures compatibility with the provided scripts and examples.

## Usage Instructions

Refer to the example scripts provided in the repository for examples. These scripts demonstrate how to use the various tools included in the `security-scan-toolbox`.

Alternatively, users can run the `ez_run` script, which provides an interactive, step-by-step guide to help them through the scanning process. This script simplifies the workflow and ensures all necessary configurations are correctly set up.


### Explanation of Configurable Parts

- `-v ~/.aws/:/root/.aws/:ro`: Mounts your local AWS configuration (credentials and config files) into the container at `/root/.aws`. Ensure your AWS credentials reside in `~/.aws/`.
- `-v /var/run/docker.sock:/var/run/docker.sock`: Grants the container access to the Docker daemon on your host.
- `-v "$PWD":/project`: Mounts the current working directory into `/project` inside the container, allowing scanners to read local files.
- `-e AWS_PROFILE=<your-aws-profile>`: Specifies the AWS profile to use. Replace `<your-aws-profile>` with the desired profile name.
- `-e HOME=/root`: Sets the home directory in the container so that tools correctly locate your AWS config and SSO cache.
- `-e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache`: Specifies the location of the cached SSO token, ensuring AWS SSO authentication works properly.

---

## Supported Tools

Within the toolbox, you can currently use the following security scanners:

### inspector-sbomgen
- **Purpose:** Scans container images using AWS Inspector to generate a Software Bill of Materials (SBOM) and identify vulnerable packages against the AWS database.


### trivy
- **Purpose:** Uses the open-source Trivy tool to scan a Docker image for known vulnerabilities.
- **Example Command:**


## Outputs
- **inspector-sbomgen:** The scan output is saved to `scan.json` in your current directory.
- **trivy:** Scan results are displayed in the console.

---

## Extending the Toolbox

The design of `security-scan-toolbox` is modular. To add new scanners:
- Integrate the new tool into the container.
- Update the dispatcher binary to recognize the new command.
- Document the usage in this README.


## Permissions for Inspector Scans

To run AWS Inspector scans, ensure the following permissions are granted to your AWS profile:

- **Amazon Inspector Permissions:**
  - `inspector-scan:ScanSbom`

- **ECR Permissions (if scanning images in Amazon ECR):**
  - `ecr:DescribeRepositories`
  - `ecr:ListImages`
  - `ecr:BatchGetImage`
  - `ecr:GetAuthorizationToken`

Ensure your AWS profile is configured with these permissions to successfully perform Inspector scans.

---

## Note

Ensure you have the necessary permissions to access the Docker socket and AWS credentials. For AWS SSO profiles, run `aws sso login --profile <your-aws-profile>` before scanning.

---