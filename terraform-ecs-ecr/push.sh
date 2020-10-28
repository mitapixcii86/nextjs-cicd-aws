# #!/bin/bash
# # 
# # Builds a Docker image and pushes to an AWS ECR repository
# #
# # Invoked by the terraform-aws-ecr-docker-image Terraform module.
# #
# # Usage:
# #
# # # Acquire an AWS session token
# # $ ./push.sh . 123456789012.dkr.ecr.us-west-1.amazonaws.com/hello-world latest
# #

set -e

source_path="$1"
repository_url="$2"
tag="${3:-latest}"

region="$(echo "$repository_url" | cut -d. -f4)"
image_name="$(echo "$repository_url" | cut -d/ -f2)"
repository_dns="$(echo "$repository_url" | cut -d/ -f1)"

(cd "$source_path" && docker build -t "$image_name" .)

aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$repository_dns"
docker tag "$image_name" "$repository_url":"$tag"
docker push "$repository_url":"$tag"

#!/usr/bin/env bash

# set -e
# echo "Retrieve an authentication token...."
# aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "${ecr-registry_id}".dkr.ecr."$region".amazonaws.com
# docker build -t nextjs-app .
# echo "Building image..."
# docker build -t ${image_name} .
# echo "Pushing image"
# docker push ${ecs_repository_url}:${var.tag}
# echo "Updating CFN"
# aws cloudformation update-stack --stack-name $STACK_NAME --use-previous-template --capabilities CAPABILITY_IAM \
#   --parameters ParameterKey=DockerImageURL,ParameterValue=${ecr-registry_id}.dkr.ecr.${var.region}.amazonaws.com/${var.image_name}:${var.tag} \
#   ParameterKey=DesiredCapacity,UsePreviousValue=true \
#   ParameterKey=InstanceType,UsePreviousValue=true \
#   ParameterKey=MaxSize,UsePreviousValue=true \
#   ParameterKey=SubnetIDs,UsePreviousValue=true \
#   ParameterKey=VpcId,UsePreviousValue=true