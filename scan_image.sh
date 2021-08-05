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

if [ -z "$SNYK_TOKEN" ]; then
  echo "Missing value for variable SNYK_TOKEN"
  exit 1
fi

if test -f "${AZURE_CREDENTIALS}"; then
  if [[ -z "${REGISTRY_USERNAME}" ]]; then
    REGISTRY_USERNAME=$(cat ${AZURE_CREDENTIALS} | jq -r '.id')
  fi

  if [[ -z "${REGISTRY_PASSWORD}" ]]; then
    REGISTRY_PASSWORD=$(cat ${AZURE_CREDENTIALS} | jq -r '.password')
  fi
fi

mkdir /home/image-scanner/scan

snyk container test --username=${REGISTRY_USERNAME} --password=${REGISTRY_PASSWORD} --json ${IMAGE_PATH} |
  jq '[.path as $target | .vulnerabilities | .[]? | {packageName: .packageName, version: .version, target: $target, title: .title, description: .description, severity: .severity | ascii_upcase, publishedDate: .publicationTime, cwe: .identifiers.CWE, cve: .identifiers.CVE, cvss: .cvssScore, references: [.references | .[]? | .url]}]' \
  > /home/image-scanner/scan/vulnerabilities.json || exit

jq 'group_by(.severity | ascii_downcase) | [.[] | {severity: .[0].severity | ascii_downcase, count: length}] | [.[] | {(.severity):.count}] | add | if . == null then {} else . end' /home/image-scanner/scan/vulnerabilities.json \
  > /home/image-scanner/scan/aggregate.json || exit


kubectl create configmap ${OUTPUT_CONFIGMAP_NAME} -n ${OUTPUT_CONFIGMAP_NAMESPACE} \
  --from-file="$VULNERABILITY_LIST_KEY"=/home/image-scanner/scan/vulnerabilities.json \
  --from-file="$VULNERABILITY_COUNT_KEY"=/home/image-scanner/scan/aggregate.json

