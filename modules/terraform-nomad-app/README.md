# terraform-nomad-app

This Terraform module deploys an application to Nomad by
creating a Nomad job.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_nomad"></a> [nomad](#requirement\_nomad) | >= 2.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nomad"></a> [nomad](#provider\_nomad) | 2.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [nomad_job.application](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job) | resource |
| [nomad_job_parser.application](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/data-sources/job_parser) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_count"></a> [application\_count](#input\_application\_count) | Number of instances for application | `number` | `1` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of application | `string` | n/a | yes |
| <a name="input_application_port"></a> [application\_port](#input\_application\_port) | Port of application | `number` | n/a | yes |
| <a name="input_args"></a> [args](#input\_args) | Arguments to pass to command when running application | `list(string)` | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | Command to run application | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU for application | `number` | `20` | no |
| <a name="input_driver"></a> [driver](#input\_driver) | Nomad driver to run application | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for application | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image for application | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory for application | `number` | `10` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata for application | `map(string)` | `{}` | no |
| <a name="input_node_pool"></a> [node\_pool](#input\_node\_pool) | Node pool for application | `string` | `"default"` | no |
| <a name="input_service_provider"></a> [service\_provider](#input\_service\_provider) | Nomad service provider, must be consul or nomad | `string` | `"consul"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | n/a |
