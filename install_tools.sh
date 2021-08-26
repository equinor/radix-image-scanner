#!/bin/bash
SNYK_VERSION=1.675.0
KUBECTL_VERSION=1.21.0

apk add --update curl

wget https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl

wget https://github.com/snyk/snyk/releases/download/v${SNYK_VERSION}/snyk-alpine
mv snyk-alpine /usr/local/bin
mv /usr/local/bin/snyk-alpine /usr/local/bin/snyk
chmod +x /usr/local/bin/snyk
