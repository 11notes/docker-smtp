# :: QEMU
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM rust as build
  ENV BUILD_VERSION=v0.6.0
  ENV BUILD_DIR=/smtp-server
  ENV BUILD_ARCH=aarch64-unknown-linux-musl
  ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc
  ENV CC=aarch64-linux-gnu-gcc

  RUN set -ex; \
    apt update; \
    apt upgrade -y; \
    apt install -y \
      g++-aarch64-linux-gnu \
      libc6-dev-arm64-cross; \
    rustup target add ${BUILD_ARCH}; \
    git clone https://github.com/stalwartlabs/smtp-server.git; \
    cd ${BUILD_DIR}; \
    git checkout ${BUILD_VERSION}; \
    git submodule init; \
    git submodule update; \
    wget -q -O - https://musl.cc/aarch64-linux-musl-cross.tgz | tar -zxf -; \
    cd aarch64-linux-musl-cross; \
    rm -f $(find . -name "ld-musl-*.so.1"); \
    rm usr; \
    cp -R ./bin/* /bin; \
    cp -R ./lib/* /lib; \
    cd ..; \
    sed -i 's/"redis", "postgres", "mysql", "sqlite"/"redis", "postgres"/' Cargo.toml;
  
  RUN set -ex; \
    cd ${BUILD_DIR}; \
    cargo build --target ${BUILD_ARCH} --manifest-path=Cargo.toml --release;

  RUN set -ex; \
    mv /smtp-server/target/${BUILD_ARCH}/release/stalwart-smtp /usr/local/bin;
    
# :: Header
  FROM 11notes/alpine:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /usr/local/bin/stalwart-smtp /usr/local/bin
  ENV APP_NAME="stalwart-smtp"
  ENV APP_ROOT=/smtp

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var \
      mkdir -p ${APP_ROOT}/log; \
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
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/log", "${APP_ROOT}/ssl"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]