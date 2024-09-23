# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Change this to your preferred region
}

# Fetch default VPC details
data "aws_vpc" "default" {
  default = true
}

# Create Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Create IAM role for EC2
resource "aws_iam_role" "ec2_admin_role" {
  name = "kops_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AdministratorAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "admin_policy_attachment" {
  role       = aws_iam_role.ec2_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_admin_role.name
}

# Fetch default subnet in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a key pair
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "kops-key"
  public_key = file("./kops.pub")  # Path to your public key file
}

# Create EC2 instance
resource "aws_instance" "free_tier_instance" {
  ami           = "ami-0e86e20dae9224db8" 
  instance_type = "t2.micro" 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = data.aws_subnets.default.ids[0]  # Use the first subnet in the default VPC

  key_name               = aws_key_pair.ec2_key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "Mangementserver"
  }
}

# Create a s3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "sinayem-kops-123.in"
}