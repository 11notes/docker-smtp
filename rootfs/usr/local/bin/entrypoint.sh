#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -f "${APP_ROOT}/ssl/default.crt" ]; then
      elevenLogJSON info "default TLS/SSL missing, creating"
      openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=${APP_NAME}" \
        -keyout "${APP_ROOT}/ssl/default.key" \
        -out "${APP_ROOT}/ssl/default.crt" \
        -days 3650 -nodes -sha256 &> /dev/null
    fi

    if [ ! -f "${APP_ROOT}/etc/config.toml" ]; then
      elevenLogJSON error "config ${APP_ROOT}/etc/config.toml missing, please create!"
    else
      elevenLogJSON info "starting stalwart-smtp server"
      set -- "stalwart-smtp" \
        --config ${APP_ROOT}/etc/config.toml
    fi
  fi

  exec "$@"