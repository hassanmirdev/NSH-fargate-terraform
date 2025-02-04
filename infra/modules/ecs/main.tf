resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {                          #Enable Container Insights in ECS Cluster:
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "appointment_service" {
  family                   = var.task_name
  cpu                      = 512
  memory                   = 1024
  container_definitions    = jsonencode([{
    name       = var.appointment_container_name
    image      = var.image_url
     memory     = 512
     cpu        = 256
  
    essential  = true
   
    portMappings = [
      {
        containerPort = 3001
        hostPort      = 3001
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }, {
      # X-Ray Daemon sidecar container definition
      name      = "xray-daemon"
      image     = "amazon/aws-xray-daemon"
      cpu       = 50
      memory    = 128
      essential = false
      portMappings = [
        {
          containerPort = 2000
          hostPort      = 2000
        }
      ]
    }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  # Task-level CPU and Memory
  # cpu                      = 256
 # memory                   = 512

  tags = {
    Name = var.task_name
  }
}


resource "aws_ecs_task_definition" "patient_service" {
  family                   = var.task_name
  cpu                      = 256
  memory                   = 5212
  container_definitions    = jsonencode([{
    name       = var.patient_container_name
    image      = var.image_url_patient
    memory     = 512
    cpu        = 256   
    #cpu        = var.task_cpu  # Make sure this is an integer
    essential  = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }, {
      # X-Ray Daemon sidecar container definition
      name      = "xray-daemon"
      image     = "amazon/aws-xray-daemon"
      cpu       = 50
      memory    = 128
      essential = false
      portMappings = [
        {
          containerPort = 2000
          hostPort      = 2000
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

# AWS cloud watch log group resource.
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/ecs-application-logs"
  retention_in_days = 7
}

output "log_group_name" { 
value = aws_cloudwatch_log_group.ecs_logs.name
}
