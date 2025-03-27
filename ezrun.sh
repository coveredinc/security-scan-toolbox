#!/bin/bash

# Function to load Docker images into an array without using mapfile
load_images() {
    images=()
    while IFS= read -r line; do
        images+=("$line")
    done < <(docker images --format "{{.Repository}}:{{.Tag}}")
}

# Prompt the user for the type of scan.
echo "Select the type of scan you want to run:"
echo "1) inspector"
echo "2) trivy"
read -p "Enter your choice (1 or 2): " scanChoice

if [ "$scanChoice" == "1" ]; then
    # Inspector scan branch.
    echo "Fetching the most recent 5 Docker images..."
    load_images
    if [ ${#images[@]} -eq 0 ]; then
      echo "No Docker images found."
      exit 1
    fi

    echo "Select an image to scan:"
    count=0
    for image in "${images[@]}"; do
        count=$((count+1))
        echo "$count) $image"
        if [ $count -eq 5 ]; then
            break
        fi
    done

    read -p "Enter the number of the image to scan: " imageChoice
    index=$((imageChoice - 1))
    if [ $index -lt 0 ] || [ $index -ge ${#images[@]} ]; then
        echo "Invalid image selection."
        exit 1
    fi
    chosenImage="${images[$index]}"
    echo "Running inspector scan on image: '$chosenImage'"
    docker run --rm -it \
      -v ~/.aws/:/root/.aws/:ro \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$PWD":/project \
      -e AWS_PROFILE=$AWS_PROFILE \
      -e HOME=/root \
      -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
      security-toolbox inspector-sbomgen container \
      --image "$chosenImage" \
      --scan-sbom \
      --scan-sbom-output-format inspector \
      -o scan.json

elif [ "$scanChoice" == "2" ]; then
    # Trivy scan branch.
    echo "Select trivy scan type:"
    echo "1) repo"
    echo "2) image"
    read -p "Enter your choice (1 or 2): " trivyChoice

    if [ "$trivyChoice" == "1" ]; then
        echo "Running trivy repo scan..."
        docker run --rm -it \
          -v ~/.aws/:/root/.aws/:ro \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v "$PWD":/project \
          -e AWS_PROFILE=$AWS_PROFILE \
          -e HOME=/root \
          -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
          security-toolbox trivy repo ./ --scanners secret,license,misconfig --format table
    elif [ "$trivyChoice" == "2" ]; then
        echo "Fetching the most recent 5 Docker images..."
        load_images
        if [ ${#images[@]} -eq 0 ]; then
            echo "No Docker images found."
            exit 1
        fi

        echo "Select an image to scan:"
        count=0
        for image in "${images[@]}"; do
            count=$((count+1))
            echo "$count) $image"
            if [ $count -eq 5 ]; then
                break
            fi
        done

        read -p "Enter the number of the image to scan: " imageChoice
        index=$((imageChoice - 1))
        if [ $index -lt 0 ] || [ $index -ge ${#images[@]} ]; then
            echo "Invalid image selection."
            exit 1
        fi
        chosenImage="${images[$index]}"
        echo "Running trivy image scan on '$chosenImage'..."
        docker run --rm -it \
          -v ~/.aws/:/root/.aws/:ro \
          -v /var/run/docker.sock:/var/run/docker.sock \
          -v "$PWD":/project \
          -e AWS_SSO_CACHE_DIR=/root/.aws/sso/cache \
          security-toolbox trivy image "$chosenImage" --compliance "docker-cis-1.6.0" --format table
    else
        echo "Invalid trivy scan type selection."
        exit 1
    fi
else
    echo "Invalid scan type selection."
    exit 1
fi