#!/bin/bash
TRIVY_VERSION=0.19.1
KUBECTL_VERSION=1.21.0

apk add --update curl

wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
tar zxvf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
mv trivy /usr/local/bin

wget https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl