# diskfree_healthcheck

This is a small docker service that checks all locally-mounted disks (including network drivers). If a given disk usage threshold is exceeded, an error message is output for every affected mount. Optionally, the errors are reported to a [Healthchecks](https://healthchecks.io/) instance.

## Usage

### Docker Compose

```yaml
services:
  app:
    image: perspectivedaily/diskfree_healthcheck:0.1.0
    hostname: HOSTNAME
    environment:
      - SLEEP_TIME=3600
      - THRESHOLD=90
      #- HEALTHCHECK_URL=https://healthchecks.example.com/ping/slug/free_disk_{{HOSTNAME}}
    volumes:
      - /:/mnt/host:ro
```

Replace `HOSTNAME` with the docker host's hostname.

### Docker Swarm Mode

```yaml
services:
  app:
    image: perspectivedaily/diskfree_healthcheck:0.1.0
    hostname: "{{.Node.ID}}"
    environment:
      - SLEEP_TIME=3600
      - THRESHOLD=90
      #- HEALTHCHECK_URL=https://healthchecks.example.com/ping/slug/free_disk_{{HOSTNAME}}
    volumes:
      - /:/mnt/host:ro
```

### Options

* `SLEEP_TIME` is the time to wait between checks, in seconds
* `THRESHOLD` is the percent threshold. If any disk usage percentage is >= `THRESHOLD`, it is reported as an error.
* `HEALTHCHECK_URL` is a ping url from a [Healthchecks](https://healthchecks.io/) instance. If the disk usage threshold is exceeded on any mount, the `/fail` hook is called with the error messages. Otherwise, the success hook is called.
