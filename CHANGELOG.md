**Table of contents**

[[_TOC_]]

## 1.4.3
  - Removed labels from Postgres

## 1.4.2
 - Log settings options
 - Added ConfigMap for pipeline meta data

## 1.4.1
 - Added ServiceMonitor which is now enabled by default. PodMonitor is now disabled by default

## 1.4.0

 - Allow TLSv1.2 and TLSv1.3 only, removed TLSv1 support
 - Make podmonitor selector configurable
 - Zipkin and Prometheus plugin configuration changes will now be properly applied

## 1.3.1

- Hotfix: Use "Recreate" strategy for database deployment

## 1.3.0

 - Made CPU, RAM and persistence resources configurable
 - Made the securityContext configurable
 - Adjusted resource request and limit defaults
 - Support for environments that prohibit writing to the root file system (like CaaS)
 - Edge TLS termination is now the default for the proxy

## 1.2.0

 - Allow setting of a Zipkin CA certificate
 - Allow setting of a external Postgres CA certificate
 - Global labels settings with a default fluentd label
 - Label deployments with chart version

## 1.1.0

 - DHEI-1712: Extended external database configuration
 - Removed kong prefix from servicePort to comply with requirements
 - Enterprise license stored in secret
 - Global ingress annotations setting

## 1.0.1

- Bugfix: Wrong secrets reference in non-rbac case for plugin-enabling jobs
- Added job to enable Prometheus plugin on global default workspace

## 1.0.0

- DHEI-1430: Hostname setting for every ingress/route
- DHEI-1430: Annotations overwrite for ingress/routes
- DHEI-1136: Added option to enable and configure Zipkin-Plugin
- DHEI-967: Added option to configure mTLS Proxy to present a server cert
- DHEI-1135: Added option to enable a metrics service that can be found scraped by Prometheus

