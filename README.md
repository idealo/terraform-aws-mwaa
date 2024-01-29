# AWS MWAA Terraform Module

Terraform module which creates AWS MWAA resources and connects them together.

## How to

### Contribute

If the automated doc generation (listed under checks) fails as part of a PR from a fork, please mention us in the PR conversation or raise an issue.

### Use 

Use this code to create a basic MWAA environment (using all default parameters, see [Inputs](#inputs)):
```terraform
module "airflow" {
  source = "idealo/mwaa/aws"
  version = "x.x.x"
  
  account_id = "12345679"
  environment_name = "MyEnvironment"
  internet_gateway_id = "ig-12345"
  private_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"] # depending on your vpc ip range
  public_subnet_cidrs = ["10.0.3.0/24","10.0.4.0/24"] # depending on your vpc ip range
  region = "us-west-1"
  source_bucket_arn = "arn:aws:s3:::MyMwaaBucket"
  vpc_id = "vpc-12345"
}
```

### Add permissions to the Airflow execution role

To give additional permissions to your airflow executions role (e.g. elasticmapreduce:CreateJobFlow to start an EMR cluster), create a Policy document containing the permissions you need:

```terraform
data aws_iam_policy_document "additional_execution_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "<Your permissions>"
    ]
    resources = [
      "<YourResource>"]
  }
}
```

and pass the document json to the module:
```terraform
module "airflow" {
  ...
  additional_execution_role_policy_document_json = data.aws_iam_policy_document.additional_execution_policy_doc.json
  ...
}
```

### Add custom plugins

Simply upload the plugins.zip to s3 and pass the relative path inside the MWAA bucket to the `plugins_s3_path` parameter.
If you zip and upload it via terraform, this would look like this:

```terraform
module "airflow" {
  ...
  plugins_s3_path = aws_s3_bucket_object.your_plugin.key
  ...
}
```

### Use your own networking config
If you set ``create_networking_config = false`` no subnets, eip, NAT gateway and route tables will be created.
**Be aware that you still need the networking resources to get your environment running, follow the [official documentation](https://docs.aws.amazon.com/mwaa/latest/userguide/vpc-create.html) to create them properly.**


### S3 Bucket configuration
MWAA needs a S3 bucket to store the DAG files. Here is a minimal configuration for this S3 bucket:

```terraform
resource "aws_s3_bucket" "mwaa" {
  bucket = "…"
}

resource "aws_s3_bucket_versioning" "mwaa" {
  bucket = aws_s3_bucket.mwaa.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
  # required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
  bucket                  = aws_s3_bucket.mwaa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_mwaa_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mwaa_environment) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Account ID of the account in which MWAA will be started | `string` | n/a | yes |
| <a name="input_additional_associated_security_group_ids"></a> [additional\_associated\_security\_group\_ids](#input\_additional\_associated\_security\_group\_ids) | Security group IDs of existing security groups that should be associated with the MWAA environment. | `list(string)` | `[]` | no |
| <a name="input_additional_execution_role_policy_document_json"></a> [additional\_execution\_role\_policy\_document\_json](#input\_additional\_execution\_role\_policy\_document\_json) | Additional permissions to attach to the base mwaa execution role | `string` | `"{}"` | no |
| <a name="input_airflow_configuration_options"></a> [airflow\_configuration\_options](#input\_airflow\_configuration\_options) | additional configuration to overwrite airflows standard config | `map(string)` | `{}` | no |
| <a name="input_airflow_version"></a> [airflow\_version](#input\_airflow\_version) | Airflow version to be used | `string` | `"2.0.2"` | no |
| <a name="input_create_networking_config"></a> [create\_networking\_config](#input\_create\_networking\_config) | true if networking resources (subnets, eip, NAT gateway and route table) should be created. | `bool` | `true` | no |
| <a name="input_dag_processing_logs_enabled"></a> [dag\_processing\_logs\_enabled](#input\_dag\_processing\_logs\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_dag_processing_logs_level"></a> [dag\_processing\_logs\_level](#input\_dag\_processing\_logs\_level) | One of: DEBUG, INFO, WARNING, ERROR, CRITICAL | `string` | `"WARNING"` | no |
| <a name="input_dag_s3_path"></a> [dag\_s3\_path](#input\_dag\_s3\_path) | Relative path of the dags folder within the source bucket | `string` | `"dags/"` | no |
| <a name="input_environment_class"></a> [environment\_class](#input\_environment\_class) | n/a | `string` | `"mw1.small"` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the MWAA environment | `string` | n/a | yes |
| <a name="input_internet_gateway_id"></a> [internet\_gateway\_id](#input\_internet\_gateway\_id) | ID of the internet gateway to the VPC, if not set and create\_networking\_config = true an internet gateway will be created | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS CMK ARN to use by MWAA for data encryption. MUST reference the same KMS key as used by S3 bucket specified by source\_bucket\_arn, if the bucket uses KMS. If not specified, the default AWS owned key for MWAA will be used for backward compatibility with version 1.0.1 of this module. | `string` | `null` | no |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers) | numeric string, min 1 | `string` | `"10"` | no |
| <a name="input_min_workers"></a> [min\_workers](#input\_min\_workers) | numeric string, min 1 | `string` | `"1"` | no |
| <a name="input_plugins_s3_object_version"></a> [plugins\_s3\_object\_version](#input\_plugins\_s3\_object\_version) | n/a | `string` | `null` | no |
| <a name="input_plugins_s3_path"></a> [plugins\_s3\_path](#input\_plugins\_s3\_path) | relative path of the plugins.zip within the source bucket | `string` | `null` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for the private subnets MWAA uses. Must be at least 2 if create\_networking\_config=true | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Subnet Ids of the existing private subnets that should be used if create\_networking\_config=false | `list(string)` | `[]` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for the public subnets MWAA uses. Must be at least 2 if create\_networking\_config=true | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where the environment and its resources will be created | `string` | n/a | yes |
| <a name="input_requirements_s3_object_version"></a> [requirements\_s3\_object\_version](#input\_requirements\_s3\_object\_version) | n/a | `string` | `null` | no |
| <a name="input_requirements_s3_path"></a> [requirements\_s3\_path](#input\_requirements\_s3\_path) | relative path of the requirements.txt (incl. filename) within the source bucket | `string` | `null` | no |
| <a name="input_scheduler_logs_enabled"></a> [scheduler\_logs\_enabled](#input\_scheduler\_logs\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_scheduler_logs_level"></a> [scheduler\_logs\_level](#input\_scheduler\_logs\_level) | One of: DEBUG, INFO, WARNING, ERROR, CRITICAL | `string` | `"WARNING"` | no |
| <a name="input_source_bucket_arn"></a> [source\_bucket\_arn](#input\_source\_bucket\_arn) | ARN of the bucket in which DAGs, Plugin and Requirements are put | `string` | n/a | yes |
| <a name="input_startup_script_s3_object_version"></a> [startup\_script\_s3\_object\_version](#input\_startup\_script\_s3\_object\_version) | n/a | `string` | `null` | no |
| <a name="input_startup_script_s3_path"></a> [startup\_script\_s3\_path](#input\_startup\_script\_s3\_path) | The relative path to the script hosted in your bucket. The script runs as your environment starts before starting the Apache Airflow process. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags and logging | `map(string)` | `{}` | no |
| <a name="input_task_logs_enabled"></a> [task\_logs\_enabled](#input\_task\_logs\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_task_logs_level"></a> [task\_logs\_level](#input\_task\_logs\_level) | One of: DEBUG, INFO, WARNING, ERROR, CRITICAL | `string` | `"INFO"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id of the VPC in which the environments resources are created | `string` | n/a | yes |
| <a name="input_webserver_access_mode"></a> [webserver\_access\_mode](#input\_webserver\_access\_mode) | Default: PRIVATE\_ONLY | `string` | `null` | no |
| <a name="input_webserver_logs_enabled"></a> [webserver\_logs\_enabled](#input\_webserver\_logs\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_webserver_logs_level"></a> [webserver\_logs\_level](#input\_webserver\_logs\_level) | One of: DEBUG, INFO, WARNING, ERROR, CRITICAL | `string` | `"WARNING"` | no |
| <a name="input_weekly_maintenance_window_start"></a> [weekly\_maintenance\_window\_start](#input\_weekly\_maintenance\_window\_start) | The day and time of the week in Coordinated Universal Time (UTC) 24-hour standard time to start weekly maintenance updates of your environment in the following format: DAY:HH:MM. For example: TUE:03:30. You can specify a start time in 30 minute increments only | `string` | `"MON:01:00"` | no |
| <a name="input_worker_logs_enabled"></a> [worker\_logs\_enabled](#input\_worker\_logs\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_worker_logs_level"></a> [worker\_logs\_level](#input\_worker\_logs\_level) | One of: DEBUG, INFO, WARNING, ERROR, CRITICAL | `string` | `"WARNING"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mwaa_arn"></a> [mwaa\_arn](#output\_mwaa\_arn) | The arn of the created MWAA environment. |
| <a name="output_mwaa_execution_role_arn"></a> [mwaa\_execution\_role\_arn](#output\_mwaa\_execution\_role\_arn) | The IAM Role arn for MWAA Execution Role. |
| <a name="output_mwaa_nat_gateway_public_ips"></a> [mwaa\_nat\_gateway\_public\_ips](#output\_mwaa\_nat\_gateway\_public\_ips) | List of the ips of the nat gateways created by this module. |
| <a name="output_mwaa_service_role_arn"></a> [mwaa\_service\_role\_arn](#output\_mwaa\_service\_role\_arn) | The Service Role arn for MWAA environment. |
| <a name="output_mwaa_webserver_url"></a> [mwaa\_webserver\_url](#output\_mwaa\_webserver\_url) | The webserver URL of the MWAA Environment. |
<!-- END_TF_DOCS -->
