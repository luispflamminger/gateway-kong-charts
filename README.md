# StarGate Helm Chart

**Table of contents**

[[_TOC_]]

## TL;DR
Not much to read, read everything!

## Requirements

### Database

StarGate requires a PostgreSQL database that will be preconfigured by StarGate's init container.

## Configuration

### Platform

You can select a platform (e.g. caas) to use predefined settings (e.g. securityContext) specifically dedicated to the platform. \
Note that you can overwrite platform specific values in the values.yaml. \
To add a new platform specific values.yaml, add the required values as platforName.yaml to the platforms folder.

**Note:** Setting platform specific values for the sub-chart by the platform specific platformName.yaml of your main-chart will not work, as the sub-chart platforms have precedence.

### Database

No detailed configuration is necessary. PostgreSQL will be deployed together with StarGate. You should change the default passwords!

### Routes, Services, etc. via job

If you want to add routes, services, etc. you can set specific curl command to deploy you preferc configuration.

### External access

StarGate can be accessed via created Ingress/Route. See the Parameters section for details.
By default, URLs will have the format `<Release.Name>[-<Suffix>]-<.Release.Namespace>.<.Values.global.domain>`.
Setting dedicated hostnames for an ingress will overwrite the created URL. The value set in `hostname` needs to be fully qualified, as `.Values.global.domain` will not be added automatically!

## Security

### Community Edition

