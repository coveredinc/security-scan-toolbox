# Determine the shell configuration file
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG_FILE=~/.zshrc
elif [ -n "$BASH_VERSION" ]; then
  if [ -f ~/.bashrc ]; then
    SHELL_CONFIG_FILE=~/.bashrc
  else
    SHELL_CONFIG_FILE=~/.bash_profile
  fi
else
  echo "Unsupported shell. Alias cannot be added via script."
  exit 1
fi

cat << 'EOF' >> $SHELL_CONFIG_FILE

# Function to run inspector-sbomgen in Docker with --profile flag
function inspector-sbomgen () {
    docker run --rm -it \
      -v ~/.aws/:/root/.aws/:ro \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$PWD":"/project" \
      inspector-sbomgen:latest "${args[@]}"
}
EOF
# Source the shell configuration file to apply the alias
source $SHELL_CONFIG_FILE

# Pull the Docker image from the ECR repository
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 
docker pull 025748181824.dkr.ecr.us-west-2.amazonaws.com/appsec/inspector-scanner:latest

echo "Alias inspector-sbomgen has been added and the Docker image has been pulled. You can now use it to run the Docker command with the normal syntax:
https://docs.aws.amazon.com/inspector/latest/user/cicd-custom.html"
# echo "inspector-sbomgen container --image <image:id> --scan-sbom --aws-profile <profile> --aws-region <region> -o ./scan.json"