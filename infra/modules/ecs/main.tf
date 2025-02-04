resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  settings {                          #Enable Container Insights in ECS Cluster:
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "appointment_service" {
  family                   = var.task_name
  container_definitions    = jsonencode([{
    name       = var.appointment_container_name
    image      = var.image_url
    memory     = var.task_memory
    cpu        = var.task_cpu  # Make sure this is an integer
    essential  = true
   
   logConfiguration = {  # ECS task definition to send container logs to CloudWatch
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
    portMappings = [
      {
        containerPort = 3001
        hostPort      = 3001
        protocol      = "tcp"
      }
    ]
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  # Task-level CPU and Memory
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  tags = {
    Name = var.task_name
  }
}


resource "aws_ecs_task_definition" "patient_service" {
  family                   = var.task_name
  container_definitions    = jsonencode([{
    name       = var.patient_container_name
    image      = var.image_url_patient
    memory     = var.task_memory
    cpu        = var.task_cpu  # Make sure this is an integer
    essential  = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  # Task-level CPU and Memory
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  tags = {
    Name = var.task_name
  }
}


# ECS Service for Appointment Service
resource "aws_ecs_service" "appointment_service" {
  name            = var.appointment_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.appointment_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.appointment_tg_arn
    container_name   = var.appointment_container_name
    container_port   = 3001
  }
}

# ECS Service for Patient Service
resource "aws_ecs_service" "patient_service" {
  name            = var.patient_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.patient_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.patient_tg_arn
    container_name   = var.patient_container_name
    container_port   = 3000
  }
}

