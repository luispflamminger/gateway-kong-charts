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

This section describes how to deploy Kong API-Gateway with the TIF-Deployer. Configuration parameters and information provided in the general Configuration section apply to this also, if not mentioned otherwise. 

### Deployment

To add Kong API-Gateway to your TIF deployment, add `kong-apigateway` to the component list of your `tif-infrastructure.yaml`. You have to have an enterprise license for Kong to run as enterprise edition. This also requires a PostgreSQL database, which is delivered within the Kong API-Gateway component.

```
  components:
  - kong-apigateway
```

### License

You need to add the license to your deployment pipeline. Simply place the `.sops.yaml` and `secrets.yaml` in the following path, starting on the level of your `infrastructure.yaml`: `secrets/kong-apigateway`

**NOTE:** You can use the same license-file for your Kong API-Gateway Kong and mTLS-Proxy Kong, but it is mandatory to be stored in each components secrets folder.

### Removal

Note that if you undeploy the PostgreSQL component, the Volume Claims created on deployment will remain. This is intended to prevent trace information to be lost. If you don't see further use in keeping thos information, delete the Volume Claims manually.

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

## Changes

1.0.0
- Initial release
