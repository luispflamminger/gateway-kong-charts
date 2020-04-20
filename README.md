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

## Security

By default, the ingress giving access to the admin API is enabled. Access is secured by role based access control (RBAC).

### SSL Verification

By default Kong API-Gateway will verify the forward proxy traffic against a chain of default Telekom CA certificates.  
You can disables this behavior by setting sslVerify to false in the ``values.yaml``.  
You can use your own CA certificates by copying a new configMap to the templates/ directory and refer to that configmap in the ``values.yaml``.

Example *templates/my-apigateway-config.yaml*:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-apigateway-config
  labels: {{- include "kong.labels" $ | nindent 4 }}
data:
  trusted-ca-certificates.pem: |
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

Example *values.yaml*:
```yaml
# ...

trustedCaCertificates:
  configMap: my-apigateway-config
  key: trusted-ca-certificates.pem

templateChangeTriggers:
  - my-apigateway-config.yaml
# ...
```

Adding the configMap file to ``templateChangeTriggers`` will cause a re-deployment of Kong API-Gateway if the content of that file change.

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
| `templateChangeTriggers`             | List of (template) yaml files fo which a checksum annotation will be created   | `[]`             |
| `trustedCaCertificates`              | List of references for CA certificate chains in PEM format                     | `[]`             |
| `trustedCaCertificates[].configMap`  | Name of the configMap that holds CA certificates                               | `nil`            |
| `trustedCaCertificates[].key`        | Data key of the configMap that holds CA certificates in PEM format             | `nil`            |
| `sslVerify`                          | Controls whether to check forward proxy traffic against CA certificates        | `true`           |
| `sslVerifyDepth`                     | SSL Verification depth                                                         | `1`              |

## Compatibility

| Environment | Compatible |
|-------------|------------|
| OTC         | Yes        |
| AppAgile    | Unverified |
| AWS EKS     | Yes        |


## Changes

1.0.0
- Initial release
