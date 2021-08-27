FROM alpine

RUN apk add --update jq

RUN adduser -D -g '' -u 1002 image-scanner
WORKDIR /radix-image-scanner

COPY install_tools.sh /radix-image-scanner/install_tools.sh
RUN chmod +x /radix-image-scanner/install_tools.sh

RUN sh /radix-image-scanner/install_tools.sh

COPY scan_image.sh /radix-image-scanner/scan_image.sh
RUN chmod +x /radix-image-scanner/scan_image.sh

ENV SNYK_TOKEN=

USER 1002
CMD sh /radix-image-scanner/scan_image.sh
