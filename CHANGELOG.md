**Table of contents**

[[_TOC_]]

## Changes
  - Using eni-zipkin plugin instead of zipkin

## 1.7.1
  - Removed: Allow dedicated ignoreServices for our own Zipkin plugin

## 1.7.0
  - Auto job deletion for non-hook jobs
  - Allow dedicated ignoreServices for our own Zipkin plugin
  - ACL plugin overwrite fix

## 1.6.1
  - Fixed configuration overwrite

## 1.6.0
  - Added TargetLabels to ServiceMonitor 
  - Added seperate jobs for bootrapping and upgrade
  - Switch to Kong Community Edition 2.3.2
  - AdminApi ingress behaviour based on edition (CE or EE)
  - Updated Jumper to 1.3.5
  - CE: Admin API protection via proxy
  - Admin API backend and path depending on config and edition

## 1.5.0
  - Updated Jumper to 1.3.0
  - Added JUMPER_ISSUER_URL env var

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

