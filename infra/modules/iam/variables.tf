variable "ecs_task_role_name" {
  description = "Name of the IAM role for ECS task execution"
  type        = string
  default     = "ecsTaskExecutionRole"
}
variable "execution_role" {
  description = "IAM Role ARN for ECS Execution"
  type        = string
  default     = "ecslogsrole"
}
