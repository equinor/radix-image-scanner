#!/bin/bash

if [ -z "$OUTPUT_CONFIGMAP_NAME" ]; then
  echo "Missing value for variable OUTPUT_CONFIGMAP_NAME"
  exit 1
fi

if [ -z "$OUTPUT_CONFIGMAP_NAMESPACE" ]; then
  echo "Missing value for variable OUTPUT_CONFIGMAP_NAMESPACE"
  exit 1
fi

if [ -z "$VULNERABILITY_LIST_KEY" ]; then
  echo "Missing value for variable VULNERABILITY_LIST_KEY"
  exit 1
fi

if [ -z "$VULNERABILITY_COUNT_KEY" ]; then
  echo "Missing value for variable VULNERABILITY_COUNT_KEY"
  exit 1
fi

if test -f "${AZURE_CREDENTIALS}"; then
  if [[ -z "${TRIVY_USERNAME}" ]]; then
    TRIVY_USERNAME=$(cat ${AZURE_CREDENTIALS} | jq -r '.id')
  fi

  if [[ -z "${TRIVY_PASSWORD}" ]]; then
    TRIVY_PASSWORD=$(cat ${AZURE_CREDENTIALS} | jq -r '.password')
  fi
fi

mkdir /home/image-scanner/scan

# TRIVY_NEW_JSON_SCHEMA: https://github.com/aquasecurity/trivy/discussions/1050
TRIVY_NEW_JSON_SCHEMA=true trivy -q i -f json --timeout 20m  ${IMAGE_PATH} |
  jq '[.Results[] | .Target as $target | .Vulnerabilities | .[]? | {packageName: .PkgName, version: .InstalledVersion, target: $target, description: .Description, severity: .Severity, publishedDate: .PublishedDate, cwe: .CweIDs, cve: [.VulnerabilityID], cvss: .CVSS["nvd"].V3Score, references: .References}]' \
  > /home/image-scanner/scan/vulnerabilities.json

if [ $? -eq 0 ]; then
  jq 'group_by(.severity | ascii_downcase) | [.[] | {severity: .[0].severity | ascii_downcase, count: length}] | [.[] | {(.severity):.count}] | add | if . == null then {} else . end' /home/image-scanner/scan/vulnerabilities.json \
  > /home/image-scanner/scan/aggregate.json

  kubectl create configmap ${OUTPUT_CONFIGMAP_NAME} -n ${OUTPUT_CONFIGMAP_NAMESPACE} \
  --from-file="$VULNERABILITY_LIST_KEY"=/home/image-scanner/scan/vulnerabilities.json \
  --from-file="$VULNERABILITY_COUNT_KEY"=/home/image-scanner/scan/aggregate.json 
else
  kubectl create configmap ${OUTPUT_CONFIGMAP_NAME} -n ${OUTPUT_CONFIGMAP_NAMESPACE}
fi

exit 0

