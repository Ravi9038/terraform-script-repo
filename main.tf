
# provider "aws" {
#   region = "us-east-2"
# }

# provider "github" {
#   # token = github_token
#
# }

# resource "github_repository" "terraform-script-repo" {
#   name        = "terraform-script-repo"
#   description = "An example repository created with Terraform"
#   # private     = false
#   visibility = "public"

#   lifecycle {
#     prevent_destroy = true
#   }


# }

# resource "aws_instance" "existing_instance" {
#   ami           = var.ami
#   instance_type = var.instance_type
#
#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }
# data "aws_instance" "existing_instance" {
#   instance_id = aws_instance.app_server.id
# }
# data "aws_subnet" "subnet" {
#   id = aws_instance.app_server.subnet_id
# }


#************* new code start from here *************

# provider "aws" {
#   region = "us-east-2"
# }
# # resource "aws_instance" "existing_instance" {
# #   ami           = var.ami
# #   instance_type = var.instance_type
# #
# #   tags = {
# #     Name = "ExampleAppServerInstance"
# #   }
# # }
# # Reference the existing EC2 instance WITHOUT importing it into Terraform management
# data "aws_instance" "existing_instance" {
#   # Your existing instance ID
#   instance_id = "i-0a1f6fbeb1bdcec58"
# }
#
# # Get the VPC ID from the subnet
# data "aws_subnet" "instance_subnet" {
#   id = data.aws_instance.existing_instance.subnet_id
# }
#
#
# # Create a new security group
# resource "aws_security_group" "new_security_group" {
#   name        = "additional-security-group"
#   description = "Additional security group for existing instance"
#   vpc_id      = data.aws_subnet.instance_subnet.vpc_id
#
#   # Example rule: Allow HTTPS traffic
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "HTTPS"
#   }
#
#   # Example rule: Allow SSH traffic
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "SSH"
#   }
#
#   # Outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }
#
#   tags = {
#     Name = "additional-security-group"
#   }
# }
#
# # Get all existing security groups currently attached to the instance
# locals {
#   existing_sg_ids = data.aws_instance.existing_instance.vpc_security_group_ids
# }
#
# # Create a resource to modify the instance security groups using the AWS CLI
# # This approach avoids having Terraform manage the instance itself
# resource "null_resource" "update_security_groups" {
#   triggers = {
#     sg_id = aws_security_group.new_security_group.id
#   }
#
#   provisioner "local-exec" {
#     command = <<-EOT
#       aws ec2 modify-instance-attribute \
#         --instance-id ${data.aws_instance.existing_instance.id} \
#         --groups ${join(" ", concat(local.existing_sg_ids, [aws_security_group.new_security_group.id]))}
#     EOT
#   }
# }


## ************* new one

provider "aws" {
  region = "us-east-2"
}

# Reference the existing EC2 instance WITHOUT importing it into Terraform management
data "aws_instance" "existing_instance" {
  # Your existing instance ID
  instance_id = "i-0a1f6fbeb1bdcec58"
}

# Get the VPC ID from the subnet
data "aws_subnet" "instance_subnet" {
  id = data.aws_instance.existing_instance.subnet_id
}

# Option 1: Create a new security group with a unique name
resource "aws_security_group" "new_security_group" {
  # Add timestamp or other unique identifier to make the name unique
  name        = "additional-security-group-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  description = "Additional security group for existing instance"
  vpc_id      = data.aws_subnet.instance_subnet.vpc_id

  # Example rule: Allow HTTPS traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # Example rule: Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "additional-security-group"
  }
}

# Get all existing security groups currently attached to the instance
locals {
  existing_sg_ids = data.aws_instance.existing_instance.vpc_security_group_ids
}

# Create a resource to modify the instance security groups using the AWS CLI
resource "null_resource" "update_security_groups" {
  triggers = {
    sg_id = aws_security_group.new_security_group.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ec2 modify-instance-attribute \
        --instance-id ${data.aws_instance.existing_instance.id} \
        --groups ${join(" ", concat(tolist(local.existing_sg_ids), [aws_security_group.new_security_group.id]))}
    EOT
  }
}

# Option 2 (Alternative): Use the existing security group instead of creating a new one
# Uncomment this section and comment out the aws_security_group resource above if you want to use this approach

# data "aws_security_group" "existing_sg" {
#   name   = "additional-security-group"
#   vpc_id = data.aws_subnet.instance_subnet.vpc_id
# }
#
# # Update the null_resource to use the existing security group
# resource "null_resource" "update_security_groups_alt" {
#   triggers = {
#     sg_id = data.aws_security_group.existing_sg.id
#   }
#
#   provisioner "local-exec" {
#     command = <<-EOT
#       aws ec2 modify-instance-attribute \
#         --instance-id ${data.aws_instance.existing_instance.id} \
#         --groups ${join(" ", concat(tolist(local.existing_sg_ids), [data.aws_security_group.existing_sg.id]))}
#     EOT
#   }
# }