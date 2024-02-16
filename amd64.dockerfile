# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM rust:alpine as build
  ENV BUILD_VERSION=v0.6.0
  ENV BUILD_DIR=/smtp-server

  RUN set -ex; \
    apk add --no-cache \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      g++ \
      git; \
    git clone https://github.com/stalwartlabs/smtp-server.git; \
    cd ${BUILD_DIR}; \
    git checkout ${BUILD_VERSION}; \
    git submodule init; \
    git submodule update;
  
  RUN set -ex; \
    cd ${BUILD_DIR}; \
    cargo build --target x86_64-unknown-linux-musl --manifest-path=Cargo.toml --release;
    
# :: Header
  FROM 11notes/alpine:stable
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /smtp-server/target/x86_64-unknown-linux-musl/release/stalwart-smtp /usr/local/bin
  ENV APP_NAME="stalwart-smtp"
  ENV APP_ROOT=/smtp

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/db; \
      mkdir -p ${APP_ROOT}/queue; \
      mkdir -p ${APP_ROOT}/reports; \
      mkdir -p ${APP_ROOT}/ssl; \
      apk --no-cache add \
        openssl; \
      apk --no-cache upgrade;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin;

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/ssl"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]