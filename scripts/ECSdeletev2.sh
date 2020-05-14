#!/bin/bash
#PMS

echo -n > ~/Desktop/ECS/clusterinformation.txt

aws ecs list-clusters | egrep 'cls-property-dev|cls-property-test|cls-property-staging' -i | awk -F'cluster/' '{print $2}' |awk -F'"' '{print $1}' | while read clustername; do

	allservice="`aws ecs list-services --cluster $clustername | grep "arn:aws:ecs" |awk -F "/" '{print $2}' | awk -F '"' '{print $1}'`"


		for services in ${allservice[@]}; do
			
			taskname="`aws ecs describe-services --services $services --cluster $clustername |grep "taskDefinition" |head -n1 | awk -F ":" '{print $7}' | awk -F "/" '{print $2}'`" 

			echo $clustername:$services:$taskname >> ~/Desktop/ECS/clusterinformation.txt

		    echo "aws ecs delete-service --cluster $clustername --service $services --force"
		    aws ecs delete-service --cluster $clustername --service $services --force

		done

done


#####EC2

traefik_server="`aws ec2 describe-tags --filters "Name=value, Values=traefik" "Name=resource-type, Values=instance"  | grep "ResourceId" | awk -F":" '{print $2}' | awk -F'"' '{print $2}'`"
aws ec2 stop-instances --instance-ids $traefik_server

backend_services="`aws ec2 describe-tags --filters "Name=value, Values=backend_services" "Name=resource-type, Values=instance"  | grep "ResourceId" | awk -F":" '{print $2}' | awk -F'"' '{print $2}'`"
aws ec2 stop-instances --instance-ids $backend_services

############################################


#####Erase all instaces of the ECS Clusters

echo "list all auto-scaling groups"
#aws autoscaling describe-auto-scaling-groups  | grep "AutoScalingGroupName" | awk -F':' '{print $2}' | awk -F'"' '{print $2}'

###you can chose to your infra. env. such as test, qa, uat, staging.
aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("test"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 0 --max-size 0 --region eu-central-1; done 
aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("qa"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 0 --max-size 0 --region eu-central-1; done 
#aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("staging"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 0 --max-size 0 --region eu-central-1; done 
#aws autoscaling describe-tags  --region eu-central-1 | jq '.Tags[] | select(.["Value"] | contains("uat"))' | grep ResourceId |awk '{print $2}' |awk -F'"' '{print $2 }' | uniq |while read autoname; do echo $autoname; aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoname --min-size 0 --max-size 0 --region eu-central-1; done 

############################################

	echo "write task definitions file name to s3 bucket"
	aws s3 rm s3://dummy-project/clusterinformation.txt
	echo "aws s3 sync ~/Desktop/servicetaskname.txt s3://dummy-project/"
    aws s3 cp ~/Desktop/ECS/clusterinformation.txt s3://dummy-project/
    cat ~/Desktop/ECS/clusterinformation.txt