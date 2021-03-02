FROM alpine

RUN apk add --update jq

RUN adduser -D -g '' image-scanner
WORKDIR /home/image-scanner/radix-image-scanner/

COPY install_trivy.sh /home/image-scanner/install_trivy.sh
RUN chmod +x /home/image-scanner/install_trivy.sh

RUN sh /home/image-scanner/install_trivy.sh

COPY scan_image.sh /home/image-scanner/scan_image.sh
RUN chmod +x /home/image-scanner/scan_image.sh

ENV TRIVY_AUTH_URL= \
    TRIVY_USERNAME= \
    TRIVY_PASSWORD=

USER image-scanner
CMD sh /home/image-scanner/scan_image.sh