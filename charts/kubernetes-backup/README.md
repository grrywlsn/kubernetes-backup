# kubernetes-backup

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cronjob.backupRepo | string | `""` |  |
| cronjob.clusterName | string | `""` |  |
| cronjob.schedule | string | `"0 23 * * *"` |  |
| cronjob.skipNamespaces | string | `"default"` |  |
| cronjob.skipResources | string | `"leases nodes secrets"` |  |
| image.tag | string | `"v3.4.2"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)