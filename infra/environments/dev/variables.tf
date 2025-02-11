variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-app-repo"
}

variable "cluster_name" {
  description = "ECS Cluster Name"
  type        = string
  default     = "my-ecs-cluster"
}

variable "task_name" {
  description = "ECS Task Name"
  type        = string
  default     = "my-task"
}

variable "image_url" {
  description = "Container Image URL"
  type        = string
  default     = "677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:appointment-service-latest"
}

variable "task_memory" {
  description = "Memory for the container"
  type        = number
  default     = 512
}

variable "task_cpu" {
  description = "CPU for the container"
  type        = number
  default     = 256
}

variable "patient_container_name" {
  description = "The name of the container"
  type        = string
  default   = "patient-container"
}

variable "patient_service_name" {
  description = "The name of the ECS service"
  type        = string
  default   = "patient-service"
}

variable "appointment_service_name" {
  description = "The name of the ECS service"
  type        = string
  default   = "appointment-service"
}

variable "appointment_container_name" {
  description = "The name of the container"
  type        = string
  default   = "appointment-container"
}


# variable "log_group_name" {
 # description = "CloudWatch Log Group Name"
 # type        = string
 # default     = "ecs-application-logs"
# }

variable "image_url_patient" {
  description = "Container Image URL"
  type        = string
  default     = "677276078111.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:patient-service-latest"
}
