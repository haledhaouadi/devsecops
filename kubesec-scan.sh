#!/bin/bash

# kubesec-scan.sh

# Perform the scan once and store the result
scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)

# Check if curl succeeded
if [[ $? -ne 0 ]]; then
    echo "Failed to reach Kubesec API."
    exit 1
fi

# Parse the message and score from the scan result
scan_message=$(echo "$scan_result" | jq .[0].message -r)
scan_score=$(echo "$scan_result" | jq .[0].score)

# Check if jq succeeded in parsing the response
if [[ -z "$scan_score" || "$scan_score" == "null" ]]; then
    echo "Failed to parse scan result. Please check your jq installation or the API response."
    exit 1
fi

# Output the score and message, and handle the scan result
echo "Scan Score: $scan_score"
echo "Kubesec Scan Message: $scan_message"

# Decision logic based on the scan score
if [[ "$scan_score" -ge 5 ]]; then
    echo "Kubernetes Resource passed with score $scan_score"
else
    echo "Score is $scan_score, which is less than or equal to 5."
    echo "Scanning Kubernetes Resource has failed."
    exit 1
fi
