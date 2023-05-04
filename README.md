[![tests](https://github.com/MurzNN/ddev-grafana/actions/workflows/tests.yml/badge.svg)](https://github.com/MurzNN/ddev-grafana/actions/workflows/tests.yml)
![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-grafana <!-- omit in toc -->

* [What is ddev-grafana?](#what-is-ddev-grafana)
* [Components of the repository](#components-of-the-repository)
* [Getting started](#getting-started)

## What is ddev-grafana?

This repository provides Grafana stack addon to
[DDEV](https://ddev.readthedocs.io).

It contains several components from Grafana stack:

- **[Grafana](https://grafana.com/grafana/)**: an open source analytics and
  interactive visualization web application. It provides charts, graphs, and
  alerts for the web when connected to supported data sources.

- **[Prometheus](https://prometheus.io/)**: an open source monitoring solution
  written in Go that collects metrics data and stores that data in a time series
  database.

- **[Loki](https://grafana.com/logs/)**: a horizontally scalable, highly
  available, multi-tenant log aggregation solution.

- **[Tempo](https://grafana.com/traces/)**: an open source, easy-to-use, and
  high-scale distributed tracing backend.

Be aware that this addon uses a lot of port mapping, so port numbers may overlap
with another running ddev project or local apps, that can lead to startup
errors, and even hidden errors with "503: No ddev back-end site available" if
the same port is configured with HTTP on one project and HTTPS on another, here
is the issue about this: https://github.com/ddev/ddev/issues/4794

To resolve such issues try to find the conflicting port and comment it or change
the port number to a free one.

## Installation

1. In the DDEV project directory launch the command:
```
ddev get MurzNN/ddev-grafana
```
2. Restart the DDEV instance:
```
ddev restart
```
3. Open the Grafana web interface via the url:
   https://your-project-name.ddev.site:3000/

## Customizations

If you need to run several projects with Tempo OpenTelemetry collectors, with
default settings it will fail, because several projects can't use the same port
number on the host network. To fix this you should disable mapping ports to the
host network on the second project via renaming the file
`docker-compose.grafana.host-ports.yaml` to
`docker-compose.grafana.host-ports.yaml.disabled`, or change port numbers to
unique ones, and restart the projects.


If you want to disable binding Grafana services to the localhost, rename the
files:
- `docker-compose.grafana.localhost.yaml` to
  `docker-compose.grafana.namedhosts.yaml.disabled`
- `docker-compose.grafana.namedhosts.yaml.disabled` to
  `docker-compose.grafana.namedhosts.yaml`


If you need to expose non-HTTP ports (gRPC, etc), you can uncomment them in the
`docker-compose.grafana.localhost.yaml` file.


** Contributed and maintained by [@MurzNN](https://github.com/MurzNN).

## Extra

Integration with popular CMSs and frameworks:

- Drupal CMS: [OpenTelemery
  module](https://www.drupal.org/project/opentelemetry)

- Symfony: [OpenTelemetry Symfony
  auto-instrumentation](https://github.com/opentelemetry-php/contrib-auto-symfony)

- Laravel: [Open Telemetry
  package](https://github.com/spatie/laravel-open-telemetry)
