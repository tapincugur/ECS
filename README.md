# ECS
### ECS Start/Stop Jobs Examples
```bash
You can schedule and run the scripts like(below): 
$ ./scripts/start.sh (00 07 * * *)
$ ./scripts/stop.sh (00 17 * * *)
```
### ECS Create Task Definitions by command line
```bash
$ aws ecs register-task-definition --cli-input-json file://~/taskdefinitions-temp/temp.json --region eu-central-1 --profile project-dev
```
