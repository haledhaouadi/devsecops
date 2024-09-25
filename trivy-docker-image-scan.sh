#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

# Increase timeout to 300 seconds (5 minutes)
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light --timeout 300s $dockerImageName

# Retry up to 3 times if the scan fails
for i in {1..3}; do
    docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light --timeout 300s $dockerImageName
    exit_code=$?
    if [[ "${exit_code}" == 0 ]]; then
        echo "Image scanning passed. No CRITICAL vulnerabilities found"
        exit 0
    fi
done

echo "Image scanning failed. Vulnerabilities found"
exit 1
