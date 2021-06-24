#!/bin/bash
apk add --update curl
VERSION=$(
    curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"v([^"]+)".*/\1/'
)

wget https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz
tar zxvf trivy_${VERSION}_Linux-64bit.tar.gz
mv trivy /usr/local/bin

wget https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl