provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2" # Setting my region to London. Use your own region here
}

resource "aws_ecr_repository" "devops_ecr" {
  name = "devops-ecr" # Naming my repository
}