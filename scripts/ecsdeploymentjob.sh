#!/bin/bash -e

#ECR Integers
date=`date "+%Y%m%d%H%M"`
profile_name="production"
AWS_ACCOUNT_ID="111111111111"
Region="eu-west-1"
dockerfilepath="/docker_services/maintainer"
dockerfilename="dockerfile"
ProjectName="production/maintainer"
SOURCE_IMAGE="$ProjectName:$date"
ECR_URL="$AWS_ACCOUNT_ID.dkr.ecr.$Region.amazonaws.com"
TARGET_IMAGE_LATEST="$ECR_URL/$ProjectName:latest"

#ECS Integers
ecsClusterName="cs-ds-prod-cluster"
nameService="maintainer-service"
nameTaskDefinition="cs-ds-prod-maintainer-task-definition"
#td_version="latest"
desired_count=1

###Image create step
echo "docker build  -t "$ProjectName:$date" -f  .$dockerfilepath/$dockerfilename ."
docker build  -t "$ProjectName:$date" -f  .$dockerfilepath/$dockerfilename .
echo "docker tag ${SOURCE_IMAGE} ${TARGET_IMAGE_LATEST}"
docker tag ${SOURCE_IMAGE} ${TARGET_IMAGE_LATEST}

###ECR logged in & Image push to ECR 
aws ecr get-login-password --region $Region --profile $profile_name | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$Region.amazonaws.com
echo "docker push ${TARGET_IMAGE_LATEST}"
docker push "${TARGET_IMAGE_LATEST}"

###ECS deployment
echo "aws ecs update-service --cluster ${ecsClusterName} --service ${nameService} --task-definition ${nameTaskDefinition} --desired-count $desired_count --force-new-deployment" --region $Region --profile $profile_name
aws ecs update-service --cluster ${ecsClusterName} --service ${nameService} --task-definition ${nameTaskDefinition} --desired-count $desired_count --force-new-deployment --region $Region --profile $profile_name