Be aware that exposing the Admin-API for Community Edition can be dangerous, as the API is not protected by any RBAC. Thus it can be accessed by anyone having access to the API url. \
Therefore the Admin-API-Ingress is disabled. For Mor details see [External access](#External-access).

By default, we protect the Admin API via a dedicated service and route together with the jwt-keycloak. You need to add the used issuer.

### SSL Verification

If you enable SSL verification StarGate will try to verify all traffic against a bundle of trusted CA certificates which needs to be specified explicitely. 
You can enable this by setting sslVerify to true in the ``values.yaml``.  If you do so, you must provide your own truststore by setting the ``trustedCaCertificates`` field with the content of your CA certificates in PEM format otherwise Kong won't start. 

Example *values.yaml*:
```yaml
trustedCaCertificates: |
  -----BEGIN CERTIFICATE-----
  <CA certificate 01 in PEM format here>
  -----END CERTIFICATE-----
  -----BEGIN CERTIFICATE-----
  <CA certificate 02 in PEM format here>
  -----END CERTIFICATE-----
  -----BEGIN CERTIFICATE-----
  <CA certificate 03 in PEM format here>
  -----END CERTIFICATE-----
```
Of course Helm let's you reference multiple values files when installing a deployment so you could also outsource ``trustedCaCertificates`` wo its own values file, for example ``my-trustes-ca-certificates.yaml``.

### Supported TLS versions

Only TLS versions TLSv1.2 and TLSv.1.3 are allowed. TLSv1.1 is NOT supported.

### Server Certificate

If "https" is used but no SNI is configured, the API gateway provides a default server certificate issued for "https://localhost". You can replace the default certificate by a custom server-certificate by specyfing the secret name in the variable ``defaultTlsSecret``.

Example *values.yaml*:
```yaml
defaultTlsSecret: my-https-secret
```

Here are some examples how to create a corresponding secret from PEM files. For more details s. Kubernetes documentation.
```
kubectl create secret tls my-https-secret --key=key.pem --cert=cert.pem
oc create secret generic my-https-secret-2 --from-file=tls.key=key.pem  --from-file=tls.crt=cert.pem
```

## Bootstrap and Upgrade
Setup and some upgrades require specific migration steps to be run before and after changing the Kong version via a newer image or starting it for the first time.
There the chart provides specialised jobs for each of those steps.

### Bootstrap
Bootstrapping is required when Kong starts for the first time and needs to setup its database. This task is handled by the job `job-kong-bootstrap.yml`.
It will be run if "`migrations: bootstrap`" is set in the `values.yaml`. This can be uncommented if no further execution is wished, but this is also prohibited by keeping the job itself.
Running the job again will do no harm in any way, as the executed bootstrap recognises the database as already initialised.
If you deploy a new instance of StarGate, make sure migrations is set to `bootstrap`.

### Upgrade

Upgrading to a newer version may require running migration steps (e.g. database changes). To run those jobs set "`migrations: upgrade`" in the `values.yaml`.
As a result `job-kong-pre-upgrade-migrations.yml` will run and `job-kong-post-upgrade-migrations.yml` will be run after successfull deployments to complete the upgrade.

**Warning:** Uncomment "`migrations: upgrade`" if you deploy again after a successfull deployment or set it to "`migrations: bootstrap`". Otherwise migrations will be executed again.

**Note:** Those jobs are only ment to be used for upgrading.

## Upgrade Advice
The following section contains special advice for dedicated updates and maybe necessary steps to be taken if updating from a certain version to another.
Although updates in minor versions, whilst keeping the same major verison, do not contain breaking changes, implications may occour.

### To 1.24.0 and up
This version introduces Kong 2.8.1 and requires migrations to be run.\
It also requires to adapt to the changed ```securityContext``` settings of the ```plugins``` in the ````values.yaml```.  

### To 1.23.0 and up
Version 1.23.0 introduces a new issuer service version. If in use, this requires to set values for the new secret ```secret-issuer-service.yml```. \
Replace ```jsonWebKey: changeme``` and  ```publicKey: changeme```.

### From 1.5.x and lower to 1.6.x
With introduction of Kong CE, a dedicated Admin-API handling has been introduced to proted the Admin-API. This required changes to the ingress of the Admin-API.
Those changes are only reflected in the ```ingress-admin.yml``` and not in the ```route-admin.yml```. Using Kong CE will work, but deploying
the Admin-API-Route will provide unsecured access to the Admin-API.

### From 1.7.x and lower to 1.8.x and up
The bundled Zipkin-plugin has been replaced by the ENI-Zipkin pluging. Behaviour and configuration differ slightly to the used one.
To avoid complications, we strongly recommend removing the existing Zipkin-Plugin before upgrading. This can be done via a DELETE call on the Admin-API (Token required).

Lookup all plugins and find the Zipkin-Plugin-ID:
```
via GET on https://admin-api-url.me/plugins
```
Deleting the existing plugin:
```
via DELETE on https://admin-api-url.me/plugins/<zipkinPluginId>
```

### From 2.x.x and lower to 3.x.x
We changed the integration of the ENI-plugins. Therefore names of the plugins changed and and eni-prefixed plugins have been removed from the image. Therefore the configuration of Kong itself, precisely the database, needs to be updated.
You can do this by activating the jobs migration. This will delete the "old" ENI-plugins to allow the configuration of the new ones.

```
migrations: jobs
```

## Parameters

This is a short overlook about important parameters in the `values.yaml`.

| Parameter                                           | Description                                                                                                                               | Default                               |
|-----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------|
| `global`                                            | Common values for all DHEI-Helm-Charts                                                                                                    |                                       |
| `global.platform`                                   | Determines where the chart will be deployed                                                                                               | `kubernetes`                          |
| `global.storageClassName`                           | Overwrites the setting determined by the platform                                                                                         | `gp2`                                 |
| `global.domain`                                     | URL for cluster external access set in Ingress/Route                                                                                      | `nil`                                 |
| `global.labels`                                     | Define global labels                                                                                                                      | `tif.telekom.de/group`                |
| `global.ingress.annotations`                        | Set annotations for all ingress, can be extended by ingress specific ones                                                                 | `nil`                                 |
| `global.image.repository`                           | Set default repository for all images                                                                                                     | `mtr.devops.telekom.de`               |
| `global.image.organisation`                         | Set default organisation for all images                                                                                                   | `tif-public`                          |
| `global.image.force`                                | Replace repository/organisation also if image is set as custom  "image:" value                                                            | `false`                               |
| `global.database.location`                          | Specifiy if you want to deploy a PostgreSQL or use an external database                                                                   | `local`                               |
| `global.database.port`                              | Port of the database                                                                                                                      | `5432`                                |
| `global.database.database`                          | Name of the database                                                                                                                      | `kong`                                |
| `global.database.schema`                            | Name of the schema                                                                                                                        | `public`                              |
| `global.database.user`                              | Username for accessing the database                                                                                                       | `kong`                                |
| `global.database.password`                          | The users password                                                                                                                        | `changeme`                            |
| `global.tracing`                                    | Set generic tracing settings, will be used if not specified explicitly                                                                    | `Trace settings`                      |
| `global.tracing.collectorUrl`| URL of the Zipkin-Collector (e.g. Jaeger-Collector), http(s) mandatory                                                                                           | `http://guardians-drax-collector.skoll:9411/api/v2/spans`|
| `global.tracing.defaultServiceName`                 | Name of the service shown in e.g. Jaeger                                                                                                  | `stargate`                            |
| `global.tracing.sampleRatio`                        | How often to sample requests that do not contain trace ids. Set to 0 to turn sampling off, or to 1 to sample all requests.                | `1`                                   |
| `migrations`                                        | Determine the migrations behaviuor for a new instance or upgrade                                                                          | `none`                                |
| `adminApi.enabled`                                  | Create service for accessing Kong Admin API                                                                                               | `true`                                |
| `adminApi.tls.enabled`                              | Access Admin API via https instead of http                                                                                                | `false`                               |
| `adminApi.ingress.enabled`                          | Create ingress for Admin API. Default depends on Edition                                                                                  | CE: `false`<br/>EE: `true`            |
| `adminApi.ingress.hostname`                         | Set dedicated hostname for Admin API ingress (or route), overwrites global URL                                                            | `nil`                                 |
| `adminApi.ingress.annotations`                      | Merges specific into global ingress annotations                                                                                           | `nil`                                 |
| `adminApi.access_log`                               | Set the log target for access log                                                                                                         | `/dev/stdout`                         |
| `adminApi.ingress.annotations`                      | Set the log target for error log                                                                                                          | `/dev/stderr`                         |
| `proxy.ingress.enabled`                             | Create ingress for proxy                                                                                                                  | `true`                                |
| `proxy.ingress.hostname`                            | Set dedicated hostname for proxy ingress (or route), overwrites global URL                                                                | `nil`                                 |
| `proxy.ingress.annotations`                         | Merges specific into global ingress annotations                                                                                           | `ssl-passthrough`                     |
| `proxy.access_log`                                  | Set the log target for access log                                                                                                         | `/dev/stdout`                         |
| `proxy.ingress.annotations`                         | Set the log target for error log                                                                                                          | `/dev/stderr`                         |
| `configuration`                                     | Set a script to run after deployment for configuration of StarGate                                                                        | `default admin-api conf`              |
| `templateChangeTriggers`                            | List of (template) yaml files fo which a checksum annotation will be created                                                              | `[]`                                  |
| `sslVerify`                                         | Controls whether to check forward proxy traffic against CA certificates                                                                   | `false`                               |
| `sslVerifyDepth`                                    | SSL Verification depth                                                                                                                    | `1`                                   |
| `setupJobs.backoffLimit`                            | How often should be retried to run the job successfully                                                                                   | `20`                                  |
| `setupJobs.activeDeadlineSeconds`                   | How long should be retried to run the job successfully                                                                                    | `300`                                 |
| `zipkin.enabled`                                    | Enable tracing via ENI-Zipkin-Plugin                                                                                                      | `false`                               |
| `zipkin.collectorUrl`                               | URL of the Zipkin-Collector (e.g. Jaeger-Collector), http(s) mandatory                                                                    | `http://guardians-drax-collector.skoll:9411/api/v2/spans`|
| `zipkin.sampleRatio`                                | How often to sample requests that do not contain trace ids. Set to 0 to turn sampling off, or to 1 to sample all requests.                | `1`                                   |
| `zipkin.includeCredential`                          | Should the credential of the currently authenticated consumer be included in metadata sent to the Zipkin server?                          | `true`                                |
| `zipkin.defaultServiceName`                         | Name of the service shown in e.g. Jaeger                                                                                                  | `stargate`                            |
| `zipkin.luaSslTrustedCertificate`                   | CA certificate for the Zipkin-Collector-URL                                                                                               | `nil`                                 |
| `trustedCaCertificates`                             | CA certificates in PEM format (string)                                                                                                    | `nil`                                 |
| `defaultTlsSecret`                                  | Name of the secret containing the default server certificates                                                                             | `nil`                                 |
| `plugins.`                                          | This section contains all Kong plugins settings                                                                                           | `See the following plugins`           |
| `prometheus.enabled`                                | Controls whether to annotate pods with prometheus scraping information or not                                                             | `true`                                |
| `prometheus.port`                                   | Sets the port at which metrics can be accessed                                                                                            | `9542`                                |
| `prometheus.path`                                   | Sets the endpoint at which at which metrics can be accessed                                                                               | `/metrics`                            |
| `prometheus.podMonitor.enabled`                     | Enables a podmonitor which can be used by the prometheus operator to collect metrics                                                      | `false`                               |
| `prometheus.podMonitor.scheme`                      | HTTP scheme to use for scraping                                                                                                           | `http`                                |
| `prometheus.podMonitor.interval`                    | Interval at which metrics should be scraped                                                                                               | `15s`                                 |
| `prometheus.podMonitor.scrapeTimeout`               | Timeout after which the scrape of prometheus is ended                                                                                     | `3s`                                  |
| `prometheus.podMonitor.honorLabels`                 | HonorLabels chooses the metric’s labels on collisions with target labels                                                                  | `true`                                |
| `prometheus.serviceMonitor.enabled`                 | Enables a servicemonitor which can be used by the prometheus operator to collect metrics                                                  | `true`                                |
| `prometheus.serviceMonitor.scheme`                  | HTTP scheme to use for scraping                                                                                                           | `http`                                |
| `prometheus.serviceMonitor.interval`                | Interval at which metrics should be scraped                                                                                               | `15s`                                 |
| `prometheus.serviceMonitor.scrapeTimeout`           | Timeout after which the scrape of prometheus is ended                                                                                     | `3s`                                  |
| `prometheus.serviceMonitor.honorLabels`             | HonorLabels chooses the metric’s labels on collisions with target labels                                                                  | `true`                                |
| `jwtKeycloak.enabled`                               | Activate or deactivate the jwt-keycloak plugin                                                                                            | `true`                                |
| `jwtKeycloak.setupJob`                              | Set required values for the provieded configuration. Can be ignored for costum config                                                     |                                       |
| `jwtKeycloak.setupJob.pluginId`                     | If you want to alter the already configured plugin, set the pluginId                                                                      | `24f1d5a5-4d31-4abc-b539-bed6d3cd7f0a`|
| `jwtKeycloak.setupJob.allowedIss`                   | Set the Iris URL you want StarGate to use for Admin API athentication                                                                     | `https://changeme/auth/realms/default`|
| `jumper`                                            | Configure the Jumper (by Hyperion)                                                                                                        | `1.5.5`                               |
| `issuerService`                                     | Confgiure the Issuer-Service (by Hyperion)                                                                                                | `1.0.0`                               |
| `postgresql.image`                                  | Specifiy the PostgreSQL image                                                                                                             | `postgres-12.3-debian`                |
| `postgresql.securityContext`                        | Specifiy the security context                                                                                                             | `nil`                                 |
| `postgresql.resources`                              | Assign ressources, e.g. limits, for Postgres                                                                                              | `Memory limits`                       |
| `externalDatabase.host`                             | If an external database is used, this is the url of the database instance                                                                 | `nil`                                 |
| `externalDatabase.ssl`                              | Use ssl for connection                                                                                                                    | `false`                               |
| `externalDatabase.sslVerify`                        | Use the provided certificate                                                                                                              | `false`                               |
| `externalDatabase.luaSslTrustedCertificate`         | Provide certificate                                                                                                                       | `nil`                                 |
| `replicas`                                          | Set the number of Stargate replicas                                                                                                       | `1`                                   |
| `autoscaling.enabled`                               | Enables Pod Autoscaling with Target CPU usage                                                                                             | `false`                               |
| `autoscaling.minReplicas`                           | Minimum number of replicas if autoscaling is enabled                                                                                      | `$replicas`                           |
| `autoscaling.maxReplicas`                           | Maximum number of replicas if autoscaling is enabled                                                                                      | `10`                                  |
| `autoscaling.cpuUtilizationPercentage`              | Number of target CPU Utilization                                                                                                          | `80`                                  |
| `logFormat`                                         | Selects the mginx log format `default`, `json` or `plain`                                                                                 | `default`                             |

## Troubleshooting

If StarGate deployment fails to come up, please have a look at the logs of the container.

**Log message:**
```
Error: /usr/local/share/lua/5.1/opt/kong/cmd/start.lua:37: nginx configuration is invalid (exit code 1):
nginx: [emerg] SSL_CTX_load_verify_locations("/usr/local/opt/kong/tif/trusted-ca-certificates.pem") failed (SSL: error:0B084088:x509 certificate routines:X509_load_cert_crl_file:no certificate or crl found)
nginx: configuration file /opt/kong/nginx.conf test failed
```
**Solution:**  
This error happens if ``sslVerify`` is set to true but no valid certificates could be found.  
Please make sue that ``trustedCaCertificates`` is set probably or set sslVerify to false if you don't wish to use ssl verification.

## Compatibility

| Environment | Compatible |
|-------------|------------|
| OTC         | Yes        |
| AppAgile    | Unverified |
| AWS EKS     | Yes        |
| CaaS        | Yes        |

This Helm Chart is also compatible with Sapling, DHEI's universal solution for deploying Helm Charts to multiple Telekom cloud platforms.
