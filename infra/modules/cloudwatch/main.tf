resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.log_group_name}"
}
