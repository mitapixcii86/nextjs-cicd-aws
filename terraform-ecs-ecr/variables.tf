variable "image_name" {
  description = "Name of Docker image"
  type        = string
  default     = "nextjs-app"
}

variable "source_path" {
  description = "Path to Docker image source"
  type        = string
  default     = "../app/"
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}

variable "hash_script" {
  description = "Path to script to generate hash of source contents"
  type        = string
  default     = ""
}

variable "push_script" {
  description = "Path to script to build and push Docker image"
  type        = string
  default     = ""
}

variable "subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}

variable "amis" {
  description = "Which AMI to spawn."
  default = {
    eu-central-1 = "ami-0d971d62e4d019dcc"
  }
}
variable "instance_type" {
  default = "t2.micro"
}

variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  default     = "1"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  default     = "10"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  default     = "4"
}
variable "ssh_pubkey_file" {
  description = "Path to an SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

#EC2 instance keyname to generate a key automatically
variable "key_name" {
  description = "Enter your key name for EC2 SSH connection "
  default     = "terraform-ansible"
}

# SPECIFY AVAILABILITY ZONES AS PER YOUR REQUIREMENT 
variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}
