data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
echo ECS_CLUSTER="${local.name}" >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum -y install python27-pip git
pip-2.7 install ansible awscli
cd /opt
BB_TOKEN=$(/usr/local/bin/aws ssm get-parameter --name ${var.bb_token_param} --region eu-west-1 --query Parameter.Value --output text)
git clone https://devops-read:$${BB_TOKEN}@bitbucket.org/Fetchr/orchestration.git
cd orchestration/ansible/
/usr/local/bin/ansible-playbook exporters_ecs.yml
EOT
  }

  dynamic "part" {
    for_each = local.user_data
    content {
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }
}

resource "aws_launch_template" "node" {
  name_prefix            = "ecs_node_"
  image_id               = local.ami_id
  instance_type          = "t3.xlarge"
  vpc_security_group_ids = local.sg_ids
  user_data              = data.cloudinit_config.config.rendered
  tags                   = local.tags
  update_default_version = true
  key_name                             = "Travel_agent_demo"


  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_node.name
  }

  dynamic "block_device_mappings" {
    for_each = local.ebs_disks
    content {
      device_name = block_device_mappings.key

      ebs {
        volume_size = block_device_mappings.value
        volume_type = "gp3"
      }
    }
  }
         block_device_mappings {
          device_name = "/dev/sdb" 

           ebs {
               delete_on_termination = "true" 
               encrypted             = "false" 
               iops                  = 100
               throughput            = 125
               volume_size           = 10
               volume_type           = "gp3" 
            }
        }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }
}
