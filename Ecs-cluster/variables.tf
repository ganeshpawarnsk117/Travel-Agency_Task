variable "cluster_name" {
  description = "Cluster name."
  default = "Demo_cluster"
}

variable "trusted_cidr_blocks" {
  description = "List of trusted subnets CIDRs with hosts that should connect to the cluster. E.g., subnets with ALB and bastion hosts."
  type        = list(string)
  default     = ["172.20.0.0/16","172.22.0.0/16"]
}

variable "instance_types" {
  description = "ECS node instance types. Maps of pairs like `type = weight`. Where weight gives the instance type a proportional weight to other instance types."
  type        = map(any)
  default = {
    "t3.xlarge" = 1
  }
}

variable "protect_from_scale_in" {
  description = "The autoscaling group will not select instances with this setting for termination during scale in events."
  default     = true
}

variable "asg_min_size" {
  description = "The minimum size the auto scaling group (measured in EC2 instances)."
  default     = 1
}

variable "asg_max_size" {
  description = "The maximum size the auto scaling group (measured in EC2 instances)."
  default     = 1
}

variable "spot" {
  description = "Choose should we use spot instances or on-demand to populate ECS cluster."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Additional security group IDs. Default security group would be merged with the provided list."
  default     = []
}

variable "subnets_ids" {
  description = "IDs of subnets. Use subnets from various availability zones to make the cluster more reliable."
  type        = list(string)
  default = ["subnet-0cc43954c41fd8e21", "subnet-09390d1809a5ab985"]
}

variable "target_capacity" {
  description = "The target utilization for the cluster. A number between 1 and 100."
  default     = "100"
}

variable "user_data" {
  description = "A shell script will be executed at once at EC2 instance start."
  default     = ""
}

variable "ebs_disks" {
  description = "A list of additional EBS disks."
  type        = map(string)
  default     = {}
}

variable "on_demand_base_capacity" {
  description = "The minimum number of on-demand EC2 instances."
  default     = 1
}

variable "lifecycle_hooks" {
  description = "A list of lifecycle hook actions. See details at https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html."
  type = list(object({
    name                    = string
    lifecycle_transition    = string
    default_result          = string
    heartbeat_timeout       = number
    role_arn                = string
    notification_target_arn = string
    notification_metadata   = string
  }))
  default = []
}

variable "arm64" {
  description = "ECS node architecture. Default is `amd64`. You can change it to `arm64` by activating this flag. If you do, then you should use corresponding instance types."
  type        = bool
  default     = false
}

data "aws_vpc" "net" {
  filter {
    name   = "tag:Name"
    values = ["demo_VPC"]
  }
}

data "aws_subnet" "net_private" {
  vpc_id = data.aws_vpc.net.id

  filter {
    name   = "tag:Name"
    values = ["demo-PrivateSubnet-0"]
  }
}

data "aws_subnet" "net_private_1" {
  vpc_id = data.aws_vpc.net.id

  filter {
    name   = "tag:Name"
    values = ["demo-PrivateSubnet-1"]
  }
}

variable "root_volume_size" {
  description = "Volume size of the instances in the ecs cluster"
  default     = "10"
}

variable "ebs_volume_size" {
  description = "Volume size of the instances in the ecs cluster"
  default     = "10"
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "aws_ssm_parameter" "ecs_ami_arm64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id"
}

variable "bb_token_param" {
  description = "parameter name for bit bucket token to clone repos "
  default     = "/infra/bb_token"
}

locals {
  ami_id                  = var.arm64 ? data.aws_ssm_parameter.ecs_ami_arm64.value : data.aws_ssm_parameter.ecs_ami.value
  asg_max_size            = var.asg_max_size
  asg_min_size            = var.asg_min_size
  ebs_disks               = var.ebs_disks
  instance_types          = var.instance_types
  lifecycle_hooks         = var.lifecycle_hooks
  name                    = replace(var.cluster_name, " ", "_")
  on_demand_base_capacity = var.on_demand_base_capacity
  protect_from_scale_in   = var.protect_from_scale_in
  sg_ids                  = distinct(concat(var.security_group_ids, [aws_security_group.ecs_nodes.id]))
  spot                    = var.spot == true ? 0 : 100
  subnets_ids             = var.subnets_ids
  target_capacity         = var.target_capacity
  trusted_cidr_blocks     = var.trusted_cidr_blocks
  user_data               = var.user_data == "" ? [] : [var.user_data]
  vpc_id                  = data.aws_vpc.net.id

  tags = {
    Name   = var.cluster_name,
    Module = "ECS Cluster"
  }
}
variable "environment" {
  default = "demo"
  
}



