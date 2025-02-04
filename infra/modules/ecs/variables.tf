variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "task_name" {
  description = "The name of the ECS task definition"
  type        = string
}

variable "appointment_container_name" {
  description = "The name of the container"
  type        = string
}

variable "image_url" {
  description = "The URL of the Docker image to use in the ECS task"
  type        = string
}

variable "image_url_patient" {
  description = "The URL of the Docker image to use in the ECS task"
  type        = string
}

variable "execution_role" {
  description = "The execution role for the ECS task"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 325
}

variable "task_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "A list of security group IDs for the ECS service"
  type        = list(string)
}

variable "desired_count" {
  description = "The desired number of instances of the ECS service"
  type        = number
  default     = 1
}

variable "task_definition" {
  description = "The ARN of the ECS task definition"
  type        = string
}

variable "patient_container_name" {
  description = "The name of the container"
  type        = string
}

variable "patient_service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "appointment_service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "appointment_tg_arn" {
  description = "Target Group ARN for Appointment Service"
  type        = string
}

variable "patient_tg_arn" {
  description = "Target Group ARN for Patient Service"
  type        = string
}
