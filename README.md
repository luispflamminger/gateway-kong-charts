# TIF Kong API-Gateway

## Requirements

### License

To allow Kong to start as enteprise edition, you need a valid enterprise license.

### Database

The Kong API-Gateway is based on Kong Enterprise. This requires a PostgreSQL database deployed together with Kong. It will be preconfigured by the Kong's init container.

### Database-less mode
Right now, Kong enterprise cannot run DB-less and additionally, certificates will be stored in the database. Do not trust the configuration that says it can run without. We got information first hand that it cannot. This may be a future Kong feature, as well as storing (all) certificates in secrets or Vault.

## Configuration

### License

Place your license-JSON into at in the `enterprise` scope of the `values.yaml`. If you don't provide a license, Kong API-Gateway will start in the community edition where no Enterprise features will be available. In this case enabled RBAC will not take effect.

### Database

No detailed configuration is necessary. PostgreSQL will be deployed together with Kong. You should rename the default password in the secret!

### External access

Kong API-Gateway can be accessed via created Ingress/Route. See the Parameters section for details.
By default, URLs will have the format `<Release.Name>[-<Suffix>]-<.Release.Namespace>.<.Values.global.domain>`.
Setting dedicated hostnames for an ingress will overwrite the created URL. The value set in `hostname` needs to be fully qualified, as `.Values.global.domain` will not be added automatically!

## Security

By default, the ingress giving access to the admin API is enabled. Access is secured by role based access control (RBAC).

### SSL Verification

If you enable SSL verification Kong API-Gateway will try to verify all traffic against a bundle of trusted CA certificates which needs to be specified explicitely. 
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

### Server Certificate

If "https" is used but no SNI is configured, the API gateway provides a default server certificate issued for "https://localhost". You can replace the default certificate by a custom server-certificate by specyfing the secret name in the variable ``defaultTlsSecret``.

Example *values.yaml*:
```yaml
defaultTlsSecret: my-https-secret
```

Here are some examples how to create a corresponding secret from PEM files. For more details s. Kubernetes/Openshift documentation.
```
kubectl create secret tls my-https-secret --key=key.pem --cert=cert.pem
oc create secret generic my-https-secret-2 --from-file=tls.key=key.pem  --from-file=tls.crt=cert.pem
```

## Configuration via TIF-Deployer
## Configuration via TIF-Deployer

