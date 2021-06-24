FROM alpine

RUN apk add --update jq

RUN adduser -D -g '' image-scanner
WORKDIR /radix-image-scanner

COPY install_tools.sh /radix-image-scanner/install_tools.sh
RUN chmod +x /radix-image-scanner/install_tools.sh

RUN sh /radix-image-scanner/install_tools.sh

COPY scan_image.sh /radix-image-scanner/scan_image.sh
RUN chmod +x /radix-image-scanner/scan_image.sh

ENV TRIVY_AUTH_URL= \
    TRIVY_USERNAME= \
    TRIVY_PASSWORD= \
    RESULT_CONFIGMAP_NAME= \
    RESULT_CONFIGMAP_NAMESPACE=


USER image-scanner
CMD sh /radix-image-scanner/scan_image.sh