#-------------------------------------------------------------------------------
# Base Image Spec
#-------------------------------------------------------------------------------
ARG BASE_IMAGE=php
ARG BASE_IMAGE_TAG=7.2-alpine
ARG BASE_IMAGE_NAMESPACE=

FROM ${BASE_IMAGE_NAMESPACE}${BASE_IMAGE}:${BASE_IMAGE_TAG} as builder

#-------------------------------------------------------------------------------
# Build Environment
#-------------------------------------------------------------------------------
COPY ./build/pre-build /usr/bin/cross-build-start
RUN [ "cross-build-start" ]

#-------------------------------------------------------------------------------
# Custom Setup
#-------------------------------------------------------------------------------

RUN apk add --no-cache mosquitto-dev git autoconf g++ make

RUN git clone https://github.com/mgdm/Mosquitto-PHP.git /mosquittophp

WORKDIR /mosquittophp

RUN phpize
RUN ./configure --with-mosquitto=/usr/lib
RUN make

#-------------------------------------------------------------------------------
# Post Build Environment
#-------------------------------------------------------------------------------
COPY ./build/post-build /usr/bin/cross-build-end
RUN [ "cross-build-end" ]

#
# -------
#
FROM ${BASE_IMAGE_NAMESPACE}${BASE_IMAGE}:${BASE_IMAGE_TAG}

#-------------------------------------------------------------------------------
# Build Environment
#-------------------------------------------------------------------------------
COPY ./build/pre-build /usr/bin/cross-build-start
RUN [ "cross-build-start" ]

#-------------------------------------------------------------------------------
# Custom Setup
#-------------------------------------------------------------------------------

COPY --from=builder /mosquittophp/modules/mosquitto.so /usr/local/lib/php/extensions/no-debug-non-zts-20170718/mosquitto.so

RUN apk add --no-cache mosquitto-dev

COPY image_files /

ENTRYPOINT ["/usr/local/bin/php"]

CMD ["/mosq.php"]

#-------------------------------------------------------------------------------
# Post Build Environment
#-------------------------------------------------------------------------------
COPY ./build/post-build /usr/bin/cross-build-end
RUN [ "cross-build-end" ]

#-------------------------------------------------------------------------------
# Labelling
#-------------------------------------------------------------------------------

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL de.5square.build-date=$BUILD_DATE \
      de.5square.name="homesmarthome/php-mosquitto" \
      de.5square.description="Multiarch (amd64 and arm) Docker image with PHP 7.2 and Mosquitto." \
      de.5square.url="5square.de" \
      de.5square.vcs-ref=$VCS_REF \
      de.5square.vcs-url="$VCS_URL" \
      de.5square.vendor="5square" \
      de.5square.version=$VERSION \
      de.5square.schema-version="1.0"