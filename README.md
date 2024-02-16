![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Stalwart SMTP
![size](https://img.shields.io/docker/image-size/11notes/smtp/0.6.0?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/smtp/0.6.0?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/smtp?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-smtp?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-smtp?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/smtp?color=e6a50e)

**Simple SMTP relay with queues and anti-spam (for edge purposes)**

# SYNOPSIS
What can I do with this? This image will provide you with a simple SMTP relay for ingress at your edge to filter and relay incoming emails.


# VOLUMES
* **/smtp/etc** - Directory of configuration files
* **/smtp/var** - Directory of db, queue, reports and so on

# RUN
```shell
docker run --name smtp \
  -v .../etc:/smtp/etc \
  -v .../var:/smtp/var \
  -d 11notes/smtp:[tag]
```

# EXAMPLES
## config /smtp/etc/config.toml
```toml
[macros]
host = "mail.domain.com"
default_domain = "domain.com"
base_path = "/smtp"
default_directory = "internal"
default_store = "rocksdb"

[include]
files = [ "%{BASE_PATH}%/etc/config.d/server.toml",
          "%{BASE_PATH}%/etc/config.d/directory.toml",
          "%{BASE_PATH}%/etc/config.d/rocksdb.toml",
          "%{BASE_PATH}%/etc/config.d/redis.toml",
          "%{BASE_PATH}%/etc/config.d/storage.toml",
          "%{BASE_PATH}%/etc/config.d/smtp.toml" ]

```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /smtp | home directory of user docker |
| `config` | /smtp/etc/config.toml | config |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/node:stable](https://hub.docker.com/r/11notes/node)

# BUILT WITH
* [stalwart smtp](https://stalw.art/smtp)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    