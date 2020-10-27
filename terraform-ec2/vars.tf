
variable "aws_region" {
  default = "eu-central-1"
}

#EC2 instance keyname to generate a key automatically
variable "key_name" {
  description = "Enter your key name for EC2 SSH connection "
  default     = "terraform-ansible"
}

# variable "ami_key_pair_name" {
#   description = "Enter your your public key for EC2 SSH connection (leave it blank in case you want to autogenerate)"}

# RETREIEVE ALL THE AVAILABILITY ZONE IN THE REGION
data "aws_availability_zones" "available" {}

# SPECIFY AVAILABILITY ZONES AS PER YOUR REQUIREMENT 
variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

#PREFFERED OPERATING SYSTEM OF YOUR CHOICE
variable "ec2_amis" {
  description = "Ubuntu Server 16.04 LTS (HVM)"
  type        = map
  default = {
    "eu-central-1" = "ami-0d971d62e4d019dcc",
  }
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.22.0/24", "10.0.44.0/24"]
}

variable "docker-test-devops-alb-trgt-grp_name" {
  default = "terraform-ansible"
}