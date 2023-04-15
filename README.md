[![tests](https://github.com/MurzNN/ddev-grafana/actions/workflows/tests.yml/badge.svg)](https://github.com/MurzNN/ddev-grafana/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-grafana <!-- omit in toc -->

* [What is ddev-grafana?](#what-is-ddev-grafana)
* [Components of the repository](#components-of-the-repository)
* [Getting started](#getting-started)

## What is ddev-grafana?

This repository provides Grafana stack addon to [DDEV](https://ddev.readthedocs.io).

It contains several components from Grafana stack:

- **[Grafana](https://grafana.com/grafana/)**: an open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.

- **[Prometheus](https://prometheus.io/)**: an open source monitoring solution written in Go that collects metrics data and stores that data in a time series database.

- **[Loki](https://grafana.com/logs/)**: a horizontally scalable, highly available, multi-tenant log aggregation solution.

- **[Tempo](https://grafana.com/traces/)**: an open source, easy-to-use, and high-scale distributed tracing backend.

## Installation

1. In the DDEV project directory launch the command:
```
ddev get MurzNN/ddev-grafana
```
2. Restart the DDEV instance:
```
ddev restart
```
3. Open the Grafana web interface via the url: http://your-project-name.ddev.site:3000/

**Contributed and maintained by [@MurzNN](https://github.com/MurzNN).

## Extra

Integration with popular CMSs and frameworks:

- Drupal CMS: [OpenTelemery module](https://www.drupal.org/project/opentelemetry)

- Symfony: [OpenTelemetry Symfony auto-instrumentation](https://github.com/opentelemetry-php/contrib-auto-symfony)

- Laravel: [Open Telemetry package](https://github.com/spatie/laravel-open-telemetry)
