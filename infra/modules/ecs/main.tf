# ECS resource

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {                          #Enable Container Insights in ECS Cluster:
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS TASK DEFINITION APPOINTMENT SERVICE

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
    # CloudWatch Agent sidecar container definition
    name      = "cloudwatch-agent"
    image     = "amazon/cloudwatch-agent:latest"
    cpu       = 50
    memory    = 128
    essential = false
    environment = [
      {
        name  = "CW_CONFIG_CONTENT"
        value = filebase64("${path.module}/../../environments/dev/cloudwatch-config.json")        
#value = filebase64("cloudwatch-config.json")  # Reference the CloudWatch config file
      }
    ]
    logConfiguration = {
    logDriver = "awslogs"
     options = {
      "awslogs-group"         = "aws_cloudwatch_log_group.ecs_logs.name"
      "awslogs-region"        = "us-east-1"
      "awslogs-stream-prefix" = "cloudwatch-agent"
  }
}
    mountPoints = [
      {
        sourceVolume = "cloudwatch-config-volume"
        containerPath = "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
      }
    ]
   command = [
      "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl",
      "-c", "file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "-a", "start"
     ]
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
    environment = [
      {
        name  = "AWS_XRAY_DAEMON_ADDRESS"
        value = "xray.us-east-1.amazonaws.com:2000"
      },
      {
        name  = "AWS_XRAY_TRACING_NAME"
        value = "appointment-service-trace"
      },
      {
        name  = "AWS_XRAY_DAEMON_DISABLE_METADATA"
        value = "true"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "xray"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  tags = {
    Name = var.task_name
  }

  volume {
    name = "cloudwatch-config-volume"
  }
}
/*
 # ECS TASK DEFINITION PROMETHEUS
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "prometheus-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:latest"
      essential = true
      cpu       = 128
      memory    = 256
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "prometheus"
        }
      }
    }
  ])
}
*/
 # ECS TASK DEFINITION GRAFANA
/* resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn      = var.execution_role
 
  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = "admin"
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])
}
*/
# ECS TASK DEFINITION PATIENT SERVICE

resource "aws_ecs_task_definition" "patient_service" {
  family                   = var.task_name
  cpu                      = 512
  memory                   = 1024
  container_definitions    = jsonencode([{
    name       = var.patient_container_name
    image      = var.image_url_patient
    memory     = 512
    cpu        = 256   
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
    # CloudWatch Agent sidecar container definition
    name      = "cloudwatch-agent"
    image     = "amazon/cloudwatch-agent:latest"
    cpu       = 50
    memory    = 128
    essential = false
    environment = [
      {
        name  = "CW_CONFIG_CONTENT"
        value = filebase64("${path.module}/../../environments/dev/cloudwatch-config.json")
       # value = filebase64("cloudwatch-config.json")  # Reference the CloudWatch config file
      }
    ]
     logConfiguration = {
    logDriver = "awslogs"
     options = {
      "awslogs-group"         = "aws_cloudwatch_log_group.ecs_logs.name"
      "awslogs-region"        = "us-east-1"
      "awslogs-stream-prefix" = "cloudwatch-agent"
  }
}
    mountPoints = [
      {
        sourceVolume = "cloudwatch-config-volume"
        containerPath = "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
      }
    ]
   command = [
      "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl",
      "-c", "file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
      "-a", "start"
     ]
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
    environment = [
      {
        name  = "AWS_XRAY_DAEMON_ADDRESS"
        value = "xray.us-east-1.amazonaws.com:2000"
      },
      {
        name  = "AWS_XRAY_TRACING_NAME"
        value = "patient-service-trace"
      },
      {
        name  = "AWS_XRAY_DAEMON_DISABLE_METADATA"
        value = "true"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "xray"
      }
    }
  }])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role

  tags = {
    Name = var.task_name
  }

 volume {
   name = "cloudwatch-config-volume"
   
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
# ECS SERVICE FOR PROMETHEUS
/* resource "aws_ecs_service" "prometheus" {
  name            = "prometheus-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.prometheus_tg_arn
    container_name   = "prometheus"
    container_port   = 9090
  }
}
*/
# ECS SERVICE FOR GRAFANA
/* resource "aws_ecs_service" "grafana" {
  name            = "grafana-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.grafana_tg_arn
    container_name   = "grafana"
    container_port   = 3000
  }
}
*/

# AWS cloud watch log group resource.
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/ecs-application-logs"
  retention_in_days = 7
}

output "log_group_name" { 
value = aws_cloudwatch_log_group.ecs_logs.name
}

