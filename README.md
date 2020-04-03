# TIF Kong API-Gateway

## Requirements

### License

To allow Kong to start as enteprise edition, you need a valid enterprise license. The license is stored as secret and will be pulled by the TIF-Pipeline-Operator to be deployed in the cluster.

### Database

The Kong API-Gateway is based on Kong Enterprise. This requires a PostgreSQL database deployed together with Kong. It will be preconfigured by the Kong's init container.

### Database-less mode
Right now, Kong enterprise cannot run DB-less and additionally, certificates will be stored in the database. Do not trust the configuration that says it can run without. We got information first hand that it cannot. This may be a future Kong feature, as well as storing (all) certificates in secrets or Vault.

## Configuration

### License

Place your license-JSON into at in the `enterprise` scope of the `values.yaml`. Make sure that `enabled` is set to `true`. Otherwise it will not start as enterprise.

### Database

No detailed configuration is necessary. PostgreSQL will be deployed together with Kong. You should rename the default password in the secret!

### External access

Kong API-Gateway can be accessed via created Ingress/Route. See the Parameters section for details.

## Security

By default, the ingress giving access to the admin API is enabled. Access is secured by role based access control (RBAC).

## Configuration via TIF-Deployer

Kong API-Gateway can also be deployed via the TIF-Deployer. Documentation can also be found [here in Codeshare](https://codeshare.workbench.telekom.de/gitlab/TIF-Collaboration/examples/pipelines/tif-infrastructure).

**WARNING: If you undeploy the PostgreSQL bundled in this component, the Volume Claims created on deployment will be deleted!**

## Parameters

This is a short overlook about important parameters in the `values.yaml`.

| Parameter                    | Description                                                      | Default          |
|------------------------------|------------------------------------------------------------------|------------------|
| `global`                     | Common values for all TIF-Helm-Charts                            |                  |
| `global.platform`            | Determines where the chart will be deployed                      | `kubernetes`     |
| `global.project_prefix`      | Prefix for the deployed application name to group applications   | `tif-`           |
| `global.storageClass`        | Select storage class for the PVCs depending on your platform     | `gp2`            |
| `global.externalDnsTarget`   | AWS EKS only: The service IP of your external ingress controller | `nil`            |
| `global.domain.internal.url` | URL for cluster external access set in Ingress/Route             | `nil`            |

## Compatibility

| Environment | Compatible |
|-------------|------------|
| OTC         | Yes        |
| AppAgile    | Unverified |
| AWS EKS     | Yes        |


## Changes

1.0.0
- Initial release
