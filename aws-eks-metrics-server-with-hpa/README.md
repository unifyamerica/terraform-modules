<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_horizontal_pod_autoscaler_v2.web_app_hpa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_helm_chart"></a> [helm\_chart](#input\_helm\_chart) | Name of the helm chart | `string` | `"metrics-server"` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Helm Chart metrics-server version to use. | `string` | `"3.11.0"` | no |
| <a name="input_helm_metrics_namespace"></a> [helm\_metrics\_namespace](#input\_helm\_metrics\_namespace) | Namespace to deploy the metrics-server. | `string` | `"kube-system"` | no |
| <a name="input_helm_name"></a> [helm\_name](#input\_helm\_name) | Name of the metrics-server resources | `string` | `"metrics-server"` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | Helm Repository to pull from | `string` | `"https://kubernetes-sigs.github.io/metrics-server/"` | no |
| <a name="input_web_namespace"></a> [web\_namespace](#input\_web\_namespace) | app namespace. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->