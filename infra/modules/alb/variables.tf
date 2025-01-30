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
