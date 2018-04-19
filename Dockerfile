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

#RUN apk add --no-cache php7 php7-openssl php7-json php7-phar php7-iconv
RUN apk add --no-cache mosquitto-dev git

RUN https://github.com/mgdm/Mosquitto-PHP.git /mosquittophp

WORKDIR /mosquittophp

RUN phpize
RUN ./configure --with-mosquitto=/path/to/libmosquitto
RUN make
RUN make install

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

#RUN apk add --no-cache php7 php7-openssl php7-json libevent

COPY --from=builder /app /app

COPY image_files /

ENTRYPOINT ["/usr/local/bin/php"]

CMD ["/app/homeconnect.php"]

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
LABEL de.5square.homesmarthome.build-date=$BUILD_DATE \
      de.5square.homesmarthome.name="homesmarthome/amazonecho_shuttle" \
      de.5square.homesmarthome.description="Shuttle service for amazon echo mqtt bridge" \
      de.5square.homesmarthome.url="homesmarthome.5square.de" \
      de.5square.homesmarthome.vcs-ref=$VCS_REF \
      de.5square.homesmarthome.vcs-url="$VCS_URL" \
      de.5square.homesmarthome.vendor="5square" \
      de.5square.homesmarthome.version=$VERSION \
      de.5square.homesmarthome.schema-version="1.0"