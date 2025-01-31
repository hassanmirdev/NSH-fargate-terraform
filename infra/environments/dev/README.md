

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../../modules/ecs | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ../../modules/iam | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ../../modules/cloudwatch | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appointment_container_name"></a> [appointment\_container\_name](#input\_appointment\_container\_name) | The name of the container | `string` | `"appointment-container"` | no |
| <a name="input_appointment_service_name"></a> [appointment\_service\_name](#input\_appointment\_service\_name) | The name of the ECS service | `string` | `"appointment-service"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | AWS availability zones | `list(string)` | <pre>[<br/>  "us-west-2a",<br/>  "us-west-2b"<br/>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS Cluster Name | `string` | `"my-ecs-cluster"` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | Container Image URL | `string` | `"677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest"` | no |
| <a name="input_image_url_patient"></a> [image\_url\_patient](#input\_image\_url\_patient) | Container Image URL | `string` | `"677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | CloudWatch Log Group Name | `string` | `"ecs-application-logs"` | no |
| <a name="input_patient_container_name"></a> [patient\_container\_name](#input\_patient\_container\_name) | The name of the container | `string` | `"patient-container"` | no |
| <a name="input_patient_service_name"></a> [patient\_service\_name](#input\_patient\_service\_name) | The name of the ECS service | `string` | `"patient-service"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | Private subnet CIDR blocks | `list(string)` | <pre>[<br/>  "10.0.3.0/24",<br/>  "10.0.4.0/24"<br/>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public subnet CIDR blocks | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24"<br/>]</pre> | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | Name of the ECR repository | `string` | `"my-app-repo"` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | CPU for the container | `number` | `256` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory for the container | `number` | `512` | no |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | ECS Task Name | `string` | `"my-task"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->