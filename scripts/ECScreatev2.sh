#!/bin/bash
#PMS

#####Create all instaces of the ECS Clusters

echo "list all auto-scaling groups"
#aws autoscaling describe-auto-scaling-groups  | grep "AutoScalingGroupName" | awk -F':' '{print $2}' | awk -F'"' '{print $2}'

###you can chose to your infra. env. such as test, qa, uat, staging.
aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("test"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 1 --max-size 4 --region eu-central-1; done 
aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("qa"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 1 --max-size 1 --region eu-central-1; done 
#aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("staging"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 1 --max-size 1 --region eu-central-1; done 
#aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("uat"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 1 --max-size 1 --region eu-central-1; done 

#sleep 240
############################################

#####EC2

traefik_server="`aws ec2 describe-tags --filters "Name=value, Values=traefik" "Name=resource-type, Values=instance"  | grep "ResourceId" | awk -F":" '{print $2}' | awk -F'"' '{print $2}'`"
aws ec2 start-instances --instance-ids $traefik_server

backend_services="`aws ec2 describe-tags --filters "Name=value, Values=backend_services" "Name=resource-type, Values=instance"  | grep "ResourceId" | awk -F":" '{print $2}' | awk -F'"' '{print $2}'`"
aws ec2 start-instances --instance-ids $backend_services

############################################

#echo "download clusterinformation file from s3"

aws s3 cp s3://dummy-project/clusterinformation.txt . 

cat ~/Desktop/ECS/clusterinformation.txt | while read clusters; do

    clustername="`echo $clusters | awk -F':' '{print $1}'`"
    servicename="`echo $clusters | awk -F':' '{print $2}'`"
    taskname="`echo $clusters | awk -F':' '{print $3}'`"

###ECS -->> Fargate

    #echo " 
    #    aws ecs create-service \
    #    --cluster $clustername \
    #    --service-name $servicename \
    #    --task-definition $taskname \
    #    --desired-count 1 \
    #    --launch-type FARGATE \
    #    --platform-version LATEST \
    #    --network-configuration 'awsvpcConfiguration={subnets=[subnet-1,subnet-2],securityGroups=[sg-02cf2256900fe9cbf],assignPublicIp=ENABLED}'
    #"

        #aws ecs create-service \
        #--cluster $clustername \
        #--service-name $servicename \
        #--task-definition $taskname \
        #--desired-count 1 \
        #--launch-type FARGATE \
        #--platform-version LATEST \
        #--network-configuration 'awsvpcConfiguration={subnets=[subnet-1,subnet-2],securityGroups=[sg-02cf2256900fe9cbf],assignPublicIp=ENABLED}'

###

###ECS -->> EC2 
    echo " 
        aws ecs create-service \
        --cluster $clustername \
        --service-name $servicename \
        --task-definition $taskname \
        --desired-count 1 \
        --launch-type EC2 
    "

        aws ecs create-service \
        --cluster $clustername \
        --service-name $servicename \
        --task-definition $taskname \
        --desired-count 1 \
        --launch-type EC2 
###

done

