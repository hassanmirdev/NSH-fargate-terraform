aws_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
security_groups = ["sg-09c3b12ec1c311254"]
repo_name = "my-app-repo"
cluster_name = "my-ecs-cluster"
task_name = "my-task"
appoinment_container_name = "appointment-container"
image_url = "677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:appointment-service-latest"
# image_url = "677276078111.dkr.ecr.us-east-1.amazonaws.com/appointment-service:latest"

task_memory = 1024
task_cpu = 325
# log_group_name = "ecs-application-logs"
image_url_patient = "677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:patient-service-latest"
# image_url_patient = "677276078111.dkr.ecr.us-east-1.amazonaws.com/patient-service:latest"
patient_container_name = "patient-container"
appointment_service_name = "appointment-service"
patient_service_name = "patient-service"
