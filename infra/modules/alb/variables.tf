variable "vpc_id" {
  description = "VPC ID where ALB should be created"
  type        = string
}

variable "subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "alb_name" {
  description = "ALB Name"
  type        = string
  default     = "my-app-alb"
}

variable "alb_security_group_name" {
  description = "Name of the security group for ALB"
  type        = string
  default     = "app-alb-sg"
}
