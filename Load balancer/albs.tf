locals {
  tags = {
    "fetchr:owner"       = "DevOps"
    "fetchr:environment" = var.environment
  }
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket_policy" "lb-bucket-policy" {
  bucket = aws_s3_bucket.prod-bucket.id

  policy = <<POLICY
  {
    "Version": "2008-10-17",
    "Id": "Policy1413182823222",
    "Statement": [
        {
            "Sid": "Stmt1413182819426",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::718504428378:root"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::travel-agency-loadbalancers-logs"
        },
        {
            "Sid": "AWSLogDeliveryWritenlb",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::travel-agency-loadbalancers-logs/public-alb/AWSLogs/234111192759/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "Stmt1413182819422",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::718504428378:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::travel-agency-loadbalancers-logs/public-alb/AWSLogs/234111192759/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}

POLICY
}
resource "aws_s3_bucket" "prod-bucket" {
  bucket        = "travel-agency-loadbalancers-logs"
  force_destroy = true

}
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.prod-bucket.id
  acl    = "log-delivery-write"
}


/*resource "aws_s3_bucket_policy" "prod" {
  bucket = "aws_s3_bucket.prod-bucket.id"
  policy = "${data.aws_iam_policy_document.s3_bucket_lb_write.json}"
}


data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.prod-bucket.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.prod-bucket.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect = "Allow"
    resources = ["${aws_s3_bucket.prod-bucket.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

output "bucket_name" {
  value = "${aws_s3_bucket.prod-bucket.bucket}"
}*/
/*resource "aws_s3_bucket" "terraform_state" {
  bucket        = "travel-agency-loadbalancers-logs"
  force_destroy = true

  tags = {
    Name        = "travel-agency-loadbalancers-logs"
    Environment = var.environment
  }
}
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "block_public_access_lb" {
  bucket                  = aws_s3_bucket.terraform_state.id
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}
/*resource "aws_s3_bucket" "lb_bucket" {
  bucket        ="Lyve-prod-ireland-loadbalancers-logs"
  force_destroy = true

  tags = {
    Name        = "Lyve-prod-ireland-loadbalancers-logs"
    Environment = var.environment
  }
}
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.lb_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "block_public_access_lb" {
  bucket                  = aws_s3_bucket.lb_bucket.id
  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.lb_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.lb_bucket.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.lb_bucket.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.lb_bucket.arn}"
        },
        {
            "Sid": "DenyUnSecureCommunications",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "${aws_s3_bucket.lb_bucket.arn}",
                "${aws_s3_bucket.lb_bucket.arn}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
  POLICY
}
resource "aws_kms_key" "cmk_alb" {
  description             = "ALB_KMS_Key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = {
    Application = "KMS for ALB"
  }
  policy = <<EOF
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
  EOF
}

resource "aws_kms_alias" "cmk_config" {
  name          = "alias/cmk-alb"
  target_key_id = aws_kms_key.cmk_alb.key_id
}



resource "aws_s3_bucket_server_side_encryption_configuration" "lb_bucket_encryption_config" {
  bucket = aws_s3_bucket.lb_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cmk_alb.key_id
    }
  }
}

resource "aws_s3_bucket_versioning" "lb_bucket_versioning_config" {
  bucket = aws_s3_bucket.lb_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}*/


module "staging_cluster_alb" {
  source             = "../terraform-modules/ecs-alb"
  vpc_id             = data.aws_vpc.net.id
  alb_name           = "demo-Cluster-ALB"
  subnet_ids         = [data.aws_subnet.net_public_az1.id, data.aws_subnet.net_public_az2.id]
  #certificate_arn    = "arn:aws:acm:eu-west-1:747996363323:certificate/9b98f062-113b-4e13-a335-ea92514e3b47"
  #enable_deletion_protection = true
  access_logs_bucket = aws_s3_bucket.prod-bucket.id
  access_logs_prefix = "public-alb"

  tags = local.tags

  alb_sg_ingress = [{
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }
  /*  {
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
    },*/
  ]

  alb_sg_egress = [{
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }]
}

output "alb_arn" {
  value = "${module.staging_cluster_alb.alb_arn}"
}

output "alb_arn_suffix" {
  value = "${module.staging_cluster_alb.alb_arn_suffix}"
}

output "http_listener_arn" {
  value = "${module.staging_cluster_alb.http_listener_arn}"
}
/*
 output "https_listener_arn" {
   value = "${module.staging_cluster_alb.https_listener_arn}"
}
*/
output "alb_dns_name" {
  value = "${module.staging_cluster_alb.dns_name}"
}
/*
module "staging_cluster_alb_2" {
  source             = "../../terraform-modules/ecs-alb"
  vpc_id             = "${data.aws_vpc.net.id}"
  alb_name           = "prod-Cluster-ALB-2"
  subnet_ids         = [data.aws_subnet.net_public_az1.id, data.aws_subnet.net_public_az2.id]
  certificate_arn    = "arn:aws:acm:eu-west-1:747996363323:certificate/9b98f062-113b-4e13-a335-ea92514e3b47"
  #enable_deletion_protection = true
  access_logs_bucket = aws_s3_bucket.prod-bucket.id
  access_logs_prefix = "public-alb"

  tags = "${local.tags}"

  alb_sg_ingress = [{
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  },
    {
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
    },
  ]

  alb_sg_egress = [{
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }]
}

output "alb_arn_2" {
  value = "${module.staging_cluster_alb_2.alb_arn}"
}

output "alb_arn_suffix_2" {
  value = "${module.staging_cluster_alb_2.alb_arn_suffix}"
}

output "http_listener_arn_2" {
  value = "${module.staging_cluster_alb_2.http_listener_arn}"
}

 output "https_listener_arn_2" {
  value = "${module.staging_cluster_alb_2.https_listener_arn}"
}

output "alb_dns_name_2" {
  value = "${module.staging_cluster_alb_2.dns_name}"
}
*/
/*module "staging_cluster_alb_3" {
  source             = "../../terraform-modules/ecs-alb"
  vpc_id             = "${data.aws_vpc.net.id}"
  alb_name           = "Staging-Cluster-ALB-3"
  subnet_ids         = [data.aws_subnet.net_public_az1.id, data.aws_subnet.net_public_az2.id]
  certificate_arn    = "arn:aws:acm:eu-west-1:083052042026:certificate/caa1cf57-6b03-4f1f-b710-f5b5e536520c"
  access_logs_bucket = "staging-ireland-loadbalancers-logs"
  access_logs_prefix = "public-alb"

  tags = "${local.tags}"

  alb_sg_ingress = [{
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  },
    {
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
    },
  ]

  alb_sg_egress = [{
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }]
}

output "alb_arn_3" {
  value = "${module.staging_cluster_alb_3.alb_arn}"
}

output "alb_arn_suffix_3" {
  value = "${module.staging_cluster_alb_3.alb_arn_suffix}"
}

output "http_listener_arn_3" {
  value = "${module.staging_cluster_alb_3.http_listener_arn}"
}

# output "https_listener_arn_3" {
#   value = "${module.staging_cluster_alb_3.https_listener_arn}"
# }

output "alb_dns_name_3" {
  value = "${module.staging_cluster_alb_3.dns_name}"
}

module "staging_cluster_alb_private" {
  source             = "../../terraform-modules/ecs-alb"
  alb_internal       = true
  vpc_id             = "${data.aws_vpc.net.id}"
  alb_name           = "Staging-Cluster-ALB-Pri"
  subnet_ids         = [data.aws_subnet.net_public_az1.id, data.aws_subnet.net_public_az2.id]
  certificate_arn    = "arn:aws:acm:eu-west-1:083052042026:certificate/caa1cf57-6b03-4f1f-b710-f5b5e536520c"
  access_logs_bucket = "staging-ireland-loadbalancers-logs"
  access_logs_prefix = "private-alb"

  tags = "${local.tags}"

  alb_sg_ingress = [{
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  },
    {
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 443
      to_port     = 443
    },
  ]

  alb_sg_egress = [{
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }]
}

output "alb_arn_private" {
  value = "${module.staging_cluster_alb_private.alb_arn}"
}

output "alb_arn_suffix_private" {
  value = "${module.staging_cluster_alb_private.alb_arn_suffix}"
}

output "http_listener_arn_private" {
  value = "${module.staging_cluster_alb_private.http_listener_arn}"
}

# output "https_listener_arn_private" {
#   value = "${module.staging_cluster_alb_private.https_listener_arn}"
# }

output "alb_dns_name_private" {
  value = "${module.staging_cluster_alb_private.dns_name}"
}

module "staging_cluster_nlb" {
  source            = "../../terraform-modules/nlb"
  vpc_id            = "${data.aws_vpc.net.id}"
  name              = "Client-NLB"
  nlb_http_tg_name  = "client-exp-internal-alb-http-tg"
  nlb_https_tg_name = "client-exp-internal-alb-https-tg"
  subnet_ids        = [data.aws_subnet.net_public_az1.id, data.aws_subnet.net_public_az2.id]

  tags = "${local.tags}"
}

output "eip_this0" {
  value = "${module.staging_cluster_nlb.eip_this0}"
}

output "eip_this1" {
  value = "${module.staging_cluster_nlb.eip_this1}"
}

output "eip_this2" {
  value = "${module.staging_cluster_nlb.eip_this2}"
}

output "nlb_arn" {
  value = "${module.staging_cluster_nlb.nlb_arn}"
}

output "nlb_arn_suffix" {
  value = "${module.staging_cluster_nlb.nlb_arn_suffix}"
}

output "nlb_http_listener_arn" {
  value = "${module.staging_cluster_nlb.http_listener_arn}"
}

output "nlb_https_listener_arn" {
  value = "${module.staging_cluster_nlb.https_listener_arn}"
}

output "nlb_dns_name" {
  value = "${module.staging_cluster_nlb.dns_name}"
}*/
