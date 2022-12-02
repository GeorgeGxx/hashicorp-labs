##################################################################################
# vars.tf
##################################################################################

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-east-1"
}
 variable "AMIS" {
   default = {
#     # ############################################
#     # # LaunchInstances:
#     #
#     #   Northern Virginia => us-east-1
#     #   OS        => Amazon Linux 2 Kernel 5.10 AMI 2.0.20221004.0 x86_64 HVM gp2
#     #   AMI_ID    => ami-09d3b3274b6c5d4aa
#     #
#     #   AMI shortcut (AMAZON MACHINE IMAGE)
#     #
#     # ############################################
     us-east-1 = "ami-09d3b3274b6c5d4aa"
   }
 }

##################################################################################
# PROVIDERS
##################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.30.0"
    }
  }
}

# provider "aws" {
#   shared_config_files      = ["C:/Users/jorge/.aws/config"]
#   shared_credentials_files = ["C:/Users/jorge/.aws/credentials"]
#   profile                  = "User1"
# }

provider "aws" {
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
    region = "${var.AWS_REGION}"
}

##################################################################################
# DATA
##################################################################################

/* data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
} */

# data "aws_ami" "server_ami" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# data "aws_ami" "server_ami" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
# }

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_subnet" "subnet1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
}

# ROUTING #
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
resource "aws_security_group" "launch-wizard-1" {
  name   = "launch-wizard-1"
  vpc_id = aws_vpc.vpc.id
  
  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCES #
resource "aws_instance" "gserver" {
  ami                    = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.launch-wizard-1.id]
  key_name               = "aws-ec2"

  user_data = filebase64("userdata.sh") 

  tags = {
    Name = "gserver"
  }

}

# resource "aws_instance" "DEVOPS_INUSE" {
#   ami                    = "${lookup(var.AMIS, var.AWS_REGION)}"
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.subnet1.id
#   vpc_security_group_ids = [aws_security_group.launch-wizard-1.id]
#   key_name              = "aws-ec2"

#   #user_data = filebase64("userdata.sh")

#   tags                   = { Name = "DEVOPS" } 

# }