Kong API-Gateway can also be deployed via the TIF-Deployer. Documentation can also be found [here in Codeshare](https://codeshare.workbench.telekom.de/gitlab/TIF-Collaboration/examples/pipelines/tif-infrastructure).

**WARNING: If you undeploy the PostgreSQL bundled in this component, the Volume Claims created on deployment will be deleted!**

## Parameters

This is a short overlook about important parameters in the `values.yaml`.

| Parameter                            | Description                                                                    | Default          |
|--------------------------------------|--------------------------------------------------------------------------------|------------------|
| `global`                             | Common values for all TIF-Helm-Charts                                          |                  |
| `global.platform`                    | Determines where the chart will be deployed                                    | `kubernetes`     |
| `global.project_prefix`              | Prefix for the deployed application name to group applications                 | `tif-`           |
| `global.storageClass`                | Select storage class for the PVCs depending on your platform                   | `gp2`            |
| `global.externalDnsTarget`           | AWS EKS only: The service IP of your external ingress controller               | `nil`            |
| `global.domain`                      | URL for cluster external access set in Ingress/Route                           | `nil`            |
| `adminApi.enabled`                   | Create service for accessing Kong Admin API                                    | `true`           |
| `adminApi.tls.enabled`               | Access Admin API via https instead of http                                     | `false`          |
| `adminApi.ingress.enabled`           | Create ingress (or route for OpenShift) for Admin API                          | `true`           |
| `adminApi.ingress.hostname`          | Set dedicated hostname for Admin API ingress (or route), overwrites global URL | `nil`            |
| `adminApi.ingress.annotations`       | Overwrite default ingress annotations                                          | `nil`            |
| `manager.enabled`                    | Create service for accessing Kong Manager                                      | `true`           |
| `manager.tls.enabled`                | Access Manager via https instead of http                                       | `false`          |
| `manager.ingress.enabled`            | Create ingress (or route for OpenShift) for Manager                            | `true`           |
| `manager.ingress.hostname`           | Set dedicated hostname Manager ingress (or route), overwrites global URL       | `nil`            |
| `manager.ingress.annotations`        | Overwrite default ingress annotations                                          | `nil`            |
| `portal.enabled`                     | Create service for accessing the Portal                                        | `false`          |
| `portal.tls.enabled`                 | Access the Portal via https instead of http                                    | `false`          |
| `portal.ingress.enabled`             | Create ingress (or route for OpenShift) for the Portal                         | `true`           |
| `portal.ingress.hostname`            | Set dedicated hostname for the Portal ingress (or route), overwrites global URL| `nil`            |
| `portal.ingress.annotations`         | Overwrite default ingress annotations                                          | `nil`            |
| `proxy.ingress.enabled`              | Create ingress (or route for OpenShift) for proxy                              | `true`           |
| `proxy.ingress.hostname`             | Set dedicated hostname for proxy ingress (or route), overwrites global URL     | `nil`            |
| `proxy.ingress.annotations`          | Overwrite default ingress annotations                                          | `nil`            |
| `templateChangeTriggers`             | List of (template) yaml files fo which a checksum annotation will be created   | `[]`             |
| `sslVerify`                          | Controls whether to check forward proxy traffic against CA certificates        | `false`           |
| `sslVerifyDepth`                     | SSL Verification depth                                                         | `1`              |
| `zipkin.enabled`                     | Enable tracing via Zipkin-Plugin                                               | `false`          |
| `zipkin.defaultServiceName`          | Name of the service shown in e.g. Jaeger                                       | `tif-kong-apigateway` |
| `zipkin.collectorUrl`                | URL of the Zipkin-Collector (e.g. Jaeger-Collector), http(s) mandatory         | `nil`            |
| `zipkin.sampleRatio`                 | How often to sample requests that do not contain trace ids. Set to 0 to turn sampling off, or to 1 to sample all requests                                                                                                                  | `0.001`          |
| `zipkin.includeCredential`           | Should the credential of the currently authenticated consumer be included in metadata sent to the Zipkin server?                                                                                                                   | `true`           |
| `zipkin.setupJob.backoffLimit`       | How often should be retried to run the job successfully                        | `20`             |
| `zipkin.setupJob.activeDeadlineSeconds`| How long should be retried to run the job successfully                       | `300`            |
| `trustedCaCertificates`              | CA certificates in PEM format (string)                                         | `nil`            |
| `defaultTlsSecret`                   | Name of the secret containing the default server certificates                  | `nil`            |
| `prometheus.enabled`                 | Controls whether a metrics services should be deployed or not                  | `true`           |
| `prometheus.port`                    | Sets the port at which metrics can be accessed                                 | `9542`           |
| `prometheus.path`                    | Sets the endpoint at which at which metrics can be accessed                    | `/metrics`       |

## Troubleshooting

If the Kong API-Gateway deployment fails to come up, please have a look at the logs of the container.

**Log message:**
```
Error: /usr/local/share/lua/5.1/kong/cmd/start.lua:37: nginx configuration is invalid (exit code 1):
nginx: [emerg] SSL_CTX_load_verify_locations("/usr/local/kong/tif/trusted-ca-certificates.pem") failed (SSL: error:0B084088:x509 certificate routines:X509_load_cert_crl_file:no certificate or crl found)
nginx: configuration file /usr/local/kong/nginx.conf test failed
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


## Changes

0.0.0
- DHEI-1430: Hostname setting for every ingress/route
- DHEI-1430: Annotations overwrite for ingress/routes
- DHEI-1136: Enable and configure Zipkin-Plugin

1.0.0
- Initial release
